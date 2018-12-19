#!/bin/ksh
#
# An example script for building AAPP v8 and OPS-LRS v8 with various external
# libraries.
#
# Creates the following subdirectories:
#
#     tarfiles
#     install
#           bufrdc
#           eccodes
#           hdf5
#           AAPP_8.2
#           opslrs
#     build
#           bufrdc_000409
#           eccodes-2.8.2-Source
#           eccodes_build
#           hdf5-1.10.1
#           AAPP_8.2
#           OPS_V8.0-AAPP-l-20180118
#           xerces-c-src1_7_0
#           fftw-3.0.1
#           flex-flex-2-5-35
#
# Assumes that the external libraries are not centrally installed, and that the
# user does not have root privilege. You can modify the script if you want to
# use centrally-installed libraries.
#
# You should check the settings at the top of the script and change them to
# suit your system (e.g. station name).
#
# The AAPP and OPS-LRS tar files need to be manually downloaded from the NWPSAF
# web site, with the user logged into the site, and placed in the "tarfiles"
# directory. The other files are downloaded automatically if they are not 
# already present in "tarfiles". It is recommended to use the latest version of
# the ecCodes library (set to 2.6.2 in this script).
#
# 01/11/2017 NCA
# 22/01/2017 Update
# 31/01/2017 Add -lhdf5_hl -lhdf5_fortran in the AAPP configure step
# 23/02/2018 Update for OPS-LRS v8.0
# 27/09/2018 AAPP v8.2; ecCodes v2.8.2; update url for aapp_data_files
#########################################################################

usage(){
  echo "Usage: ./install_aapp8 item"
  echo "where item is:"
  echo "  1 for HDF5 (with Fortran interfaces)"
  echo "  2 for BUFRDC"
  echo "  3 for ecCodes"
  echo "  4 for AAPP"
  echo "  5 for AAPP MAIA4 data files"
  echo "  6 for fftw (needed for OPS-LRS)"
  echo "  7 for xerces (needed for OPS-LRS)"
  echo "  8 for flex (checks whether it is centrally installed)"
  echo "  9 for OPS-LRS"
  echo " 10 for current set of OPS-LRS auxiliary files"
}

item=$1
[ $item ] || { usage; exit 1; }

AAPP_VERSION=8.2            #to correspond with the name of the AAPP tar file
FORTRAN_COMPILER=gfortran   #gfortran, ifort (or pgf90 if you are not building OPS-LRS)
STATION=exeter    #change as required
SITE_ID=UKM       #change as required
NTHREADS=8  #for OPS-LRS. Depends on the number of cores you have available,
            #but aim for a multiple of 4 if possible. It can be changed later,
            #by editing OPS-LRS-run/OPS/conf/OPS_SD.cfg

TOP=$PWD
TAR=$TOP/tarfiles
BUILD=$TOP/build
INSTALL=$TOP/install

mkdir -p $TAR $BUILD $INSTALL

HDF5_INSTALL_DIR=$INSTALL/hdf5
BUFRDC_INSTALL_DIR=$INSTALL/bufrdc
ECCODES_INSTALL_DIR=$INSTALL/eccodes
AAPP_INSTALL_DIR=$INSTALL/AAPP_$AAPP_VERSION
OPSLRS_EXT_INSTALL_DIR=$INSTALL/opslrs
OPSLRS_INSTALL_DIR=$INSTALL/opslrs

mkdir -p $HDF5_INSTALL_DIR $BUFRDC_INSTALL_DIR $ECCODES_INSTALL_DIR 
mkdir -p $OPSLRS_EXT_INSTALL_DIR $OPSLRS_INSTALL_DIR $AAPP_INSTALL_DIR


##############HDF5 version 1.10.1

