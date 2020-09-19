#/bin/bash
# Usage: bash 01_gen_frames.sh ./video/train_256 ./rgb/train_256 25 
# bash 01_gen_frames.sh /data/jingzhou/Projects/Datasets/ActionRecognition/gesture/video /data/jingzhou/Projects/Datasets/ActionRecognition/gesture/rgb 25 "_"
VIDEOS_PATH=$1
FRAMES_PATH=$2
FPS=$3
PREFIX=$4

echo "+ Extract frames from $VIDEOS_PATH to $FRAMES_PATH"

CLASSES=$(ls $VIDEOS_PATH)
NUM_CLASSES=$(ls $VIDEOS_PATH|wc -l)
COUNT_CLASS=0
for class in $CLASSES
do
  CLASS_PATH=$VIDEOS_PATH/$class
  VIDEOS=$(ls $CLASS_PATH)
  NUM_VIDEOS=$(ls $CLASS_PATH|wc -l)
  VIDEO_COUNT=0
  echo "| [$COUNT_CLASS/$NUM_CLASSES] Process $CLASS_PATH"
  for video in $VIDEOS
  do
    VIDEO_PATH=$CLASS_PATH/$video
    VIDEO_NAME=${video##*/}
    VIDEO_FRAME_PATH=$FRAMES_PATH/$class/${VIDEO_NAME%%$PREFIX*}
    TIME=${VIDEO_NAME#*$PREFIX}
    TIME=${TIME%.*}
    START_TIME=${TIME%$PREFIX*}
    END_TIME=${TIME#*$PREFIX}
    END_TIME=$(echo "$END_TIME-0.7"|bc)



    if [[ ! -d $VIDEO_FRAME_PATH ]];then
      mkdir -p $VIDEO_FRAME_PATH
      echo "  | [$VIDEO_COUNT/$NUM_VIDEOS] Extract frames from $VIDEO_PATH to $VIDEO_FRAME_PATH"
      if [[ $PREFIX == "." ]];then
        ffmpeg  -i $VIDEO_PATH -vf fps=$FPS $VIDEO_FRAME_PATH/image_%4d.jpg
      else
        ffmpeg -ss $START_TIME -i $VIDEO_PATH -to $END_TIME -vf fps=$FPS $VIDEO_FRAME_PATH/image_%4d.jpg
      fi
      if [[ $(ls $VIDEO_FRAME_PATH |wc -l) == 0 ]];then
        echo "  | $VIDEO_FRAME_PATH is empty"
        rm -r $VIDEO_FRAME_PATH
      fi
    elif [[ $(ls $VIDEO_FRAME_PATH |wc -l) == 0 ]];then 
      echo "  | $VIDEO_FRAME_PATH is empty"
      rm -r $VIDEO_FRAME_PATH
    else
      echo "  | $VIDEO_FRAME_PATH exist"
    fi 
    
    #BACKGROUND_PATH=$FRAMES_PATH/background/${VIDEO_NAME%%$PREFIX*}
    #if [[ ! $PREFIX == "" ]] && [[ ! -d $BACKGROUND_PATH ]];then
    #  mkdir -p $BACKGROUND_PATH
    #  END_TIME=$(echo "$END_TIME+2.0"|bc)
    #  END_END_TIME=$(echo "$END_TIME+2.0"|bc)
    #  echo $END_TIME $END_END_TIME
    #  ffmpeg -ss $END_TIME -i $VIDEO_PATH -to $END_END_TIME -vf fps=$FPS $BACKGROUND_PATH/image_%4d.jpg
    #  if [[ $(ls $BACKGROUND_PATH |wc -l) == 0  ]];then
    #    echo "  | $BACKGROUND_PATH is empty"
    #    rm -r $BACKGROUND_PATH
    #  fi
    #elif [[ $(ls $BACKGROUND_PATH |wc -l) == 0  ]];then  
    #  echo "  | $BACKGROUND_PATH is empty"
    #  rm -r $BACKGROUND_PATH
    #else
    #  echo "  | $BACKGROUND_PATH exists"
    #fi
    let VIDEO_COUNT++
  done
  let COUNT_CLASS++
done
echo "- Finish"
