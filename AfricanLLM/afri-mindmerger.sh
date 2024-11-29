#!/bin/bash
#SBATCH --gpus-per-node=a100:1
#SBATCH --mem=40G
#SBATCH --cpus-per-task=4
#SBATCH --time=96:00:00
#SBATCH --account=def-annielee
#SBATCH --mail-type=ALL
#SBATCH --mail-user=david.guzman@mail.utoronto.ca
#SBATCH --output=afri-mindmerger-pipeline.out
#SBATCH --error=afri-mindmerger-pipeline.out

#############################################################
# install the environment by loading in python and required packages
module load python/3.10.13
module load gcc/12.3
module load cuda/12.2
module load arrow/17.0.0 

source AfricanLLM-env/bin/activate
#############################################################

# Redirect all output and errors from this point forward
exec > afri-mindmerger-pipeline.out 2>&1

echo "Job Array ID / Job ID: $SLURM_ARRAY_JOB_ID / $SLURM_JOB_ID"

export HF_HOME=~/scratch/huggingface
echo $HF_HOME

cd MindMerger-AfricanLLM

echo "mapping stage"
## deepspeed run_training_afri.py --deepspeed --llm_path  meta-math/MetaMath-Mistral-7B --mt_path castorini/afriteva_v2_large --stage_name mapping --task math --augmentation False --save_name AfriMindMerger --train_num 9000 --train_batch_size 4 --train_micro_batch_size_per_gpu 4 --epoch_num 1 --max_seq_len 200 --max_gen_len 200 --eval_batch_size 4

echo "augmentation stage"
deepspeed run_training_afri.py --deepspeed --llm_path  meta-math/MetaMath-Mistral-7B --mt_path castorini/afriteva_v2_large --stage_name augmentation --task math --augmentation True --save_name AfriMindMerger  --train_num 3000 --train_batch_size 1 --train_micro_batch_size_per_gpu 1 --epoch_num 1 --max_seq_len 512 --max_gen_len 512 --eval_batch_size 1

echo "evaluation stage"
deepspeed run_evaluation.py --deepspeed --task afrimgsm --llm_path meta-math/MetaMath-Mistral-7B --mt_path castorini/afriteva_v2_large --augmentation True     --eval_batch_size 4 --init_checkpoint outputs/AfriMindMerger/math/augmentation/pytorch_model.bin --save_name AfriMindMerger
