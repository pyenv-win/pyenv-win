#!/usr/bin/env python3
"""
Update .versions_cache.xml with available Python versions from mirrors.
This replaces the VBScript pyenv-update.vbs that doesn't work in GitHub Actions.
"""

import re
import sys
import json
import xml.etree.ElementTree as ET
from urllib.request import urlopen, Request
from urllib.error import URLError, HTTPError
from urllib.parse import urlparse
from html.parser import HTMLParser
from pathlib import Path


# Mirrors to scan
MIRRORS = [
    "https://www.python.org/ftp/python",
    "https://downloads.python.org/pypy/versions.json",
    "https://api.github.com/repos/oracle/graalpython/releases"
]

# Regex patterns from VBScript
REGEX_FILE = re.compile(
    r'^python-(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:([a-z]+)(\d*))?([\.-]amd64)?([\.-]arm64)?(-webinstall)?\.(exe|msi)$',
    re.IGNORECASE
)

REGEX_JSON_URL = re.compile(
    r'"download_url":\s*"(https://[^\s"]+/((?:pypy\d+\.\d+-v|graalpy-)(\d+)(?:\.(\d+))?(?:\.(\d+))?-(?:(win64|windows-amd64)|(windows-aarch64))\.zip))"'
)

REGEX_VER = re.compile(r'^(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:([a-z]+)(\d*))?$', re.IGNORECASE)


class PythonLinkParser(HTMLParser):
    """Parse HTML to extract Python download links."""
    
    def __init__(self):
        super().__init__()
        self.links = []
        self.current_link = None
        
    def handle_starttag(self, tag, attrs):
        if tag == 'a':
            for attr, value in attrs:
                if attr == 'href':
                    self.current_link = value
                    break
    
    def handle_data(self, data):
        if self.current_link:
            self.links.append((self.current_link, data.strip()))
            self.current_link = None


def fetch_url(url, headers=None):
    """Fetch URL content with error handling."""
    try:
        if headers:
            req = Request(url, headers=headers)
        else:
            req = Request(url)
        with urlopen(req, timeout=30) as response:
            return response.read().decode('utf-8')
    except (URLError, HTTPError) as e:
        print(f"Error downloading from {url}: {e}", file=sys.stderr)
        return None


def scan_cpython_versions(mirror_url):
    """Scan CPython versions from python.org mirror."""
    installers = {}
    
    # Get main page
    html = fetch_url(mirror_url)
    if not html:
        return installers
    
    parser = PythonLinkParser()
    parser.feed(html)
    
    # Find version directories (e.g., 3.11.0/, 3.10.5/)
    for href, text in parser.links:
        if REGEX_VER.match(text.strip('/')):
            # Scan each version directory
            version_url = f"{mirror_url.rstrip('/')}/{href.strip('/')}"
            version_installers = scan_version_page(version_url)
            installers.update(version_installers)
    
    return installers


def scan_version_page(url):
    """Scan a specific version page for installer files."""
    installers = {}
    
    html = fetch_url(url)
    if not html:
        return installers
    
    parser = PythonLinkParser()
    parser.feed(html)
    
    for href, text in parser.links:
        filename = text.strip()
        match = REGEX_FILE.match(filename)
        if match:
            groups = match.groups()
            major, minor, patch, rel, rel_num, x64, arm, web, ext = groups
            
            # Build full URL
            full_url = f"{url.rstrip('/')}/{filename}"
            
            # Create version code matching VBScript JoinWin32String/JoinInstallString logic
            # Format: major.minor.patch + release + rel_num + suffix
            version_code = ''
            if major:
                version_code = major
            if minor:
                version_code += '.' + minor
            if patch:
                version_code += '.' + patch
            if rel:
                version_code += rel
            if rel_num:
                version_code += rel_num
            
            # Add architecture suffix
            if arm:
                version_code += '-arm'
            elif not x64:
                # 32-bit gets -win32 suffix
                version_code += '-win32'
            # x64 gets no suffix
            
            installers[filename] = {
                'code': version_code,
                'file': filename,
                'url': full_url,
                'x64': bool(x64 or arm),
                'webInstall': bool(web),
                'msi': ext.lower() == 'msi',
                'zipRootDir': ''
            }
    
    return installers


