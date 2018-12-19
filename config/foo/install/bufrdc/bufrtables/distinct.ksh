#!/usr/bin/ksh

set -e

./clean.sh
p4 edit -t xtext links.sh
cp links.sh links.sh.new

set +e
for f in *.distinct
do
  grep $f links.sh > /dev/null
  if [ $? -ne 0 ]
  then
    echo deleting $f
    p4 delete $f
  fi
done
set -e

for f in *.distinct
do
		t=`echo $f | awk 'BEGIN{FS="";}{print $1;}'`
    md5=`md5sum $f | awk '{print $1;}' `
		df=${t}_${md5}.distinct
		if [ $f != $df ]
		then
        cat links.sh | sed s/$f/$df/g > links.sh.new
        mv links.sh.new links.sh
				if [ ! -f $df ]
				then
          cp $f $df
          chmod +w $df
          p4 add $df
          p4 delete $f
        fi
		fi
done

chmod +x links.sh
./links.sh

for f in *.TXT
do
		if [ ! -L $f ]
		then
				t=`echo $f | awk 'BEGIN{FS="";}{print $1;}'`
				df=${t}_`md5sum $f | awk '{print $1;}' `.distinct
				if [ ! -f $df ]
				then
						cp $f $df
            p4 add $df
				fi
		fi
done

cat /dev/null > links.sh
for f in *.TXT
do
		t=`echo $f | awk 'BEGIN{FS="";}{print $1;}'`
		df=${t}_`md5sum $f | awk '{print $1;}' `.distinct
		rm -f $f
		ln -s $df $f
		echo ln -s $df $f >> links.sh
done

chmod +x links.sh
