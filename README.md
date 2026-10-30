# Compute-Canada
Documentation related to Compute Canada.

# Details
- **Username:** same as the one from [alliancecan.ca](https://ccdb.alliancecan.ca/security/login)
- **Password:** same as the one from [alliancecan.ca](https://ccdb.alliancecan.ca/security/login)

To setup everything the easiest is to do it via [milatools](https://github.com/mila-iqia/milatools), start with 
```
mila init
```
to use your account from [alliancecan.ca](https://ccdb.alliancecan.ca/security/login). Then try

```bash
ssh -vv tamia
```

## Hardware
- [Available GPUs](https://docs.alliancecan.ca/wiki/Using_GPUs_with_Slurm/en#Available_GPUs)

## VS Code
Use the `Remote Explorer` extension. If for some reason you can't connect anymore try deleting the `~/.vscode-server` folder in the server and connecting again.

### Optional terminal configuration
I like to use [oh-my-bash](https://github.com/ohmybash/oh-my-bash), is offers useful tools and information in the terminal for git, virtual environments, autocomplete and others. To install it
```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
```

# Environments
### Virtualenv
The easiest thing to do is to create an environment with `virtualenv` in the `path` of your project
```bash
module load python/3.10.13
module load gcc/12.3
module load arrow/17.0.0 

cd path/to/your/project
pip install virtualenv
virtualenv AfricanLLM-env
source AfricanLLM-env/bin/activate
```

### Conda
> **Note:** Conda environments may cause issues with some of the libraries and modules from DRAC. Prefer `virtualenv` unless you specifically need to install something from conda.

Alternatively, you can use Miniconda
```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
source ~/miniconda3/bin/activate
conda create -n F5-TTS python=3.10 -y
```

Load the modules before activating the virtual environment, otherwise you might get this
```
IMPORTANT: the module must be loaded before activating your virtual environment.
      
1. Deactivate your virtual environment : deactivate
2. Load the Arrow module : module load gcc arrow/x.y.z
3. Activate your virtual env. : source <env>/bin/activate
4. And re-run your pip install command.
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

## Hugging Face
GPU nodes usually don't have network access, download the models/datasets first in the landing nodes. Also, landing nodes have a limit in the storage, models need to be stored somewhere in `~/scratch`, change this with (only for the session, you can change permanently this in your `.bashrc` file)
```bash
export HF_HOME=~/scratch/huggingface
```

# Slurm

## Interactive jobs
You can use `milatools` as well
```
mila code . --command code --cluster=tamia --alloc --gres=gpu:h100:4 --mem=256G --cpus-per-task=16 --time=4:00:00
```
If you have a job already running you can connect directly via its `jobid` (run `squeue -u $USER`)
```
mila code . --command code --cluster=tamia --job <jobid>
```
You can also interact with it like this in the login node
```bash
# Run whatever command you want in the compute node with srun
srun --pty --jobid=<jobid> nvidia-smi
srun --pty --jobid=<jobid> python train.py
```
