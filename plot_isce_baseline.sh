#!/bin/sh

out=ALOS_baseline.ps
rm $out
gmt gmtset GMT_COMPATIBILITY=4
gmt gmtset INPUT_DATE_FORMAT yyyy/mm/dd
blist=$1
date1=2006-06-01T/2011-06-30T/-3000/3000
size=12c/7c

xdate=`cat $1 |awk '{print $2}'`
ybase=`cat $1 |awk '{print $3}'`

gmt psbasemap -JX${size} -R${date1} -Bs1Y/S -Bpa6of1o:Time:/a500f100:"Perpendicular Baseline (m)":WSen -K -P -V > $out
 awk '{print $2 "  "$3}' $1 | awk '{print substr($1, 1,4)"/"substr($1,5,2)"/"substr($1, 7,2) " " $2}' | gmt psxy -J -R -Sc0.15 -G0/0/0 -O -P -V >> $out

gmt psconvert $out -Tf -A

rm gmt.* .gmt*

