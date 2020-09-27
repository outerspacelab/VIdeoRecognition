#!/bin/bash

# Network
NETWORK=TemporallyGenerativeClueNet

# Mode
MODE=test

# Backbone
CONV_NET=resnet18
INPUT_SIZE=224

# Dataset
DATASET_ROOT_DIR=/home/young/Data/Projects/Datasets/Reasearch/Action
DATASET=ucf101
DATASET_TYPE=rgb
SPLIT=1
NUM_CLIPS=2
NUM_FRAMES=16

# Preprocess
#PREPROCESS=RandomCrop,RandomHorizontalFlip

# Test
GPUS=0
BATCH_SIZE=1
EPOCHES=1
TRAIN_DIR=/home/young/Data/Projects/Models/"$NETWORK"_"backbone$CONV_NET"_\
"inputSize$INPUT_SIZE"_"dataset$DATASET"_"datasetType$DATASET_TYPE"_"split$SPLIT"_\
numclips1_numframes8_gpus0,1_batchSize8_lr0.000125_epoches2


# Run
python backends/pytorch/main.py \
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
