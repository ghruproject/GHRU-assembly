import argparse
import os
import subprocess

def main(args):

    if not os.path.exists(args.workdir):
        os.makedirs(args.workdir)
        print(f"Directory {args.workdir} created.")
    else:
        print(f"Directory {args.workdir} already exists.")

    create_dockerfile(args.workdir)
    build_dockerfile( args.workdir)

def build_dockerfile(workdir):
    # Build the Dockerfile
    command = f"docker build -t happykhan/checkm2:0.1.0 {workdir}"
    print(f"Building Docker image with command: {command}")
    result = subprocess.run(command, shell=True, capture_output=True, text=True, check=True)
    print(result.stdout)
    # Tag the Docker image
    tag_command = "docker tag happykhan/checkm2:0.1.0 happykhan/checkm2:0.1.0"
    print(f"Tagging Docker image with command: {tag_command}")
    result = subprocess.run(tag_command, shell=True, capture_output=True, text=True, check=True)
    print(result.stdout)
    # Push the Docker image to the repository
    command = "docker push happykhan/checkm2:0.1.0"
    print(f"Pushing Docker image with command: {command}")
    result = subprocess.run(command, shell=True, capture_output=True, text=True, check=True)
    # print(result.stdout)

def create_dockerfile(workdir):
    # Create a Dockerfile

    dockerfile = f"""FROM quay.io/biocontainers/checkm2:1.1.0--pyh7e72e81_1
    RUN mkdir /opt/checkm_data
    COPY ./uniref100.KO.1.dmnd /opt/checkm_data/
    ENV CHECKM2DB=/opt/checkm_data/uniref100.KO.1.dmnd
    """
    with open(os.path.join(workdir, "Dockerfile"), "w", encoding="utf-8") as f:
        f.write(dockerfile)

    

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Prepare databases for GHRU assembly.')
    parser.add_argument('--workdir', type=str, help='Directory workdir', default="Docker/checkm2")
    args = parser.parse_args()    
    main(args)