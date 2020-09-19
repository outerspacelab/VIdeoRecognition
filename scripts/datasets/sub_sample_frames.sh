#!/bin/bash
# Usage: bash sub_sample_frames.sh /data/jingzhou/Projects/Datasets/ActionRecognition/gesture/rgb

echo "+ Subsample frames from $1"

DATA_PATH=$1
ROOT_PATH=${1%/*}
DATA_NAME=${1##*/}
SUB_PATH=$ROOT_PATH/$DATA_NAME"_sub"
FPV=7
INTERVAL=2
mkdir -p $SUB_PATH

NUM_SMAPLE_ALL=0
CLASS_COUNT=0
NUM_CLASS=$(ls $DATA_PATH |wc -l)
for CLASS in $(ls $DATA_PATH)
do 
  CLASS_PATH=$DATA_PATH/$CLASS
  SUB_CLASS_PATH=$SUB_PATH/$CLASS
  mkdir -p $SUB_CLASS_PATH

  echo "| [$CLASS_COUNT/$NUM_CLASS] Subsample $CLASS"
  NUM_CLASS_FRAMES=$(ls $CLASS_PATH |wc -l)
  FRAMES_COUNT=0
  for FRAMES in $(ls $CLASS_PATH)
  do
    
    echo "  | [$FRAMES_COUNT/$NUM_CLASS_FRAMES] Subsample $FRAMES"
    FRAMES_PATH=$CLASS_PATH/$FRAMES
    NUM_FRAMES=$(ls $FRAMES_PATH |wc -l)

    SUB_FRAMES_PATH=$SUB_CLASS_PATH/$FRAMES
    mkdir -p $SUB_FRAMES_PATH

     
    SAMPLE_FRAME_COUNT=0 
    for FRAME in $(ls $FRAMES_PATH)
    do
      FRAME_PATH=$FRAMES_PATH/$FRAME
      PREFIX=${FRAME_PATH##*.}
      FRAME_PATH=${FRAME_PATH%_*}
      INDEX=$((SAMPLE_FRAME_COUNT*INTERVAL+1))
      if [[ $INDEX -gt $NUM_FRAMES ]] || [[ $SAMPLE_FRAME_COUNT -ge $FPV  ]];then
        break
      fi

      INDEX=$(printf '%04d' $INDEX)"."$PREFIX
      SUB_FRAME_PATH=$FRAME_PATH"_"$INDEX
      #echo $SUB_FRAME_PATH
      #echo $SUB_FRAMES_PATH
      cp $SUB_FRAME_PATH $SUB_FRAMES_PATH
      let SAMPLE_FRAME_COUNT++
    done




    NUM_SMAPLE_ALL=$((NUM_SMAPLE_ALL+SAMPLE_FRAME_COUNT))
    let FRAMES_COUNT++
  done
  let CLASS_COUNT++
done
echo "| Total frames: $NUM_SMAPLE_ALL"
echo "- Finish"
