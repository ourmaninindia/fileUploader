#!/bin/bash
TINYAPIKEY="uKgMjIpeqXWPbVqdJXPFVdro4LUeXEvk"
 
# Make sure source dir is supplied
if [ -z "$1" ]
    then
    echo "Missing argument. Supply the source directory containing the images to be optimized. Usage: ./tiny.sh <source_dir>"
    exit 1
fi
 
INDIR=$1
 
# Make sure source dir exists
if [ ! -d "$INDIR" ]; then
    echo "\"$INDIR\" directory not found. Supply the source directory containing the images to be optimized. Source directory should be relative to location of this script. Usage: ./tiny.sh <source_dir>"
    exit 1
fi
 
DIRNAME=${INDIR##*/}
OUTDIRNAME="${DIRNAME}_tiny"
OUTDIR="`pwd`/$OUTDIRNAME"
 
# Make sure output dir does not already exist with files.
# If dir exists but empty, it's ok, we proceed.
if find "$OUTDIRNAME" -mindepth 1 -print -quit | grep -q .; then
    echo "Output directory ($OUTDIRNAME) already exists. Exiting without optimizing images."
    exit 1
fi
 
# Create output dir if it does not already exist
if [ ! -d "$OUTDIRNAME" ]; then
    echo "Creating output dir \"$OUTDIRNAME\"..."
    mkdir $OUTDIRNAME   
fi
 
# Begin optimizing images
echo "Optimizing images..."
cd $INDIR
shopt -s nullglob
for file in *.png *.PNG *.jpg *.JPG *.jpeg *.JPEG
do
    Cfile=`curl https://api.tinify.com/shrink --user api:$TINYAPIKEY --data-binary @"${file}" --dump-header /dev/stdout --silent | grep Location | awk '{print $2 }'`
    echo "test 1"
    Cfile=${Cfile// }
    echo "test 2"
    Cfile=`echo -n "$Cfile"| sed s/.$//`
    echo "test 3"
    curl ${Cfile} -o "${OUTDIR}/${file}" --silent
done
 
# Gather stats
echo "Gathering stats..."
INDIR_SIZE="$(du -h)"
INDIR_FILE_COUNT="$(ls | wc -l)"
cd $OUTDIR
OUTDIR_SIZE="$(du -h)"
OUTDIR_FILE_COUNT="$(ls | wc -l)"
echo -e "Finished.\r\nOriginal directory ($INDIR) has $INDIR_FILE_COUNT files; total size $INDIR_SIZE\r\nTinified directory ($OUTDIRNAME) has $OUTDIR_FILE_COUNT files; total size $OUTDIR_SIZE"
