#/bin/bash
# Usage: bash 04_reindex_frames.sh /data/jingzhou/Projects/Datasets/ActionRecognition/checkmark_clean

CLASS_PATH=$1
echo "+ Reindex $CLASS_PATH"

if [[ ! -d $CLASS_PATH"_copy" ]];then
  echo "| copy $CLASS_PATH to $CLASS_PATH"_copy""
  cp -r $CLASS_PATH $CLASS_PATH"_copy"
fi

NUM_FRAMES=$(ls $CLASS_PATH |wc -l)
COUNT=0
for i in $(ls $CLASS_PATH)
do
  echo "| [$COUNT/$NUM_FRAMES]" 
  FRAMES_PATH=$CLASS_PATH/$i
  NUM_FRAME=$(ls $FRAMES_PATH |wc -l)
  COUNT_FRAME=0
  for j in $(ls $FRAMES_PATH)
  do
    FRAME_PATH=$FRAMES_PATH/$j
    FRAME_RENAME_PATH=$FRAMES_PATH/"image_"$(printf "%04d" $((COUNT_FRAME+1)))"."${j##*.}
    if [[ ! $FRAME_PATH == $FRAME_RENAME_PATH ]];then
      mv $FRAME_PATH $FRAME_RENAME_PATH
    else
      echo " | No need for rename"
    fi
    let COUNT_FRAME++
  done
  let COUNT++
done


