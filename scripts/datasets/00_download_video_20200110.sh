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
getInfo(){
  LINE=(${LINE// / })
  VIDEO=${LINE[0]}
  #echo $((${#LINE[*]}-1)) ${#LINE[*]} 
  for i in $(seq 0 $((${#LINE[*]}-1)))
  do
    case ${LINE[$i]} in
      http*)
        URL=${LINE[$i]}
      ;;
      *segment_range*)
        START_TIME=${LINE[$i]##*[}
        START_TIME=${START_TIME%\"}
      ;;
      *.*"]""}")
        END_TIME=${LINE[$i]%]*}
      ;;
      *抓取*)
        CLASS="grab"
      ;;
      *招手*)
        CLASS="wave" 
      ;;
      *捏合*)
        CLASS="pinch"
      ;;
      *再见*)
        CLASS="byebye"
      ;;
      *画叉*)
        CLASS="cross"
      ;;
      *对勾*)
        CLASS="checkmark"
      ;;
      *画圆*)
        CLASS="drawcircle"
      ;;
    esac  
  done
  if [[ $URL == "" ]] || [[ $CLASS == "" ]] || \
     [[ $START_TIME == "" ]] || [[ $END_TIME == "" ]];then
     echo "- error happen"
     exit -1
  fi

}





# Read
COUNT=0
NUM_TOTAL=$(sed -n '$=' $SOURCE_TXT.temp)
NUM_VALID=0
while read LINE
do
  if [[ $LINE == *invalid* ]];then
    if [[ $LINE == *false* ]];then
      getInfo "video" "url" "class" "start" "end"
      echo "| [$COUNT/$NUM_TOTAL] Download $VIDEO, $CLASS, $URL, [$START_TIME, $END_TIME]"
      mkdir -p $VIDEO_PATH/$CLASS
      if [[ ! -f $VIDEO_PATH/$CLASS/"$VIDEO"_"$START_TIME"_"$END_TIME".mp4 ]];then
        wget -P $VIDEO_PATH/$CLASS $URL -O $VIDEO_PATH/$CLASS/"$VIDEO"_"$START_TIME"_"$END_TIME".mp4  
      else  
        echo "| exist"  
      fi
      let NUM_VALID++
    fi
  fi
  let COUNT++
done < $SOURCE_TXT.temp
rm $SOURCE_TXT.temp
echo "| [$NUM_VALID/$NUM_TOTAL] (valid/total)"
echo "- Finish"
