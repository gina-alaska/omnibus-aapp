#!/bin/sh

for f in *.TXT
do
	if [ -L $f ]
	then
		rm -f $f
	fi
done