if [ $item = 1 ]; then
  
  cd $TAR
  tarfile=hdf5-1.10.1.tar.gz
  url="https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.10/hdf5-1.10.1/src/"
  [ -s $tarfile ] || { echo "Downloading HDF5"; wget ${url}${tarfile}; }
  [ -s $tarfile ] || { echo "Failed to download $tarfile"; exit 1; }

  cd $BUILD
  dir=${tarfile%.tar.gz}
  [ -d $dir ] || { echo "unpacking HDF5"; tar -xzf $TAR/$tarfile; }

  cd $dir
  export FC=$FORTRAN_COMPILER
  mkdir -p $HDF5_INSTALL_DIR

  ./configure --prefix=$HDF5_INSTALL_DIR --enable-fortran || { echo "problem with hdf5 configure"; exit 1; }
  make || { echo "problem with hdf5 make"; exit 1; }
  make install || { echo "problem with hdf5 make install"; exit 1; }
  echo "Finished hdf5 build"

fi

##############BUFRDC version 409
# Note: you may have to check the download url is still valid, 
# see https://software.ecmwf.int/wiki/display/BUFR/BUFRDC+Home

if [ $item = 2 ]; then
  
  cd $TAR
  tarfile=bufrdc_000409.tar.gz
  url="https://software.ecmwf.int/wiki/download/attachments/35752466/"
  [ -s $tarfile ] || { echo "Downloading BUFRDC"; wget ${url}${tarfile}; }
  [ -s $tarfile ] || { echo "Failed to download $tarfile"; exit 1; }

#BUFRDC build can fail in buevar.F if the install directory has 47 characters
#or more, so create a link in /tmp

  if [ ${#BUFRDC_INSTALL_DIR} -ge 47 ]; then
    echo "Too many characters in $BUFRDC_INSTALL_DIR"
    echo "Creating a link /tmp/bufrdc_install"
    BUFRDC_INSTALL_DIR_ORIG=$BUFRDC_INSTALL_DIR
    BUFRDC_INSTALL_DIR=/tmp/bufrdc_install
    rm -f $BUFRDC_INSTALL_DIR
    ln -sf $BUFRDC_INSTALL_DIR_ORIG $BUFRDC_INSTALL_DIR || { echo "unable to create $BUFRDC_INSTALL_DIR"; exit 1; }
  fi

  cd $BUILD
  dir=${tarfile%.tar.gz}
  [ -d $dir ] || { echo "unpacking BUFRDC"; tar -xzf $TAR/$tarfile; }
  [ -d $dir ] || { echo "problem unpacking BUFRDC"; exit 1; }
  cd $dir
  echo "Building BUFRDC ..."

  case $FORTRAN_COMPILER in
    gfortran) reply=y;;
    pgf90)    reply=n;;
    ifort)    reply=i;;
    *) echo "unsupported compiler"
       exit 1;;
  esac

  ./build_library <<EOF
$reply
n
$BUFRDC_INSTALL_DIR
EOF
  ./install

  [ $BUFRDC_INSTALL_DIR_ORIG ] && BUFRDC_INSTALL_DIR=BUFRDC_INSTALL_DIR_ORIG
  echo "Finished BUFRDC build"

fi

##############ecCodes
# Note: you may have to check the download url is still valid, 
# see https://software.ecmwf.int/wiki/display/ECC/Releases
# In general, you should use the latest available release of ecCodes.

if [ $item = 3 ]; then

  cd $TAR
  tarfile=eccodes-2.8.2-Source.tar.gz
  url="https://software.ecmwf.int/wiki/download/attachments/45757960/"
  [ -s $tarfile ] || { echo "Downloading ecCodes"; wget ${url}${tarfile}; }
  [ -s $tarfile ] || { echo "Failed to download $tarfile"; exit 1; }

  cd $BUILD
  dir=${tarfile%.tar.gz}
  [ -d $dir ] || { echo "unpacking ecCodes"; tar -xzf $TAR/$tarfile; }

  echo "Building ecCodes ..."

  mkdir -p eccodes_build
  cd eccodes_build

  cmake \
    -DCMAKE_INSTALL_PREFIX=${ECCODES_INSTALL_DIR} \
    -DCMAKE_Fortran_COMPILER=${FORTRAN_COMPILER} \
    $BUILD/$dir
  make || { echo "problem with ecCodes make"; exit 1; }
  make install >install.out || { echo "problem with ecCodes make install"; exit 1; }
  echo "Finished ecCodes build"

