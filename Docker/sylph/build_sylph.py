import argparse
import os
import tarfile
import shutil
import subprocess
import urllib.request

def main(args):

    if not os.path.exists(args.workdir):
        os.makedirs(args.workdir)
        print(f"Directory {args.workdir} created.")
    else:
        print(f"Directory {args.workdir} already exists.")

    get_db(args.workdir)
    create_dockerfile(args.workdir)
    build_dockerfile( args.workdir)

def build_dockerfile(workdir):
    # Build the Dockerfile
    command = f"docker build -t happykhan/slyph:0.1.0 {workdir}"
    print(f"Building Docker image with command: {command}")
    result = subprocess.run(command, shell=True, capture_output=True, text=True, check=True)
    print(result.stdout)
    # Push the Docker image to the repository
    command = "docker push happykhan/slyph:0.1.0"
    print(f"Pushing Docker image with command: {command}")
    # result = subprocess.run(command, shell=True, capture_output=True, text=True, check=True)
    # print(result.stdout)

def create_dockerfile(workdir):
    # Create a Dockerfile

    dockerfile = f"""FROM quay.io/biocontainers/sylph:0.8.0--ha6fb395_0
    RUN mkdir /opt/sylph
    COPY ./gtdb-r220-c1000-dbv1.syldb /opt/sylph
    WORKDIR /opt/sylph
    RUN chmod -R 777 /opt/sylph
    """
    with open(os.path.join(workdir, "Dockerfile"), "w", encoding="utf-8") as f:
        f.write(dockerfile)

def get_db(directory):

    url = "http://faust.compbio.cs.cmu.edu/sylph-stuff/gtdb-r220-c1000-dbv1.syldb"
    filename = os.path.join(directory, "gtdb-r220-c1000-dbv1.syldb")
    if not os.path.exists(filename):
        if not os.path.exists(directory):
            os.makedirs(directory)
            print(f"Directory {directory} created.")
        else:
            print(f"Directory {directory} already exists.")
        
        print(f"Downloading {url} to {filename}")
        urllib.request.urlretrieve(url, filename)
        print(f"Downloaded {filename}")

    

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Prepare databases for GHRU assembly.')
    parser.add_argument('--workdir', type=str, help='Directory workdir', default="Docker/sylph")
    args = parser.parse_args()    
    main(args)