#!/bin/bash
#SBATCH --partition=YOUR_PARTITION
#SBATCH --nodelist=YOUR_NODE
#SBATCH --job-name=gnext_app
#SBATCH --mem=3GB
#SBATCH --output=shiny_app_%j.out
#SBATCH --error=shiny_app_%j.err

#!/bin/bash

source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate gnext-shiny
Rscript -e "shiny::runApp('.', host='0.0.0.0', port=3838)"
