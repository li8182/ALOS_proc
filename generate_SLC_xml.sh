#!/bin/sh

slcdir=`pwd`
echo "SLC direcotry: $slcdir"

for slc in `cat slc.list`
do
	echo $slc
	cd $slc
	rm $slc.xml
	led=`\ls LED*`	
        img=`\ls IMG-HH*`
	echo $led
	echo $img
	hv=`\ls IMG-HV* | sed 1q`
	echo "<component>"                              >  $slc.xml
	echo '    <property name="IMAGEFILE">'          >> $slc.xml
	echo "        <value>$slcdir/$slc/$img</value>" >> $slc.xml
	echo "    </property>"                          >> $slc.xml 	
	echo '    <property name="LEADERFILE">'         >> $slc.xml
	echo "	      <value>$slcdir/$slc/$led</value>" >> $slc.xml
	echo "    </property>"                            >> $slc.xml
	echo '    <property name="OUTPUT">'             >> $slc.xml
	echo "        <value>${slc}.raw</value>"        >> $slc.xml
	echo "    </property>"                          >> $slc.xml
	if [ ! -z "$hv" ] 
	then
		echo '    <property name="RESAMPLE_FLAG">'  >> $slc.xml
		echo "        <value>dual2single</value>"   >> $slc.xml
		echo "    </property>"                      >> $slc.xml  
	fi
	echo "</component>"                             >> $slc.xml
	cd ../
done
