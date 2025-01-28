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
    final_path = os.path.join(output_dir, "confindr_db")
    extract_path = os.path.join(output_dir)
    if not os.path.exists(final_path):
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

    # Download and extract http://faust.compbio.cs.cmu.edu/sylph-stuff/gtdb-r220-c1000-dbv1.syldb 
    url = "http://faust.compbio.cs.cmu.edu/sylph-stuff/gtdb-r220-c1000-dbv1.syldb"
    output_path = os.path.join(output_dir, "gtdb-r220-c1000-dbv1.syldb")
    if not os.path.exists(output_path) or os.path.getsize(output_path) < 1 * 1024 * 1024 * 1024:
        # Download the file using wget
        os.system(f"wget -O {output_path} {url}")



if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Prepare databases for GHRU assembly.')
    parser.add_argument('--directory', type=str, help='Directory to store databases', default="assembly_databases")
    args = parser.parse_args()    
    main(args)