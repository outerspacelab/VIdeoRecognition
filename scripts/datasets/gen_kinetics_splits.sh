##!/bin/bash
## Usage: bash gen_kinetics_splits.sh ./label /data/jingzhou/Projects/Datasets/ActionRecognition/kinetics/rgb
DATA_PATH=$1
TRAIN_PATH=$1/train_256.csv
TEST_PATH=$1/val_256.csv
TRAIN_RGB_PATH=$2/train_256
TEST_RGB_PATH=$2/val_256

TRAIN_SPLIT=train_split1.txt
TEST_SPLIT=test_split1.txt
#
#CLASS_TXT=class.txt
#rm -f $TRAIN_SPLIT
#rm -f $TEST_SPLIT
##
#sort -t ','  -k 1,1 -u $TEST_PATH > $CLASS_TXT
#cat $CLASS_TXT | awk -F"[,]+" '{print $1}' > $CLASS_TXT.temp 
#sed -i -e '/label/d'  $CLASS_TXT.temp
#mv $CLASS_TXT.temp $CLASS_TXT
#sed -i 's/"//g'  $CLASS_TXT
#sed -i 's/ /_/g'  $CLASS_TXT
##
#cat $TEST_PATH | awk -F"[,]+" '{print $1}' > $TEST_SPLIT.1
#cat $TEST_PATH | awk -F"[,]+" '{print $2}' > $TEST_SPLIT.2
#paste $TEST_SPLIT.1 $TEST_SPLIT.2 -d "/" > $TEST_SPLIT
#rm -rf $TEST_SPLIT.*
#sed -i -e '/label/d'  $TEST_SPLIT
#sed -i 's/$/&.mp4/g' $TEST_SPLIT
#sed -i 's/^/val_256\/&/g' $TEST_SPLIT
#sed -i 's/"//g'  $TEST_SPLIT
#sed -i 's/ /_/g'  $TEST_SPLIT
#
##
#rm -rf $TEST_SPLIT.temp
#while read line
#do
#  #echo $line
#  contents=(${line//// })
#  class_name=${contents[1]}
#  video_name=${contents[2]}
#  video_name=${video_name%%.*}
#  count=0
#  while read line_class 
#  do 
#    if [[ $line_class ==  $class_name  ]];then
#      RGB_FRAMES_PATH=$TEST_RGB_PATH/$class_name/$video_name
#      NUM_FRAMES=$(ls $RGB_FRAMES_PATH|wc -l)
#      echo "$line $NUM_FRAMES $count" >> $TEST_SPLIT.temp
#      break
#    fi
#    let count++
#  done < $CLASS_TXT
#done  <  $TEST_SPLIT
#mv  $TEST_SPLIT.temp $TEST_SPLIT
##
#cat $TRAIN_PATH | awk -F"[,]+" '{print $1}' > $TRAIN_SPLIT.1
#cat $TRAIN_PATH | awk -F"[,]+" '{print $2}' > $TRAIN_SPLIT.2
#paste $TRAIN_SPLIT.1 $TRAIN_SPLIT.2 -d "/" > $TRAIN_SPLIT
#rm -rf $TRAIN_SPLIT.*
#sed -i -e '/label/d'  $TRAIN_SPLIT
#sed -i 's/$/&.mp4/g' $TRAIN_SPLIT
#sed -i 's/^/train_256\/&/g' $TRAIN_SPLIT
#sed -i 's/"//g'  $TRAIN_SPLIT
#sed -i 's/ /_/g'  $TRAIN_SPLIT
#
##
#rm -rf $TRAIN_SPLIT.temp
#while read line
#do
#  #echo $line
#  contents=(${line//// })
#  class_name=${contents[1]}
#  video_name=${contents[2]}
#  video_name=${video_name%%.*}
#  count=0
#  while read line_class 
#  do 
#    if [[ $line_class ==  $class_name  ]];then
#      RGB_FRAMES_PATH=$TRAIN_RGB_PATH/$class_name/$video_name
#      NUM_FRAMES=$(ls $RGB_FRAMES_PATH|wc -l)
#      echo "$line $NUM_FRAMES $count" >> $TRAIN_SPLIT.temp
#      break
#    fi
#    let count++
#  done < $CLASS_TXT
#done  <  $TRAIN_SPLIT
#mv  $TRAIN_SPLIT.temp $TRAIN_SPLIT
##
#rm $CLASS_TXT
#cp $TRAIN_SPLIT $TRAIN_SPLIT.copy
#cp $TEST_SPLIT $TEST_SPLIT.copy
# clean data
cp $TRAIN_SPLIT.copy $TRAIN_SPLIT
cp $TEST_SPLIT.copy $TEST_SPLIT

SPLIT_NUMBER=40
for i in `seq 0 $SPLIT_NUMBER`
do
    sed -i "/.mp4 $i /d"  $TRAIN_SPLIT
    sed -i "/.mp4 $i /d"  $TEST_SPLIT
done







