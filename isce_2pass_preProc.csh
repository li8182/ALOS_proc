#!/bin/csh

set SLC_DIR="/home/zhiwei/work2016-CUHK/WDD-Landslides/SLC"
#set P_DIR="/media/sdb1/users/zzw/projs/Mexico-Envisat/T255/ints"
set startstep="startup"
set endstep="preprocess"
set list=$1
set i=0
set SB_DIR=`pwd`

foreach slave(`cat $list`)
   echo $slave
   if ($i == 1) then   
      set IFG_DIR = $SB_DIR/$master"_"$slave
      rm -rf $IFG_DIR
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
          echo "    </component>" >> $master"_"$slave.xml
          echo "</insarApp>"      >> $master"_"$slave.xml
	  insarApp.py $master"_"$slave.xml --steps --start=$startstep --end=$endstep
	  set pberp_top=`cat isce.log | grep 'baseline.perp_baseline_bottom' | awk '{print $3}'`
          set pberp_bot=`cat isce.log | grep 'baseline.perp_baseline_top' | awk '{print $3}'`
          set pberp=`echo $pberp_top $pberp_bot | awk '{mean=($1+$2)/2.0; print mean}'`
          echo "$master    $slave    $pberp"
          echo "$master    $slave    $pberp" >> ../ifg_baseline.list 
	  cd ../
       endif
   else
        set i = 1
	set master = $slave 
	echo "$master	$slave	0" > ../ifg_baseline.list
   endif
end

rm -rf 20*
