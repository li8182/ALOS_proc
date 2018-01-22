#!/bin/bash
#this code draw the whole interferogram
# sh test.sh filt_topophase.unw.geo.pha
# eg. interf_plot stacking.defo.geo.vrt stacking.defo.geo.ss17.ps

rm gmt.*
INPUT_FILE=$1
OUTPUT_FILE=$2
CMP_TICK=$3
SCALE_TICK=$4
# CMP_TICK=-T-2/2/1
# SCALE_TICK=-B1::/:cm:

PS="$OUTPUT_FILE".ps
INPUT_FILE_vrt="$INPUT_FILE".vrt
baseMap_R=/home/jiechencyz/Experiment/Sobosise/googleTiff/Sobosise.red.nc
baseMap_G=/home/jiechencyz/Experiment/Sobosise/googleTiff/Sobosise.green.nc
baseMap_B=/home/jiechencyz/Experiment/Sobosise/googleTiff/Sobosise.blue.nc

ncname_tmp="$INPUT_FILE".tmp.nc
# grdzeroname="$INPUT_FILE_vrt".zero.grd
ncname="$INPUT_FILE".nc


CMP=test.cpt

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

#[72.3718267, 72.5550191, 127.6424161, 129.0097045]
ROI=127.6424161/129.0098150/72.3718266/72.5550191
J=M6i
D=6.2i/1.3i/7c/0.5c

# gdal_translate -of netCDF $baseMap -b 1 Sobosise.red.nc
# gdal_translate -of netCDF $baseMap -b 2 Sobosise.green.nc
# gdal_translate -of netCDF $baseMap -b 3 Sobosise.blue.nc

# Make GMT color palette tables
 #制作colorbar
gmt makecpt -Crainbow $CMP_TICK -Fr -Z > $CMP 

# 绘制地图，-J设置投影方式，-R设置绘图范围（经纬度），-V无用，-P是指portrait模式，A4纸是竖着的，-B 设置网格和横纵坐标的属性
 # -Bx,y 定义横纵坐标轴，-BWSen中WSEN指代东南西北四条绘图边界，大写表示绘制并标注文字，小写表示只绘制边界不标注
 # -K 与 -O ： 在写入最终文件的系列代码中 第一行命令只用-K 中间命令使用-K -O， 最后一行命令只用-O （这两个参数是规定输出文件中header和trailer的，-O忽略header，-K忽略trailer）
gmt psbasemap -J$J -R$ROI -V -P -Bx0.3d -By0.05d -BWSen -K > $PS 

# 将原始数据inputfile转换为GMT可以识别的文件（ncname_tmp）-G 声明输出文件
gdal_translate -of netCDF $INPUT_FILE_vrt $ncname_tmp -a_nodata -9999

# 再将ncname_tmp裁剪为最终成图的区域ncname -G 声明输出文件  -Sb 将所有小于-1000的值设置为NaN
gmt grdclip $ncname_tmp -G$ncname -Sb-1000/NaN

# 将R,G,B三通道数据绘制出来，-J声明投影方式，-R声明区域，
gmt grdimage $baseMap_R $baseMap_G $baseMap_B -J$J -R$ROI -O -K >> $PS

# 将ncname数据绘制出来，-C声明使用的colorbar -J声明投影方式 （一般而言，对同一张输出的图，-J -R均会遵循最初命令行的设置）
gmt grdimage $ncname -C$CMP -J$J -O -K -Q >> $PS

# 画上COLORBAR -D声明colorbar在图上位置 -C声明所用colorbar -I增加光效更美丽 -O 彻底结束文件
gmt psscale -D$D -C$CMP $SCALE_TICK -O -I >> $PS

# 将输出的ps文件转换为bmp -T声明输出文件类型，b代表bmp；-A 调整输出效果 -E声明输出分辨率（dpi）
gmt psconvert -Tb $PS -A -E1000
# gmt psconvert -W+k $PS -A -E400


