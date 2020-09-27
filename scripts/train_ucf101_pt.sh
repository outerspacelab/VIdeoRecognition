#!/bin/bash

# Network
NETWORK=TemporallyGenerativeClueNet

# Mode
MODE=train

# Backbone
CONV_NET=resnet18
INPUT_SIZE=224

# Dataset
DATASET_ROOT_DIR=/home/young/Data/Projects/Datasets/Reasearch/Action
DATASET=ucf101
DATASET_TYPE=rgb
SPLIT=1
NUM_CLIPS=1
NUM_FRAMES=8

# Preprocess
PREPROCESS=RandomCrop,RandomHorizontalFlip

# Train
GPUS=0,1
BATCH_SIZE=8
LR=0.000125
EPOCHES=2
TRAIN_DIR=/home/young/Data/Projects/Models/"$NETWORK"_"backbone$CONV_NET"_\
"inputSize$INPUT_SIZE"_"dataset$DATASET"_"datasetType$DATASET_TYPE"_"split$SPLIT"_\
"numclips$NUM_CLIPS"_"numframes$NUM_FRAMES"_"gpus$GPUS"_"batchSize$BATCH_SIZE"_"lr$LR"_\
"epoches$EPOCHES"

# Retrain
#rm -r $TRAIN_DIR

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
        --preprocess=$PREPROCESS \
        --gpus=$GPUS \
        --batch_size=$BATCH_SIZE \
        --lr=$LR \
        --epoches=$EPOCHES \
        --train_dir=$TRAIN_DIR \
        --temporal_stride=1 \
        --log_steps=100 \
        --save_epoches=0.1
