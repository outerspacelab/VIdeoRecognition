##!/bin/bash
## Usage: bash 03_gen_custom_gesture_splits.sh /data/jingzhou/Projects/Datasets/ActionRecognition/gesture/rgb

echo "+ Generate custom gesture splits"
ALL_RGB_PATH=$1



ROOT_PATH=${ALL_RGB_PATH%/*}
ALL_SPLIT=$ROOT_PATH/info/all.txt
TRAIN_SPLIT=$ROOT_PATH/info/train_split1.txt
TEST_SPLIT=$ROOT_PATH/info/test_split1.txt
rm -f $ALL_SPLIT
rm -f $TRAIN_SPLIT
rm -f $TEST_SPLIT

#CLASS_TXT=class.txt

CLASS_INDEX=0
MIN_NUM_FRAMES=999
MAX_NUM_FRAMES=0
for CLASS in $(ls $ALL_RGB_PATH)
do
  CLASS_PATH=$ALL_RGB_PATH/$CLASS
  echo "| Process $CLASS_PATH"
  NUM_ITERM=$(ls $CLASS_PATH |wc -l)
  #echo $NUM_ITERM
  COUNT=0
  for ITERM in $(ls $CLASS_PATH)
  do
    ITERM_PATH=$CLASS_PATH/$ITERM
    NUM_ITERM_IMAGES=$(ls $ITERM_PATH |wc -l)
    if [[ $MIN_NUM_FRAMES -gt $NUM_ITERM_IMAGES ]] && [[ ! $NUM_ITERM_IMAGES == 0 ]];then
      MIN_NUM_FRAMES=$NUM_ITERM_IMAGES 
      MIN_PATH=$ITERM_PATH
    fi
    if [[ $MAX_NUM_FRAMES -lt $NUM_ITERM_IMAGES ]];then
      MAX_NUM_FRAMES=$NUM_ITERM_IMAGES 
      MAX_PATH=$ITERM_PATH
    fi
    echo "$CLASS/$ITERM.mp4 $NUM_ITERM_IMAGES $CLASS_INDEX" >> $ALL_SPLIT
   

    #echo "  | [$COUNT/$NUM_ITERM], $NUM_ITERM_IMAGES"
    let COUNT++
    #echo "  | Read $ITERM_PATH"
  done
  let CLASS_INDEX++
done

sed -i '/.mp4 0/d' $ALL_SPLIT
shuf $ALL_SPLIT -o  $ALL_SPLIT.temp
NUM_ITERMS=$(sed -n '$=' $ALL_SPLIT.temp)
NUM_TRAIN=$((NUM_ITERMS*9/10))
sed -n "1,"$NUM_TRAIN"p" $ALL_SPLIT.temp > $TRAIN_SPLIT
sed -n ""$((NUM_TRAIN+1))","$NUM_ITERMS"p" $ALL_SPLIT.temp > $TEST_SPLIT
rm $ALL_SPLIT.temp
#
echo "| $MIN_PATH, $MIN_NUM_FRAMES"
echo "| $MAX_PATH, $MAX_NUM_FRAMES"
echo "- Finish"
