#!/usr/bin/env bash

interf_name=$1 #first parameter is a list
imagecounts=$(cat $interf_name | wc -l) #line counts as image counts
for ((i=1;i<$imagecounts;i++))
do
    IMAGEBASE=`awk NR==$i $interf_name`
    gdalinfo -mm LOS/"$IMAGEBASE"_los.geo
done

#20070801_20070916 Min/Max=-44.968,56.800
#20090806_20090921 Min/Max=-51.275,78.969
#20100809_20100924 Min/Max=-50.605,93.734
#20081219_20090203 Min/Max=-44.658,49.434
#20070616_20070916 Min/Max=-120.017,77.991
#20090621_20090921 Min/Max=-71.052,100.907
#20100624_20100924 Min/Max=-190.807,106.799
#20070616_20070801 Min/Max=-56.856,112.729
#20090621_20090806 Min/Max=-66.145,73.353
#20100624_20100809 Min/Max=-67.912,72.525
#20080201_20080318 Min/Max=-19.361,21.246

