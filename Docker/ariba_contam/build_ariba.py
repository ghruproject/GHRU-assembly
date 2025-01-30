import argparse
import os
import tarfile
import shutil
import subprocess
import urllib.request

def main(args):

    if not os.path.exists(args.directory):
        os.makedirs(args.directory)
        print(f"Directory {args.directory} created.")
    else:
        print(f"Directory {args.directory} already exists.")

    get_mlst(args.directory)
    create_dockerfile(args.directory, args.workdir)
    build_dockerfile( args.workdir)

def build_dockerfile(workdir):
    # Build the Dockerfile
    command = f"docker build -t happykhan/ariba_contam:0.1.0 {workdir}"
    print(f"Building Docker image with command: {command}")
    result = subprocess.run(command, shell=True, capture_output=True, text=True, check=True)
    print(result.stdout)
    # Push the Docker image to the repository
    command = "docker push happykhan/ariba_contam:0.1.0"
    print(f"Pushing Docker image with command: {command}")
    # result = subprocess.run(command, shell=True, capture_output=True, text=True, check=True)
    # print(result.stdout)

def create_dockerfile(directory, workdir):
    # Create a Dockerfile

    dockerfile = f"""FROM quay.io/biocontainers/ariba:2.14.6--py38h40d3509_6
    RUN mkdir /opt/ariba
    RUN mkdir /opt/ariba/mlst_db
    COPY ./ariba_mlst/ /opt/ariba/mlst_db
    WORKDIR /opt/ariba
    COPY ./run_ariba.py /opt/ariba/run_ariba.py
    RUN chmod -R 777 /opt/ariba
    """
    with open(os.path.join(workdir, "Dockerfile"), "w", encoding="utf-8") as f:
        f.write(dockerfile)

def get_mlst(directory):

    command = "docker run quay.io/biocontainers/ariba:2.14.6--py38h40d3509_6 ariba pubmlstspecies"
    result = subprocess.run(command, shell=True, capture_output=True, text=True, check=True)
    output_list = result.stdout.splitlines()

    # Create a dictionary to store the first mention of each genus-species
    species_dict = {}

    # Iterate through the list
    for species in output_list:
        # Remove any "#" and trailing characters to get the base name
        base_name = species.split('#')[0]
        
        # If the base name is not already in the dictionary, add it with the current species as the value
        if base_name not in species_dict:
            species_dict[base_name] = species
    for species, db_name in species_dict.items():
        # Download the database
        ab_path = os.path.abspath(directory)
        safe_species = species.replace(" ", "_")
        safe_species = safe_species.replace("/", "_")
        safe_species = safe_species.replace(".", "")        
        final_path = os.path.join(ab_path, safe_species)
        if not os.path.exists(final_path):
            print(f"Downloading {species} database to {directory}")
            command = f"docker run -v {ab_path}:/data quay.io/biocontainers/ariba:2.14.6--py38h40d3509_6 ariba pubmlstget '{db_name}' /data/{safe_species}"
            result = subprocess.run(command, shell=True, capture_output=True, text=True)
    

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Prepare databases for GHRU assembly.')
    parser.add_argument('--directory', type=str, help='Directory to store databases', default="Docker/ariba_contam/ariba_mlst")
    parser.add_argument('--workdir', type=str, help='Directory workdir', default="Docker/ariba_contam")
    args = parser.parse_args()    
    main(args)