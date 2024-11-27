# Compute-Canada
Documentation related to Compute Canada.

# Details
- **Username:** davidguz
- **Password:** same as the one from alliancecan.ca

To connect
```bash
ssh davidguz@narval.computecanada.ca
```
You can also replace `narval` for any of the other clusters available, like `cedar`.

## Lee Lab
Here are the instructions to setup your Compute Canada account for the LeeLab
- [Compute Canada tutorial - Google Doc](https://docs.google.com/document/d/1Py9W7RDYeuq5m7cnnpeXljHhsgSE9a1JXbQcPEY0nYk/edit?usp=sharing)
- [Compute Canada tutorial - video](https://drive.google.com/drive/folders/1tV4EV8taVD1LiERpXXQ1gDc6a-My-ikj)

## Hardware
Only Narval has A100 GPUs. If you want to run smaller experiments consider switching to other cluster.
- [Available GPUs](https://docs.alliancecan.ca/wiki/Using_GPUs_with_Slurm/en#Available_GPUs)

## VS Code
Use the `Remote Explorer` extension. If for some reason you can't connect anymore try deleting the `~/.vscode-server` folder in the server and connecting again.

### Optional terminal configuration
I like to use [oh-my-bash](https://github.com/ohmybash/oh-my-bash), is offers useful tools and information in the terminal for git, virtual environments, autocomplete and others. To install it
```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
```

# Environments
The easiest thing to do is to create an environment with `virtualenv` in the `path` of your project (I haven't tried Anaconda in Compute Canada if you prefer that option, but so far `virtualenv` works fine)
```bash
module load python/3.10.13

cd path/to/your/project
pip install virtualenv
virtualenv AfricanLLM-env
source AfricanLLM-env/bin/activate
```

## Packages
The usual `pip install` of some packages may cause some problems in Compute Canada, there are a few special packages in Compute Canada for this reason. For instance, instead of doing the usual
```bash
pip install torch==2.2.0+cu118
```
try 
```bash
pip install torch==2.2.0+computecanada
```
If you are having issues with a package try looking if there is a Compute Canada version of it, try 
```bash
pip install packagename==
``` 
this will throw an error that will give you all the versions available of the package, including the `+computecanada` versions.

# Jobs

## Test a script
I like to create a "sleeper" job and interact with the job, this is faster and allows to debug easily the Slurm script before submitting it
```bash
#!/bin/bash
#SBATCH --gpus-per-node=a100:1
#SBATCH --cpus-per-task=4
#SBATCH --mem=40G
#SBATCH --time=24:00:00
#SBATCH --account=def-annielee
#SBATCH --mail-type=ALL
#SBATCH --mail-user=david.guzman@mail.utoronto.ca
#SBATCH --output=sleeper_%j.out
#SBATCH --error=sleeper_%j.out

#############################################################
# install the environment by loading in python and required packages
module load python/3.10.13
module load gcc/12.3
module load cuda/12.2
module load arrow/17.0.0 

source AfricanLLM-env/bin/activate
#############################################################
# Redirect all output and errors from this point forward
exec > sleeper_${SLURM_JOB_ID}.out 2>&1

echo "Job Array ID / Job ID: $SLURM_ARRAY_JOB_ID / $SLURM_JOB_ID"

export HF_HOME=~/scratch/huggingface
echo $HF_HOME

sleep 1d
```

Then run `squeue -u $USER` to get the job ID and interact with the job, for instance:
```bash
# Run whatever command you want in the compute node with srun
srun --pty --jobid=22057719 nvidia-smi
srun --pty --jobid=22057719 python train.py
```
