# Compute-Canada
Documentation related to Compute Canada.

# Details
- **Username:** davidguz
- **Password:** same as the one from alliancecan.ca

To connect
```bash
ssh davidguz@cedar.computecanada.ca
```
You can also replace `cedar` for any of the other clusters available, like `beluga`.

## VS Code
Use the `Remote Explorer` extension. If for some reason you can't connect anymore try deleting the `~/.vscode-server` folder and connecting again.

# Lee Lab
- [Compute Canada tutorial - Google Doc](https://docs.google.com/document/d/1Py9W7RDYeuq5m7cnnpeXljHhsgSE9a1JXbQcPEY0nYk/edit?usp=sharing)

# Hardware
- [Available GPUs](https://docs.alliancecan.ca/wiki/Using_GPUs_with_Slurm/en#Available_GPUs)

# Environments
The easiest thing to do is to create an environment with `virtualenv` in the `path` of your project
```bash
module load python/3.10.13

cd path/to/your/project
pip install virtualenv
virtualenv AfricanLLM-env
source AfricanLLM-env/bin/activate
```

# Jobs

## Test a script
I like to create a "sleeper" job and interact with the job, this is faster and allows to debug easily the Slurm script before submitting it
```bash
#!/bin/bash
#SBATCH --gpus-per-node=v100l:1
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --account=def-annielee

#############################################################
# install the environment by loading in python and required packages
module load python/3.10.13
module load gcc/12.3
module load cuda/12.2
module load arrow/17.0.0 

source AfrincanLLM-env/bin/activate
#############################################################

echo "Job Array ID / Job ID: $SLURM_ARRAY_JOB_ID / $SLURM_JOB_ID"
sleep 86400
```

Then run `squeue -u $USER` to get the job ID and interact with the job
```
srun --pty --jobid=22057719 nvidia-smi
```

# Notes
- They changed the usual `module load` from Slurm to `module spider`
