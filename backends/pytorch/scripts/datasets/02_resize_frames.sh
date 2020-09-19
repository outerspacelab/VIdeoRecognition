##!/bin/bash
## Usage: bash 02_resize_frames.sh /data/jingzhou/Projects/Datasets/ActionRecognition/gesture/rgb 128 128

echo "+ Resize frames to $2 x $3"
ALL_RGB_PATH=$1
COPY_RGB_PATH=$ALL_RGB_PATH"_copy"
#ROOT_PATH=${ALL_RGB_PATH%/*}


if [[ ! -d $COPY_RGB_PATH ]];then
  cp -r $ALL_RGB_PATH $COPY_RGB_PATH
else
  echo "| $COPY_RGB_PATH exist."
fi

for CLASS in $(ls $ALL_RGB_PATH)
do
  CLASS_PATH=$ALL_RGB_PATH/$CLASS
  echo "| Process $CLASS_PATH"
  for ITERM in $(ls $CLASS_PATH)
  do
    ITERM_PATH=$CLASS_PATH/$ITERM
    #identify -format "%wx%h" $ITERM_PATH/*.jpg
    find $ITERM_PATH -iname '*.jpg' -exec convert \{} -verbose -resize 128x128\!\> \{} \; 
    echo "  | Read $ITERM_PATH"
  done
  let CLASS_INDEX++
done

echo "- Finish"
