#!/usr/bin/env bash
#this code draw the whole interferogram
# eg. interf_plot "$MASTER"_"$SLAVE".defo.geo "$MASTER"_"$SLAVE".defo.geo.fig $CMP_TICK $SCALE_TICK

rm gmt.*
INPUT_FILE=$1
OUTPUT_FILE=$2
CMP_TICK=$3
SCALE_TICK=$4
#CMP_TICK=-T-7/14/1      #-Tmin/max/step
#SCALE_TICK=-B1::/:cm:
#BASEMAP=/DATA2/kunlun_data/alos/P491_F700/ISCE_proc/analysis/jingxiangu20.tif

#resample to same size
# gdalwarp -t_srs '+proj=longlat +datum=WGS84 +no_defs' -tr 0.000111111111111 -0.000111111111111 $BASEMAP jingxiangu.lonlat.tif
#separate RGB bands
# gdal_translate -of netCDF jingxiangu.lonlat.tif -b 1 jingxiangu.red.nc
# gdal_translate -of netCDF jingxiangu.lonlat.tif -b 2 jingxiangu.green.nc
# gdal_translate -of netCDF jingxiangu.lonlat.tif -b 3 jingxiangu.blue.nc

PS="$OUTPUT_FILE".ps
INPUT_FILE_vrt="$INPUT_FILE".vrt
baseMap_R=/DATA2/kunlun_data/alos/P491_F700/ISCE_proc/analysis/jingxiangu.red.nc
baseMap_G=/DATA2/kunlun_data/alos/P491_F700/ISCE_proc/analysis/jingxiangu.green.nc
baseMap_B=/DATA2/kunlun_data/alos/P491_F700/ISCE_proc/analysis/jingxiangu.blue.nc

ncname_tmp="$INPUT_FILE".tmp.nc
# grdzeroname="$INPUT_FILE_vrt".zero.grd
ncname="$INPUT_FILE".nc

CMP=los.cpt

gmt gmtset MAP_FRAME_TYPE plain
gmt gmtset FONT_ANNOT_PRIMARY = +10p,Helvetica,black
# gmt gmtset FORMAT_GEO_OUT = ddd.xxxF
gmt gmtset FORMAT_GEO_MAP = ddd.xxF
# gmt gmtset FORMAT_FLOAT_OUT = D

gmt gmtset MAP_VECTOR_SHAPE = 1.4
gmt gmtset COLOR_MODEL = rgb
gmt gmtset COLOR_BACKGROUND = white  # when z < lowest color table entry
gmt gmtset COLOR_FOREGROUND = red  # when z > highest color table entry
gmt gmtset COLOR_NAN = white
# gmt gmtset IO_LONLAT_TOGGLE = true

#[35.66, 35.71, 94.01, 94.06]
#ROI=94.0099427/94.0600571/35.6531641/35.7100564
ROI=94.0099427/94.0600571/35.6631641/35.7100564
J=M6i
D=6.2i/1.3i/7c/0.5c

# Make GMT color palette tables
 #制作colorbar
gmt makecpt -Crainbow $CMP_TICK -Fr -Z > $CMP

# 绘制地图，-J设置投影方式，-R设置绘图范围（经纬度），-V无用，-P是指portrait模式，A4纸是竖着的，-B 设置网格和横纵坐标的属性
 # -Bx,y 定义横纵坐标轴，-BWSen中WSEN指代东南西北四条绘图边界，大写表示绘制并标注文字，小写表示只绘制边界不标注
 # -K 与 -O ： 在写入最终文件的系列代码中 第一行命令只用-K 中间命令使用-K -O， 最后一行命令只用-O （这两个参数是规定输出文件中header和trailer的，-O忽略header，-K忽略trailer）
gmt psbasemap -J$J -R$ROI -V -P -Bx0.02d -By0.02d -BWSen -K > $PS

# 将原始数据inputfile转换为GMT可以识别的文件（ncname_tmp）-G 声明输出文件
gdal_translate -of netCDF $INPUT_FILE_vrt $ncname_tmp -a_nodata -9999

# 再将ncname_tmp裁剪为最终成图的区域ncname -G 声明输出文件  -Sb 将所有小于-1000的值设置为NaN
gmt grdclip $ncname_tmp -G$ncname -Sb-1000/NaN

gmt grdimage $baseMap_R $baseMap_G $baseMap_B -J$J -R$ROI -O -K >> $PS

gmt grdimage $ncname -C$CMP -J$J -t60 -R$ROI -O -K -Q >> $PS

gmt psscale -D$D -C$CMP $SCALE_TICK -O -I >> $PS

gmt psconvert -Tf $PS -A -E400
# gmt psconvert -Tb $PS -A -E1000
# gmt psconvert -W+k $PS -A -E400