#!/bin/bash
# ******************************************************************* #
# **********Yan HU, 29 Nov, 2017, huyan@link.cuhk.edu.hk************* #
# ******************************************************************* #

#run in ISCE_proc
##
# Reference points
# ref1 94.050717 35.700568
# ref2 94.049920 35.671982
# ref3 94.013031 35.705293

interf_path=$1 #first parameter is a list
imagecounts=$(cat $interf_path | wc -l) #line counts as image counts

W_PATH=/DATA2/kunlun_data/alos/P491_F700/ISCE_proc/analysis/W
UNW_PATH=/DATA2/kunlun_data/alos/P491_F700/ISCE_proc/analysis/UNW

MASK_PATH=/DATA2/kunlun_data/alos/P491_F700/ISCE_proc/analysis/MASK
NAN_PATH=/DATA2/kunlun_data/alos/P491_F700/ISCE_proc/analysis/NAN

UNWPHS_PATH=/DATA2/kunlun_data/alos/P491_F700/ISCE_proc/analysis/UNWPHS
UNWPHS_nan_PATH=/DATA2/kunlun_data/alos/P491_F700/ISCE_proc/analysis/UNWPHS_nan

PHS_PATH=/DATA2/kunlun_data/alos/P491_F700/ISCE_proc/analysis/PHS
PHS_nan_PATH=/DATA2/kunlun_data/alos/P491_F700/ISCE_proc/analysis/PHS_nan

DEFO_PATH=/DATA2/kunlun_data/alos/P491_F700/ISCE_proc/analysis/DEFO
DEFO_nan_PATH=/DATA2/kunlun_data/alos/P491_F700/ISCE_proc/analysis/DEFO_nan

LOS_PATH=/DATA2/kunlun_data/alos/P491_F700/ISCE_proc/analysis/LOS
LOS_nan_PATH=/DATA2/kunlun_data/alos/P491_F700/ISCE_proc/analysis/LOS_nan

for ((i=1;i<$imagecounts;i++))
do
    IPATH=`awk NR==$i $interf_path`
    cd $IPATH
    echo `pwd`

# generate amp_mask
    UNW=filt_topophase.unw.geo
    #W=filt_topophase.flat.geo
    #cp "$UNW" "$UNW_PATH"
    #cp "$W" "$W_PATH"
    imageMath.py --eval='a_0!=0' --a=$UNW -o "$IPATH"_mask.geo -t float -s BIL
    cp "$IPATH"_mask.geo $MASK_PATH
    cp "$IPATH"_mask.geo.vrt $MASK_PATH
    cp "$IPATH"_mask.geo.xml $MASK_PATH
    AMP_MASK="$IPATH"_mask.geo
#generate nan_mask
    imageMath.py --eval='(a==0)*(-9999)' --a=$AMP_MASK -o "$IPATH"_nan_mask.geo  -s BIL #generate nan mask
    cp "$IPATH"_nan_mask.geo $NAN_PATH
    cp "$IPATH"_nan_mask.geo.vrt $NAN_PATH
    cp "$IPATH"_nan_mask.geo.xml $NAN_PATH
    NAN_MASK="$IPATH"_nan_mask.geo

# separate phase
    imageMath.py --eval='a_1' --a=$UNW -o filt_topophase.unw.phs.geo -s BIL
    TEMP1=filt_topophase.unw.phs.geo
    #apply amp mask
    imageMath.py --eval='a*b' --a=$TEMP1 --b=$AMP_MASK -o "$IPATH"_unwphs.geo -s BIL
    cp "$IPATH"_unwphs.geo $UNWPHS_PATH
    cp "$IPATH"_unwphs.geo.vrt $UNWPHS_PATH
    cp "$IPATH"_unwphs.geo.xml $UNWPHS_PATH
    UNWPHS="$IPATH"_unwphs.geo
    #apply nan mask
    imageMath.py --eval='a*(b==0)+b' --a=$TEMP1 --b=$NAN_MASK -o "$IPATH"_unwphs_nan.geo -s BIL
    cp "$IPATH"_unwphs_nan.geo $UNWPHS_nan_PATH
    cp "$IPATH"_unwphs_nan.geo.vrt $UNWPHS_nan_PATH
    cp "$IPATH"_unwphs_nan.geo.xml $UNWPHS_nan_PATH
    UNWPHS_nan="$IPATH"_unwphs_nan.geo

