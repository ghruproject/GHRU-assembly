import os
import re
import subprocess
import argparse

def build_singularity_containers(config_file_path, image_dir, pipeline_name):
    sing_dir = os.path.join(image_dir, pipeline_name)
    # os.makedirs(sing_dir, exist_ok=True)
    container_mentions = []

    with open(config_file_path, 'r') as config_file:
        for line in config_file:
            matches = re.search(r"container = '(\w+\/\w+:\w+)'", line)
            if matches:
                container_mentions.append(matches.group(1))

    for mention in container_mentions:
        image_name = mention.split('/')[-1].replace(':', '_')
        image_file = os.path.join(sing_dir, image_name)
        command = f'singularity pull {image_file}.sif docker://{mention}'
        print(command)
        subprocess.run(command, shell=True)
        print('Please update nextflow.config with the following line:')
        print(f"container = '{image_file}.sif'")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Build Singularity containers from config file')
    parser.add_argument('-c', '--config_file', type=str, help='Path to the config file', default='nextflow.config')
    parser.add_argument('-i', '--image_dir', type=str, help='Path to the directory to store the Singularity images', default='/well/aanensen/shared/singularity/')
    parser.add_argument('-p', '--pipeline_name', type=str, help='Pipeline name', default='nf-phylotyping')

    args = parser.parse_args()

    build_singularity_containers(args.config_file, args.image_dir, args.pipeline_name)