def scan_json_releases(mirror_url):
    """Scan PyPy or GraalPython releases from JSON API."""
    installers = {}
    
    # Set User-Agent for GitHub API
    parsed_url = urlparse(mirror_url)
    is_github = parsed_url.netloc == 'api.github.com' or parsed_url.netloc == 'github.com'
    headers = {'User-Agent': 'pyenv-win-updater'} if is_github else None
    content = fetch_url(mirror_url, headers=headers)
    if not content:
        return installers
    
    try:
        # Parse as JSON
        data = json.loads(content)
        
        if is_github:
            # GitHub API format (GraalPython)
            for release in data:
                if 'assets' not in release:
                    continue
                for asset in release['assets']:
                    name = asset.get('name', '')
                    if not name.endswith('.zip'):
                        continue
                    if 'windows-amd64' not in name and 'windows-aarch64' not in name:
                        continue
                    
                    # Match: graalpy-23.1.0-windows-amd64.zip
                    match = re.match(r'^(graalpy-(\d+)\.(\d+)\.(\d+)-(windows-amd64|windows-aarch64))\.zip$', name)
                    if match:
                        zip_root = match.group(1)
                        download_url = asset.get('browser_download_url', '')
                        
                        installers[name] = {
                            'code': zip_root,
                            'file': name,
                            'url': download_url,
                            'x64': True,
                            'webInstall': False,
                            'msi': False,
                            'zipRootDir': zip_root
                        }
        else:
            # PyPy JSON format
            # Extract download URLs using regex as fallback
            for match in REGEX_JSON_URL.finditer(content):
                groups = match.groups()
                url = groups[0]
                filename = groups[1]
                zip_root = groups[1].replace('.zip', '')  # Remove .zip extension
                
                installers[filename] = {
                    'code': zip_root,
                    'file': filename,
                    'url': url,
                    'x64': True,
                    'webInstall': False,
                    'msi': False,
                    'zipRootDir': zip_root
                }
    except json.JSONDecodeError:
        # Fall back to regex for non-JSON or malformed JSON
        for match in REGEX_JSON_URL.finditer(content):
            groups = match.groups()
            url = groups[0]
            filename = groups[1]
            zip_root = groups[1].replace('.zip', '')  # Remove .zip extension
            
            installers[filename] = {
                'code': zip_root,
                'file': filename,
                'url': url,
                'x64': True,
                'webInstall': False,
                'msi': False,
                'zipRootDir': zip_root
            }
    
    return installers


def remove_duplicates(installers):
    """Remove web installers if offline version exists, and versions < 2.4."""
    filtered = {}
    
    for filename, data in installers.items():
        # Skip versions < 2.4 (Wise Installer issues)
        code = data['code']
        # Parse version from code (handles formats like "2-1-3", "3-11-0", "pypy3.7-v7.3.4-win64")
        version_parts = re.findall(r'\d+', code)
        
        if len(version_parts) >= 2:
            try:
                major = int(version_parts[0])
                minor = int(version_parts[1])
                
                # Skip if version < 2.4
                if major < 2 or (major == 2 and minor < 4):
                    continue
            except (ValueError, IndexError):
                pass
        
        # Check if webinstall has non-web equivalent
        if data['webInstall']:
            # Try to find non-web version
            non_web = filename.replace('-webinstall', '')
            if non_web in installers:
                continue  # Skip web version
        
        filtered[filename] = data
    
    return filtered


