#!/usr/bin/env bash
# ******************************************************************* #
# **********Yan HU, 29 Nov, 2017, huyan@link.cuhk.edu.hk**************** #
# ******************************************************************* #

# Reference points
# ref1 94.050717 35.700568
# ref2 94.049920 35.671982
# ref3 94.013031 35.705293

# 20160722-20160803: 28.452
# 20160803-20160815: -45.210
# 20160815-20160827: -31.670
# 20160827-20160908: 3.618
# ref_1=-28.452
# ref_2=45.210
# ref_3=31.670
# ref_4=-3.618
# ref_list="45.210 31.670 -3.618"

ref1_lon=94.050717
ref1_lat=35.700568
ref2_lon=94.049920
ref2_lat=35.671982
ref3_lon=94.013031
ref3_lat=35.705293
rm Tmp_*

interf_path=$1 #first parameter is a list
imagecounts=$(cat $interf_path | wc -l) #line counts as image number
for ((i=1;i<$imagecounts;i++))
do
    PATH1=`awk NR==$i $interf_path`
    PATH2=`awk NR==$i+1 $interf_path`

    UNW1=$PATH1/filt_topophase.unw.geo
#     INTERF1=$PATH1/filt_topophase.flat.geo
    UNW2=$PATH2/filt_topophase.unw.geo
#     INTERF2=$PATH2/filt_topophase.flat.geo
    DEFO1=$PATH1/filt_topophase.unw.defo.geo
    DEFO2=$PATH2/filt_topophase.unw.defo.geo

#     imageIndexTmp=`expr $imageIndex + 1`
#     REF1=$(echo $ref_list | awk '{print $('$imageIndex')}')
#     REF2=$(echo $ref_list | awk '{print $('$imageIndexTmp')}')
    REF1=`gdallocationinfo -valonly -b 2 $UNW1 $ref_colomn $ref_row`
    REF2=`gdallocationinfo -valonly -b 2 $UNW2 $ref_colomn $ref_row`

#     imageMath.py --eval='a_0;-(a_1-'$REF1')*5.546576*(120/12)/12.5663706' --a=$UNW1 -o $DEFO1 -s BIL
    imageMath.py --eval='a_0;-(a_1-'$REF1')*5.546576/12.5663706' --a=$UNW1 -o $DEFO1 -s BIL
#     imageMath.py --eval='a_1' --a=$UNW1 -o "$UNW1".pha -s BIL
#     imageMath.py --eval='a_0;-(a_1-'$REF2')*5.546576*(120/12)/12.5663706' --a=$UNW2 -o $DEFO2 -s BIL
    imageMath.py --eval='a_0;-(a_1-'$REF2')*5.546576/12.5663706' --a=$UNW2 -o $DEFO2 -s BIL
#     imageMath.py --eval='a_1' --a=$UNW2 -o "$UNW2".pha -s BIL

    outTmp=Tmp_"$imageIndex".defo.geo
    imageIndex1=`expr $imageIndex - 1`
    outTmp1=Tmp_"$imageIndex1".defo.geo
    if [ -f Tmp_0.defo.geo ];
    then
        imageMath.py --eval='a_0;(a_1+b_1)' --a=$outTmp1 --b=$DEFO2 -o $outTmp -s BIL
    else
        cp $DEFO1 Tmp_0.defo.geo
        cp "$DEFO1".vrt Tmp_0.defo.geo.vrt
        cp "$DEFO1".xml Tmp_0.defo.geo.xml

        imageMath.py --eval='a_0;(a_1+b_1)' --a=Tmp_0.defo.geo --b=$DEFO2 -o $outTmp -s BIL
    fi
done
imageMath.py --eval='a>0' --a=dem.crop -o dem.mask  -s BIL
imageMath.py --eval='b_0;a*b_1/'$imageNumbers'' --a=dem.mask --b=$outTmp -o stacking.defo.geo -s BIL
imageMath.py --eval='a_0;a_1*b/'$imageNumbers'' --a=$outTmp --b=dem.mask -o stacking.defo.geo -s BIL
imageMath.py --eval='a_1' --a=stacking.defo.geo -o stacking.defo.geo.pha -s BIL
# mdx.py stacking.defo.geo.pha -z -6 -cmap cmy  -kml stacking.defo.geo.pha.kml


rm Tmp_*