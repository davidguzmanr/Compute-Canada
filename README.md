# Compute-Canada
Documentation related to Compute Canada.

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
virtualenv AfrincanLLM-env
source AfrincanLLM-env/bin/activate
```

# Notes
- They changed the usual `module load` from Slurm to `module spider`
