import os
import shutil
import subprocess
import sys

if __name__ == "__main__":
    if not getattr(sys, 'frozen', False):
        sys.stderr.write("This should be run as a frozen exe\n")
        sys.exit(1)

    pyenv_root = os.path.dirname(os.path.dirname(sys.executable))

    pyenv_vbs = os.path.join(pyenv_root, "libexec", "pyenv.vbs")
    result = subprocess.run(["cscript", "/nologo", pyenv_vbs, "vname"], capture_output=True, text=True)
    if result.returncode != 0:
        sys.stderr.write(result.stdout)
        sys.exit(result.returncode)

    versions = [ver.strip() for ver in result.stdout.splitlines()]

    python_shim = os.path.normcase(os.path.join(pyenv_root, "shims", "python.exe"))
    python_binaries = [os.path.normcase(os.path.join(pyenv_root, "versions", ver, "python.exe")) for ver in versions]
    python_in_path = shutil.which("python.exe")
    if python_in_path:
        python_in_path = os.path.normcase(python_in_path)
    if python_in_path and python_in_path not in [python_shim] + python_binaries:
        sys.stderr.write(f"Wrong {python_in_path} is in the PATH\n")
        sys.exit(1)

    exe = os.path.basename(sys.executable)
    for ver in versions:
        bin_dir = os.path.join(pyenv_root, "versions", ver)
        scripts_dir = os.path.join(bin_dir, "Scripts")

        for dir in [bin_dir, scripts_dir]:
            exe_path = os.path.join(dir, exe)
            os.environ["PATH"] = os.pathsep.join([bin_dir, scripts_dir, os.environ["PATH"]])

    result = subprocess.run([exe_path] + sys.argv[1:])
    sys.exit(result.returncode)

    sys.stderr.write(f"{exe} is not found")
    sys.exit(1)