fi

##############AAPP
# Note: if some or all of the external libraries are centrally installed then you should modify the configure
# step (remove -L...) and no need to modify LD_LIBRARY_PATH.

if [ $item = 4 ]; then

  cd $TAR
  tarfile=AAPP_${AAPP_VERSION}.tgz

  if [ ! -s $tarfile ]; then
    echo "Please put $tarfile in directory $TAR"
    exit 1
  fi

  cd $BUILD
  dir=${tarfile%.tgz}
  [ -d $dir ] || { echo "unpacking AAPP"; tar -xzf $TAR/$tarfile; }

  cd $dir
  ./configure --station=$STATION --fortran-compiler=$FORTRAN_COMPILER --site-id=$SITE_ID \
    --external-libs="-L$BUFRDC_INSTALL_DIR -lbufr -L$ECCODES_INSTALL_DIR/lib -leccodes -leccodes_f90 -L$HDF5_INSTALL_DIR/lib -lhdf5 -lhdf5_hl -lhdf5_fortran -lhdf5hl_fortran" \
    --external-includes="-I$HDF5_INSTALL_DIR/include -I$ECCODES_INSTALL_DIR/include" \
    --prefix=$AAPP_INSTALL_DIR

#set up LD_LIBRARY_PATH in ATOVS_ENV8
  sed -i s#DIR_HDF5=#DIR_HDF5=$HDF5_INSTALL_DIR# ATOVS_ENV8
  sed -i s#DIR_ECCODES=#DIR_ECCODES=$ECCODES_INSTALL_DIR# ATOVS_ENV8

#Correct the atms_channels.dat file (see bug report on https://www.nwpsaf.eu/site/software/aapp/updates/)
  tmpdir=AAPP/src/tools/libaapphdf5
  grep -v "Dummy line" $tmpdir/atms_channels.dat >$tmpdir/atms_channels1.dat && \
    mv $tmpdir/atms_channels1.dat $tmpdir/atms_channels.dat

  echo "Building AAPP ..."
  make >make.out 2>make.err || { echo "AAPP make failed"; exit 1; }
  make install || { echo "AAPP make install failed"; exit 1; }

  echo "Finished AAPP build"

fi
  
##############AAPP MAIA4 data

if [ $item = 5 ]; then

  cd $TAR
#  url=https://nwpsaf.eu/downloads/aapp_data_files/maia_data_files/
  url=ftp://ftp.eumetsat.int/pub/NWPSAF/aapp_data_files/maia_data_files/

  if [[ $AAPP_VERSION = 8.* ]]; then
    tarfile=AAPP_MAIA4_thresholds_v8.tgz
    [ -s $tarfile ] || { echo "Downloading $tarfile"; wget ${url}${tarfile}; }
    [ -s $tarfile ] || { echo "Problem downloading $tarfile"; exit 1; }
    tarfile=AAPP_MAIA4_atlas.tgz
    [ -s $tarfile ] || { echo "Downloading $tarfile"; wget ${url}${tarfile}; }
    [ -s $tarfile ] || { echo "Problem downloading $tarfile"; exit 1; }
    cd $AAPP_INSTALL_DIR
    [ -d AAPP/data_maia4/thresholds ] || { echo "Unpacking thresholds"; tar -xzf $TAR/AAPP_MAIA4_thresholds_v8.tgz; }
    [ -d AAPP/data_maia4/atlas ] || { echo "Unpacking atlas"; tar -xzf $TAR/AAPP_MAIA4_atlas.tgz; }

  else    #v7.x
    tarfile=AAPP_MAIA4_data.tar.gz
    [ -s $tarfile ] || { echo "Downloading $tarfile"; wget ${url}${tarfile}; }
    [ -s $tarfile ] || { echo "Problem downloading $tarfile"; exit 1; }
    tarfile=AAPP_MAIA4_data_update_7.6.tar.gz
    [ -s $tarfile ] || { echo "Downloading $tarfile"; wget ${url}${tarfile}; }
    [ -s $tarfile ] || { echo "Problem downloading $tarfile"; exit 1; }
    tarfile=AAPP_MAIA4_data_update_7.9.tar.gz
    [ -s $tarfile ] || { echo "Downloading $tarfile"; wget ${url}${tarfile}; }
    [ -s $tarfile ] || { echo "Problem downloading $tarfile"; exit 1; }
    cd $AAPP_INSTALL_DIR
    if [ ! -d AAPP/data_maia4 ]; then
      echo "Unpacking maia4_data"
      tar -xzf $TAR/AAPP_MAIA4_data.tar.gz
      tar -xzf $TAR/AAPP_MAIA4_data_update_7.6.tar.gz
      tar -xzf $TAR/AAPP_MAIA4_data_update_7.9.tar.gz
    fi
  fi