# subtract reference
    ref1_lon=94.050717
    ref1_lat=35.700568
    #ref2_lon=94.049920
    #ref2_lat=35.671982
    #ref3_lon=94.013031
    #ref3_lat=35.705293
    REF1=`gdallocationinfo -valonly -wgs84 $TEMP1 $ref1_lon $ref1_lat`
    #REF2=`gdallocationinfo -valonly -wgs84 $TEMP1 $ref2_lon $ref2_lat`
    #REF3=`gdallocationinfo -valonly -wgs84 $TEMP1 $ref3_lon $ref3_lat`
    echo $REF1
    #echo $REF2
    #echo $REF3
    imageMath.py --eval='a-'$REF1'' --a=$TEMP1 -o phs.unw.geo -s BIL
    #imageMath.py --eval='a-('$REF1'+'$REF2'+'$REF3')/3' --a=$TEMP1 -o phs.unw.geo -s BIL
    TEMP2=phs.unw.geo
    # mask the phs
    imageMath.py --eval='a*b' --a=$TEMP2 --b=$AMP_MASK -o "$IPATH"_phs.geo -s BIL
    cp "$IPATH"_phs.geo $PHS_PATH
    cp "$IPATH"_phs.geo.vrt $PHS_PATH
    cp "$IPATH"_phs.geo.xml $PHS_PATH
    PHS="$IPATH"_phs.geo

    #apply nan mask
    imageMath.py --eval='a*(b==0)+b' --a=$TEMP2 --b=$NAN_MASK -o "$IPATH"_phs_nan.geo -s BIL
    cp "$IPATH"_phs_nan.geo $PHS_PATH
    cp "$IPATH"_phs_nan.geo.vrt $PHS_PATH
    cp "$IPATH"_phs_nan.geo.xml $PHS_PATH
    PHS_nan="$IPATH"_phs_nan.geo

# calculate deformation
    imageMath.py --eval='a*23.60571/12.5663706' --a=$PHS -o "$IPATH"_defo.geo -s BIL
    cp "$IPATH"_defo.geo $DEFO_PATH
    cp "$IPATH"_defo.geo.vrt $DEFO_PATH
    cp "$IPATH"_defo.geo.xml $DEFO_PATH
    DEFO="$IPATH"_defo.geo

    imageMath.py --eval='a*23.60571/12.5663706' --a=$PHS_nan -o "$IPATH"_defo_nan.geo -s BIL
    cp "$IPATH"_defo_nan.geo $DEFO_nan_PATH
    cp "$IPATH"_defo_nan.geo.vrt $DEFO_nan_PATH
    cp "$IPATH"_defo_nan.geo.xml $DEFO_nan_PATH
    DEFO_nan="$IPATH"_defo_nan.geo

# calculate velocity
    imageMath.py --eval='a*365/46' --a=$DEFO -o "$IPATH"_los.geo -s BIL
    cp "$IPATH"_los.geo $LOS_PATH
    cp "$IPATH"_los.geo.vrt $LOS_PATH
    cp "$IPATH"_los.geo.xml $LOS_PATH

    imageMath.py --eval='a*365/46' --a=$DEFO_nan -o "$IPATH"_los_nan.geo -s BIL
    cp "$IPATH"_los_nan.geo $LOS_nan_PATH
    cp "$IPATH"_los_nan.geo.vrt $LOS_nan_PATH
    cp "$IPATH"_los_nan.geo.xml $LOS_nan_PATH
    cd ..
done

