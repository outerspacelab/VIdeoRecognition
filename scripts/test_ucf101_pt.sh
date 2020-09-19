#!/bin/bash

# Network
NETWORK=TemporallyBalancedGenerativeNet

# Mode
MODE=test

# Backbone
CONV_NET=resnet18
INPUT_SIZE=224

# Dataset
DATASET_ROOT_DIR=/home/young/Data/Projects/Datasets
DATASET=ucf101
DATASET_TYPE=rgb
SPLIT=1
NUM_CLIPS=2
NUM_FRAMES=16

# Preprocess
#PREPROCESS=RandomCrop,RandomHorizontalFlip

# Train
GPUS=0
BATCH_SIZE=1
EPOCHES=1
TRAIN_DIR=/home/young/Data/Projects/Models/"$NETWORK"_"Backbone$CONV_NET"_\
"InputSize$INPUT_SIZE"_"Dataset$DATASET"_"DatasetType$DATASET_TYPE"_"Split$SPLIT"_\
"NumClips$NUM_CLIPS"_"Numframes$NUM_FRAMES"_"GPUS$GPUS"_"BatchSize$BATCH_SIZE"_"Lr$LR"_\
"Epoches$EPOCHES"

# Run
python main.py \
        --mode=$MODE \
        --input_size=$INPUT_SIZE \
        --dataset_root_dir=$DATASET_ROOT_DIR \
        --dataset=$DATASET \
        --dataset_type=$DATASET_TYPE \
        --split=$SPLIT \
        --num_clips=$NUM_CLIPS \
        --num_frames=$NUM_FRAMES \
        --gpus=$GPUS \
        --batch_size=$BATCH_SIZE \
        --epoches=$EPOCHES \
        --train_dir=$TRAIN_DIR \
        --temporal_stride=1 \
