import subprocess

def install(package):
    try:
        subprocess.check_call(["pip", "install", package])
    except subprocess.CalledProcessError:
        print(f"Failed to install {package}, skipping...")

with open("/home/scripts/requirements.txt", "r") as file:
    install('tensorflow')
    for line in file:
        package = line.strip()
        if package:
            install(package)