def sort_versions(installers):
    """Sort installers by semantic version."""
    def version_key(item):
        filename = item[0]
        code = item[1]['code']
        x64 = item[1]['x64']
        
        # Determine implementation type (CPython=0, PyPy=1, GraalPython=2)
        if code.startswith('pypy'):
            impl_type = 1
        elif code.startswith('graalpy'):
            impl_type = 2
        else:
            impl_type = 0  # CPython
        
        # Extract version components
        # Handle formats like: 2.4.1-win32, 3.11.0, pypy3.10-v7.3.15-win64, graalpy-23.1.0-windows-amd64
        version_match = re.match(r'^(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:([a-z]+)(\d*))?', code)
        
        if version_match:
            major = int(version_match.group(1) or 0)
            minor = int(version_match.group(2) or 0)
            patch = int(version_match.group(3) or 0)
            release = version_match.group(4) or ''  # empty for final releases
            rel_num = int(version_match.group(5) or 0)
            
            # For release sorting: empty string (final) should come AFTER pre-releases
            # Pre-releases should be ordered: a, b, rc, then final
            if release == '':
                rel_sort = (1, '', 0)  # Final releases come after pre-releases
            else:
                # Pre-releases: a=alpha, b=beta, rc=release candidate
                rel_sort = (0, release, rel_num)  # Pre-releases come first
            
            # Within same version: win32, then arm, then amd64 (no suffix)
            # Extract architecture from code suffix
            if code.endswith('-win32'):
                arch_sort = 0  # win32 first
            elif code.endswith('-arm'):
                arch_sort = 1  # arm second
            else:
                arch_sort = 2  # amd64 (no suffix) last
            
            return (impl_type, major, minor, patch, rel_sort[0], rel_sort[1], rel_sort[2], arch_sort, code)
        
        # For pypy/graalpy, extract version numbers
        numbers = re.findall(r'\d+', code)
        return (impl_type,) + tuple(int(n) for n in numbers) + (0, '', 0, 0, code,)
    
    return sorted(installers.items(), key=version_key)


def save_to_xml(installers, output_path):
    """Save installers to XML file."""
    root = ET.Element('versions')
    
    for filename, data in installers:
        version = ET.SubElement(root, 'version')
        version.set('x64', 'true' if data['x64'] else 'false')
        version.set('webInstall', 'true' if data['webInstall'] else 'false')
        version.set('msi', 'true' if data['msi'] else 'false')
        
        ET.SubElement(version, 'code').text = data['code']
        ET.SubElement(version, 'file').text = data['file']
        ET.SubElement(version, 'URL').text = data['url']
        
        if data['zipRootDir']:
            ET.SubElement(version, 'zipRootDir').text = data['zipRootDir']
    
    # Pretty print with tabs to match original format
    ET.indent(root, space='\t')
    tree = ET.ElementTree(root)
    
    # Write XML with custom declaration to match original format
    with open(output_path, 'wb') as f:
        f.write(b'<?xml version="1.0" encoding="utf-8" standalone="no"?>\n')
        tree.write(f, encoding='utf-8', xml_declaration=False)
        f.write(b'\n')  # Add newline at end of file
    
    print(f"Saved {len(installers)} installers to {output_path}")


def main():
    """Main function to update version cache."""
    all_installers = {}
    page_count = 0
    
    for mirror in MIRRORS:
        print(f":: [Info] ::  Mirror: {mirror}")
        
        # Properly parse URL to check if it's a JSON API endpoint
        parsed_url = urlparse(mirror)
        is_json_api = (mirror.endswith('.json') or 
                      parsed_url.netloc == 'api.github.com' or 
                      parsed_url.path.endswith('.json'))
        
        if is_json_api:
            installers = scan_json_releases(mirror)
        else:
            installers = scan_cpython_versions(mirror)
        
        all_installers.update(installers)
        page_count += 1
    
    # Remove duplicates and filter
    filtered = remove_duplicates(all_installers)
    
    # Sort by version
    sorted_installers = sort_versions(filtered)
    
    # Save to XML
    script_dir = Path(__file__).parent.parent.parent
    output_file = script_dir / 'pyenv-win' / '.versions_cache.xml'
    save_to_xml(sorted_installers, output_file)
    
    print(f":: [Info] ::  Scanned {page_count} pages and found {len(sorted_installers)} installers.")


if __name__ == '__main__':
    main()
