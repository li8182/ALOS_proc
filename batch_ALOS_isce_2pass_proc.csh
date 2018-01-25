#!/bin/csh

set SLC_DIR="/home/zhiwei/work2016-CUHK/WDD-Landslides/SLC"
#set P_DIR="/media/sdb1/users/zzw/projs/Mexico-Envisat/T255/ints"
set rglooks=6
set azlooks=8
set filter=0.4
set geobox="[26.24, 26.36, 102.52, 102.64]"
set startstep="startup"
set endstep="endup"
set list=$1
set i = 0
set SB_DIR=`pwd`

foreach slave(`cat $list`)
   echo $slave
   if ($i == 1) then
      set IFG_DIR = $SB_DIR/$master"_"$slave
      if (! -e $IFG_DIR) then
          mkdir $IFG_DIR
	  cd $IFG_DIR
	  cp $SLC_DIR/$master/$master.xml .  
	  cp $SLC_DIR/$slave/$slave.xml .
          echo "<insarApp>"				> $master"_"$slave.xml
	  echo "    <component name="\""insar"\"">"           >> $master"_"$slave.xml
          echo "        <property  name="\""Sensor name"\"">ALOS</property>"    >> $master"_"$slave.xml
	  echo "        <component name="\""master"\"">"                        >> $master"_"$slave.xml
	  echo "            <catalog>${master}.xml</catalog>"               >> $master"_"$slave.xml
	  echo "        </component>"                                     >> $master"_"$slave.xml
          echo "        <component name="\""slave"\"">"                         >> $master"_"$slave.xml
          echo "            <catalog>${slave}.xml</catalog>"                >> $master"_"$slave.xml
          echo "        </component>"                                     >> $master"_"$slave.xml
          echo "        <property  name="\""range looks"\"">${rglooks}</property>"         >> $master"_"$slave.xml
          echo "        <property  name="\""azimuth looks"\"">${azlooks}</property>"       >> $master"_"$slave.xml
          echo "        <property  name="\""filter strength"\"">$filter</property>"        >> $master"_"$slave.xml
          echo "        <property  name="\""do unwrap"\"">True</property>"                 >> $master"_"$slave.xml
          echo "        <property  name="\""unwrapper name"\"">snaphu_mcf</property>"     >> $master"_"$slave.xml
          echo "        <property  name="\""geocode bounding box"\"">${geobox}</property>" >> $master"_"$slave.xml
          echo "        <property  name="\""geocode list"\"">filt_topophase.flat filt_topophase.unw topophase.cor phsig.cor</property>"    >> $master"_"$slave.xml
          echo "    </component>" >> $master"_"$slave.xml
          echo "</insarApp>"      >> $master"_"$slave.xml
	  insarApp.py $master"_"$slave.xml --steps --start=$startstep --end=$endstep
	cd ../
	endif
       set i = 0 
   else
       set i = 1
       set master = $slave
   endif
end
