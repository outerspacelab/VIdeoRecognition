#!/bin/bash
# Usage: bash 00_download_video.sh /data/jingzhou/Projects/Datasets/ActionRecognition/gesture/info/20191204.txt
# xxx.txt is converted into UTF-16 UnicodeText(.txt) from xlsx

SOURCE_TXT=$1
echo "+ 00 Download Video from $SOURCE_TXT"

ROOT_PATH=${SOURCE_TXT%/*}
ROOT_PATH=${ROOT_PATH%/*}
VIDEO_PATH=$ROOT_PATH/video

# Preprocess
iconv -f UTF-16 -t UTF-8 $SOURCE_TXT > $SOURCE_TXT.temp
sed -i 's///g' $SOURCE_TXT.temp
sed -i 's/""/"/g' $SOURCE_TXT.temp
sed -i 's/"{/{/g' $SOURCE_TXT.temp
sed -i 's/}"/}/g' $SOURCE_TXT.temp 

#
getClass(){
 if [[ $CLASS == *抓取*  ]];then
   CLASS="grab"
 elif [[ $CLASS == *招手* ]];then
   CLASS="wave"
 elif [[ $CLASS == *捏合* ]];then  
   CLASS="pinch"
 elif [[ $CLASS == *再见* ]];then
   CLASS="byebye"
 elif [[ $CLASS == *画叉* ]];then
   CLASS="cross"
 elif [[ $CLASS == *对勾* ]];then
   CLASS="checkmark"
 elif [[ $CLASS == *画圆* ]];then
   CLASS="drawcircle"
 fi
}

# Read
COUNT=0
NUM_TOTAL=$(sed -n '$=' $SOURCE_TXT.temp)
while read LINE
do
  LINE=(${LINE// / })
  if [[ ${LINE[24]} == *false* ]];then
    CLASS=${LINE[2]}
    getClass $CLASS
    VIDEO=${LINE[0]}
    URL=${LINE[7]}
    START_TIME=${LINE[16]##*[}
    START_TIME=${START_TIME%\"}
    END_TIME=${LINE[17]%]*}
    echo "| [$COUNT/$NUM_TOTAL] Download $VIDEO, $CLASS, $URL, [$START_TIME, $END_TIME]"
    mkdir -p $VIDEO_PATH/$CLASS
    if [[ ! -f $VIDEO_PATH/$CLASS/"$VIDEO"_"$START_TIME"_"$END_TIME".mp4 ]];then
      wget -P $VIDEO_PATH/$CLASS $URL -O $VIDEO_PATH/$CLASS/"$VIDEO"_"$START_TIME"_"$END_TIME".mp4  
    fi
    let COUNT++
  fi
done < $SOURCE_TXT.temp
rm $SOURCE_TXT.temp
echo "| Total $COUNT"
echo "- Finish"
