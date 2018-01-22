#!/bin/csh

set SLC_DIR="/DATA2/kunlun_data/alos/P491_F700/SLC/"
set DEM="/DATA2/kunlun_data/TanDEM/kunluneast_N35E93_N36E95_DEM.xml"
set filter=0.4
set geobox="[35.66, 35.71, 94.01, 94.06]"
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
        echo "<insarApp>"				                                                          > $master"_"$slave.xml
	    echo "<component name="\""insar"\"">"                                                    >> $master"_"$slave.xml
        echo "<property  name="\""Sensor name"\"">ALOS</property>"                               >> $master"_"$slave.xml
	    echo "<component name="\""master"\"">"                                                   >> $master"_"$slave.xml
	    echo "<catalog>${master}.xml</catalog>"                                                  >> $master"_"$slave.xml
	    echo "</component>"                                                                      >> $master"_"$slave.xml
     	echo "<component name="\""slave"\"">"                                                    >> $master"_"$slave.xml
        echo "<catalog>${slave}.xml</catalog>"                                                   >> $master"_"$slave.xml
        echo "</component>"                                                                      >> $master"_"$slave.xml
        echo "<property  name="\""filter strength"\"">${filter}</property>"                      >> $master"_"$slave.xml
        echo "<property  name="\""do unwrap"\"">True</property>"                                 >> $master"_"$slave.xml
        echo "<property  name="\""unwrapper name"\"">snaphu_mcf</property>"                      >> $master"_"$slave.xml
        echo "<component name="\""Dem"\"">"                                                      >> $master"_"$slave.xml
	    echo "<catalog>${DEM}</catalog>"                                                         >> $master"_"$slave.xml
        echo "</component>"                                                                      >> $master"_"$slave.xml
	    echo "<property  name="\""geocode bounding box"\"">${geobox}</property>"                 >> $master"_"$slave.xml
        echo "<property  name="\""geocode list"\"">filt_topophase.flat filt_topophase.unw topophase.cor phsig.cor</property>"    >> $master"_"$slave.xml
        echo "</component>"                                                                      >> $master"_"$slave.xml
        echo "</insarApp>"                                                                       >> $master"_"$slave.xml

	  insarApp.py --steps $master"_"$slave.xml --start=startup --"end"=filter
          mv topophase.flat topophase.copy.flat
          mv topophase.flat.xml topophase.copy.flat.xml
          mv topophase.flat.vrt topophase.copy.flat.vrt
          imageMath.py --"eval"='a>0.6' --a=phsig.cor -o coh_mask -t float -s BIL
          imageMath.py --"eval"='abs(a)*exp(J*arg(a))*b' --a=topophase.copy.flat --b=coh_mask -o topophase.flat -t cfloat -s BIL
          cp topophase.copy.flat.vrt topophase.flat.vrt
          cp topophase.copy.flat.xml topophase.flat.xml
      insarApp.py --steps --start='filter' --"end"='geocode' $master"_"$slave.xml

	cd ../
	endif
       set i = 0 
   else
       set i = 1
       set master = $slave
   endif
end