fi

##############fftw
 
if [ $item = 6 ]; then

  cd $TAR
#  url=https://nwpsaf.eu/downloads/aapp_data_files/OPS-LRS/external_libs/
  url=ftp://ftp.eumetsat.int/pub/NWPSAF/aapp_data_files/OPS-LRS/external_libs/
  tarfile=fftw-3.0.1.tar.gz

  [ -s $tarfile ] || { echo "Downloading fftw-3.0.1.tar.gz"; wget ${url}${tarfile}; }
  [ -s $tarfile ] || { echo "Failed to download $tarfile"; exit 1; }

  cd $BUILD
  dir=${tarfile%.tar.gz}
  [ -d $dir ] || { echo "unpacking fftw"; tar -xzf $TAR/$tarfile; }

  cd $dir
  ./configure --prefix=$OPSLRS_EXT_INSTALL_DIR/fftw-3.0.1
  make || { echo "make failed for fftw-3.0.1"; exit 1; }
  make install || { echo "make install failed for fftw-3.0.1"; exit 1; }
  echo "Finished fftw-3.0.1 build"

fi

##############xerces
 
if [ $item = 7 ]; then

  cd $TAR
#  url=https://nwpsaf.eu/downloads/aapp_data_files/OPS-LRS/external_libs/
  url=ftp://ftp.eumetsat.int/pub/NWPSAF/aapp_data_files/OPS-LRS/external_libs/

  file=iostream.h        #missing from modern Linux distributions
  [ -s $file ] || { echo "Downloading iostream.h"; wget ${url}${file}; }

  tarfile=xerces-c-src1_7_0.tar.gz
  [ -s $tarfile ] || { echo "Downloading xerces-c-src1_7_0.tar.gz"; wget ${url}${tarfile}; }
  [ -s $tarfile ] || { echo "Failed to download $tarfile"; exit 1; }

  cd $BUILD
  dir=${tarfile%.tar.gz}
  [ -d $dir ] || { echo "unpacking xerces"; tar -xzf $TAR/$tarfile; }

  cp $TAR/iostream.h $dir/src/xercesc/util/NetAccessors/Socket
  cd $dir/src/xercesc/util/NetAccessors/Socket
  sed -i 's/#include <iostream.h>/#include "iostream.h"/' UnixHTTPURLInputStream.cpp
  
  cd $BUILD/$dir/src/xercesc
  export XERCESCROOT=$BUILD/$dir
  sh ./runConfigure -p linux -c gcc -x g++ -r pthread -P $OPSLRS_EXT_INSTALL_DIR/xerces-c-1.7.0
  make || { echo "make failed for xerces-c-src1_7_0"; exit 1; }
  make install || { echo "make install failed for xerces-c-src1_7_0"; exit 1; }
  echo "Finished xerces-c-src1_7_0 build"

fi  

##############flex
 
