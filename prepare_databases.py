import argparse
import os
import tarfile
import shutil

def main(args):

    if not os.path.exists(args.directory):
        os.makedirs(args.directory)
        print(f"Directory {args.directory} created.")
    else:
        print(f"Directory {args.directory} already exists.")

    prepare_databases(args.directory)

def prepare_databases(output_dir):
    # Download rMLST database for confindr
    import urllib.request

    url = "https://quadram-bioinfo-rlmst.s3.climb.ac.uk/confindr_db_2024_2_12.tar.gz"
    output_path = os.path.join(output_dir, "confindr_db.tar.gz")
    extract_path = os.path.join(output_dir)

    # Download the file
    with urllib.request.urlopen(url) as response, open(output_path, 'wb') as out_file:
        out_file.write(response.read())

    # Create the directory if it doesn't exist
    os.makedirs(extract_path, exist_ok=True)

    # Extract the tar.gz file
    with tarfile.open(output_path, "r:gz") as tar:
        tar.extractall(path=extract_path)

    # Remove the downloaded tar.gz file
    os.remove(output_path)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Prepare databases for GHRU assembly.')
    parser.add_argument('--directory', type=str, help='Directory to store databases', default="assembly_databases")
    args = parser.parse_args()    
    main(args)