if [ $item = 8 ]; then

  flexmissing="$(gcc -lfl 2>&1 | grep 'cannot find')"
  if [ "$flexmissing" ]; then

    cd $TAR
    tarfile=flex-2-5-35.tar.gz      #note there is a problem building later versions at Met Office
    url=https://github.com/westes/flex/archive
    [ -s $tarfile ] || { echo "Downloading flex"; wget ${url}/${tarfile}; }

    cd $BUILD
    dir=flex-flex-2-5-35
    [ -d $dir ] || { echo "unpacking flex"; tar -xzf $TAR/$tarfile; }
    [ -d $dir ] || { echo "$dir not found, please check the flex tar file"; exit 1; }

    cd $dir
    ./autogen.sh
    ./configure --prefix=$OPSLRS_EXT_INSTALL_DIR/$dir
    make || { echo "make failed for $dir"; exit 1; }
    make install

    if [ -s $OPSLRS_EXT_INSTALL_DIR/$dir/lib/libfl.a ]; then
      echo "Finished flex build (you can ignore preceding error messages)"
    else
      echo "Failed to create libfl.a"
      exit 1
    fi

  else
    echo "libfl appears to be centrally installed"
  fi

fi

##############OPS-LRS version 8 

if [ $item = 9 ]; then

#This script unpacks the tar files currently on the NWPSAF server.

#Check the tar files

  cd $TAR
  tarfile=OPS_V8.0-AAPP-l-20180118.tgz
  [ -s $tarfile ] || { echo "Please put $tarfile in directory $OPSLRS_HOME"; exit 1; }

#Unpack the tar files

  cd $BUILD
  tar -xzf $TAR/$tarfile
  cd OPS_V8.0-AAPP-l-20180118

#Copy libfl.a if it has been created by previous step

  libfl=$OPSLRS_EXT_INSTALL_DIR/flex-flex-2-5-35/lib/libfl.a
  if [ -s $libfl ]; then
    cp $libfl src/EXT/env/lib
  fi

#Configure and make OPS-LRS

  case $FORTRAN_COMPILER in
    gfortran) arch=Linux-gfortran;;
    ifort)    arch=Linux-Intel;;
    *) echo "unsupported compiler"    #note: pgf90 not supported for OPS-LRS
       exit 1;;
  esac
  if [ $arch = Linux-Intel ]; then    #if ifort is selected, use icc if available
    icc --version >/dev/null 2>/dev/null
    [ $? = 0 ] && arch=Linux-Intel-icc
  fi

  ./configure --aapp-prefix=$INSTALL/AAPP_$AAPP_VERSION \
    --xrcs-prefix=$OPSLRS_EXT_INSTALL_DIR/xerces-c-1.7.0 \
    --fftw-prefix=$OPSLRS_EXT_INSTALL_DIR/fftw-3.0.1 \
    --prefix=$OPSLRS_INSTALL_DIR \
    --arch=$arch \
    --optimize=normal \
    --site-id=$SITE_ID \
    --nthreads=$NTHREADS

  echo "Building OPS-LRS ..."
  make || { echo "OPS-LRS make failed"; exit 1; }
  make install || { echo "OPS-LRS make install failed"; exit 1; }
  
  echo "Finished OPS-LRS build"  
  
fi  

##############OPS-LRS aux files 

if [ $item = 10 ]; then

  cd $OPSLRS_INSTALL_DIR
  script=get_aux_files.sh
#  url=https://nwpsaf.eu/downloads/aapp_data_files/OPS-LRS/aux_data/
  url=ftp://ftp.eumetsat.int/pub/NWPSAF/aapp_data_files/OPS-LRS/aux_data/
  [ -s $script ] || { echo "Downloading $script"; wget ${url}/${script}; }
  chmod +x $script

  dir=$OPSLRS_INSTALL_DIR/aux
  mkdir -p $dir

  echo "Downloading the aux files into $dir"
  ./get_aux_files.sh $dir
  echo "Finished downloading the aux files into $dir"
  echo "Note: you should run get_aux_files.sh periodically to check for updates,"
  echo "and monitor https://nwpsaf.eu/site/forums/forum/aapp/announcements/"
fi  
