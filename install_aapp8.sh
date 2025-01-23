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
#           AAPP_8.12
#           opslrs
#           kai
#     build
#           bufrdc_000409
#           eccodes-2.27.1-Source
#           eccodes_build
#           hdf5-1.10.1
#           AAPP_8.12
#           OPS_V8.4-AAPP-l-20211216
#           xerces-c-src1_7_0
#           fftw-3.0.1
#           gettext-0.19.8.1 [if autopoint is not already installed]
#           flex-flex-2.5.39 [if libfl.a is not already installed]
#           kai-1.12
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
# the ecCodes library.
#
# 01/11/2017 NCA
# 22/01/2017 Update
# 31/01/2017 Add -lhdf5_hl -lhdf5_fortran in the AAPP configure step
# 23/02/2018 Update for OPS-LRS v8.0
# 27/09/2018 AAPP v8.2; ecCodes v2.8.2; update url for aapp_data_files
# 20/12/2018 AAPP v8.3; ecCodes v2.10.0
# 18/04/2019 AAPP v8.4; eccodes v2.12.0. Include autopoint (from gettext),
#            which is a prerequisite for building flex
# 05/12/2019 Add comment in bufrdc build; use eccodes v2.15.0.
# 09/12/2019 AAPP v8.5; check cmake version is sufficient for ecCodes
# 06/02/2020 Correction to cmake version checking
# 12/08/2020 AAPP v8.6; flex 2.5.39 (as 2.5.35 is no longer available); eccodes v2.18.0
# 03/09/2020 Port to nwp-saf.eumetsat.int
# 04/02/2021 AAPP v8.7
# 02/08/2021 AAPP v8.8, ecCodes 2.22.1
# 16/09/2021 Add --no-check-certificate in calls to wget for BUFRDC and ecCodes (BoM suggestion)
# 22/09/2021 Modify OPS-LRS "configure" script for compatibility with perl 5.26 and later. Add some error traps.
# 15/12/2021 Update url for BUFRDC and ecCodes; use ecCodes 2.24.0
# 07/02/2022 Add kai option. AAPP v8.9; OPS_V8.4-AAPP-l-20211216; ecCodes 2.24.2
# 30/06/2022 AAPP v8.10; ecCodes 2.26.0
# 12/10/2022 Test whether aec is installed (turned on by default in ecCodes >=2.25.0)
# 05/01/2023 AAPP v8.11; ecCodes 2.27.1
# 07/08/2023 AAPP v8.12. By default we have left ecCodes at 2.27.1, but the user may wish to
#            update to 2.31.0 provided they have a suitable C++ compiler; this script checks
#            compatibility.
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
  echo "  8 for flex and autopoint (checks whether they are centrally installed)"
  echo "  9 for OPS-LRS"
  echo " 10 for current set of OPS-LRS auxiliary files"
  echo " 11 for kai"
}

item=$1
[ $item ] || { usage; exit 1; }

AAPP_VERSION=8.12           #to correspond with the name of the AAPP tar file
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
INSTALL=/opt/aapp/AAPP_8.12

mkdir -p $TAR $BUILD $INSTALL

HDF5_INSTALL_DIR=$INSTALL/hdf5
BUFRDC_INSTALL_DIR=$INSTALL/bufrdc
ECCODES_INSTALL_DIR=$INSTALL/eccodes
AAPP_INSTALL_DIR=$INSTALL/AAPP_$AAPP_VERSION
OPSLRS_EXT_INSTALL_DIR=$INSTALL/opslrs
OPSLRS_INSTALL_DIR=$INSTALL/opslrs
KAI_INSTALL_DIR=$INSTALL/kai

mkdir -p $HDF5_INSTALL_DIR $BUFRDC_INSTALL_DIR $ECCODES_INSTALL_DIR 
mkdir -p $OPSLRS_EXT_INSTALL_DIR $OPSLRS_INSTALL_DIR $AAPP_INSTALL_DIR $KAI_INSTALL_DIR


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
# see https://confluence.ecmwf.int/display/BUFR/BUFRDC+Home

if [ $item = 2 ]; then
  
  cd $TAR
  tarfile=bufrdc_000409.tar.gz
  url="https://confluence.ecmwf.int/download/attachments/35752466/"
  [ -s $tarfile ] || { echo "Downloading BUFRDC"; wget --no-check-certificate ${url}${tarfile}; }
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
  echo 'If you saw an error in the step "./test.sh", this can be ignored as it is not critical for AAPP' 

fi

##############ecCodes
# Note: you may have to check the download url is still valid, 
# see https://confluence.ecmwf.int/display/ECC/Releases
# In general, you should use the latest available release of ecCodes.

if [ $item = 3 ]; then

  ecversion=2.27.1

  set $(IFS=.; echo $ecversion)
  ec1=$1
  ec2=$2

  echo "Checking g++ requirements for ecCodes v$ecversion..."

#ecCodes 2.29.0 requires C++11 (g++ v4.8.1)
#ecCodes 2.31.0 requires C++17 (g++ v8)

  if [[ $ec1 -gt 2 || $ec1 -eq 2 && $ec2 -ge 29 ]]; then
    set $(g++ --version) || { echo "Error: g++ is needed for ecCodes from v2.29 but cannot be run"; exit 1; }
    gppversion=$3
    if [[ $ec1 -gt 2 || $ec1 -eq 2 && $ec2 -ge 31 ]]; then
      set $(IFS=.; echo $gppversion)
      gpp1=$1
      if [[ $gpp1 -lt 8 ]]; then
        echo "Error: g++ v8 or higher (supporting C++17) is needed for ecCodes from v2.31, found $gppversion"
        exit 1
      fi
      echo "... g++ v$gppversion is OK"
    else
      echo "... g++ v$gppversion is OK"
    fi
  else
    echo "... not required"
  fi

  echo "Checking cmake requirements for ecCodes v$ecversion..."

#ecCodes 2.13.0 requires cmake 3.6
#ecCodes 2.19.0 requires cmake 3.12

  set $(cmake --version) || { echo "Error: cannot run cmake"; exit 1; }
  cmakev=${3}
  set $(IFS=.; echo $cmakev)
  cmake1=$1
  cmake2=$2

  if [[ $ec1 -eq 2 && $ec2 -ge 13 && $ec2 -lt 19 ]]; then
    if [[ $cmake1 -lt 3 || $cmake1 -eq 3 && $cmake2 -lt 6 ]]; then
      echo "Error: cmake version $cmakev is <3.6.0; you will not be able to build eccodes v2.13.0 or later"
      echo "Recommend to install a recent cmake (v3.6.0 or higher), or modify this script to set ecversion=2.12.5"
      exit 1
    else
      echo "... cmake v$cmakev is OK"
    fi
  elif [[ $ec1 -gt 2 || $ec1 -eq 2 && $ec2 -ge 19 ]]; then
    if [[ $cmake1 -lt 3 || $cmake1 -eq 3 && $cmake2 -lt 12 ]]; then
      echo "Error: cmake version $cmakev is <3.12.0; you will not be able to build eccodes v2.19.0 or later"
      echo "Recommend to install a recent cmake (v3.12.0 or higher), or modify this script to set ecversion=2.18.0"
      exit 1
    else
      echo "... cmake v$cmakev is OK"
    fi
  fi  

  cd $TAR
  tarfile=eccodes-${ecversion}-Source.tar.gz
  url="https://confluence.ecmwf.int/download/attachments/45757960/"
  [ -s $tarfile ] || { echo "Downloading ecCodes"; wget --no-check-certificate ${url}${tarfile}; }
  [ -s $tarfile ] || { echo "Failed to download $tarfile"; exit 1; }

  cd $BUILD
  dir=${tarfile%.tar.gz}
  [ -d $dir ] || { echo "unpacking ecCodes"; tar -xzf $TAR/$tarfile; }

  echo "Building ecCodes ..."

  mkdir -p eccodes_build
  cd eccodes_build
  [ $(aec 2>/dev/null; echo $?) -le 1 ] || aecflag="-DENABLE_AEC=OFF"   #test whether Adaptive Entropy Encoding is available

  cmake \
    -DCMAKE_INSTALL_PREFIX=${ECCODES_INSTALL_DIR} \
    -DCMAKE_Fortran_COMPILER=${FORTRAN_COMPILER} $aecflag \
    $BUILD/$dir
  make || { echo "problem with ecCodes make"; exit 1; }
  make install >install.out || { echo "problem with ecCodes make install"; exit 1; }
  if [ ! -d ${ECCODES_INSTALL_DIR}/lib ] && [ -d ${ECCODES_INSTALL_DIR}/lib64 ]; then
    (cd ${ECCODES_INSTALL_DIR}; ln -s lib64 lib)
  fi
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
  set -x
  ./configure --station=$STATION --fortran-compiler=$FORTRAN_COMPILER --site-id=$SITE_ID \
    --external-libs="-L$BUFRDC_INSTALL_DIR -lbufr -L$ECCODES_INSTALL_DIR/lib -leccodes_f90 -leccodes -L$HDF5_INSTALL_DIR/lib -lhdf5 -lhdf5_hl -lhdf5_fortran -lhdf5hl_fortran" \
    --external-includes="-I$HDF5_INSTALL_DIR/include -I$ECCODES_INSTALL_DIR/include" \
    --prefix=$AAPP_INSTALL_DIR
  status=$?
  set +x

  if [ $status != 0 ]; then
    echo "Error: AAPP configure failed"
    exit 1
  fi

#set up LD_LIBRARY_PATH in ATOVS_ENV8
  sed -i s#DIR_HDF5=#DIR_HDF5=$HDF5_INSTALL_DIR# ATOVS_ENV8
  sed -i s#DIR_ECCODES=#DIR_ECCODES=$ECCODES_INSTALL_DIR# ATOVS_ENV8

  echo "Building AAPP ..."
  make >make.out 2>make.err || { echo "AAPP make failed"; exit 1; }
  make install || { echo "AAPP make install failed"; exit 1; }

#Make sure the installed AVHRR vis cal files have the original date, not the installation date.
#(They will get updated from the internet when you run avh_get_vis_coefs).
  cp -p AAPP/src/calibration/libavhrcl/*.txt $AAPP_INSTALL_DIR/AAPP/data/calibration/coef/avhcl

  echo "Finished AAPP build"

fi
  
##############AAPP MAIA4 data

if [ $item = 5 ]; then

  cd $TAR
  url=https://nwp-saf.eumetsat.int/downloads/aapp_data_files/maia_data_files/

  tarfile=AAPP_MAIA4_thresholds_v8.tgz
  [ -s $tarfile ] || { echo "Downloading $tarfile"; wget ${url}${tarfile}; }
  [ -s $tarfile ] || { echo "Problem downloading $tarfile"; exit 1; }
  tarfile=AAPP_MAIA4_atlas.tgz
  [ -s $tarfile ] || { echo "Downloading $tarfile"; wget ${url}${tarfile}; }
  [ -s $tarfile ] || { echo "Problem downloading $tarfile"; exit 1; }
  tarfile=AAPP_MAIA4_atlas_extra.tgz
  [ -s $tarfile ] || { echo "Downloading $tarfile"; wget ${url}${tarfile}; }
  [ -s $tarfile ] || { echo "Problem downloading $tarfile"; exit 1; }
  cd $AAPP_INSTALL_DIR
  [ -d AAPP/data_maia4/thresholds ] || { echo "Unpacking thresholds"; tar -xzf $TAR/AAPP_MAIA4_thresholds_v8.tgz; }
  [ -d AAPP/data_maia4/atlas ] || { echo "Unpacking atlas"; tar -xzf $TAR/AAPP_MAIA4_atlas.tgz; }
  [ -f AAPP/data_maia4/atlas/ecmwf_grib_surface.grb ] || { echo "Unpacking atlas_extra"; tar -xzf $TAR/AAPP_MAIA4_atlas_extra.tgz; }

fi

##############fftw
 
if [ $item = 6 ]; then

  cd $TAR
  url=https://nwp-saf.eumetsat.int/downloads/aapp_data_files/OPS-LRS/external_libs/
  tarfile=fftw-3.0.1.tar.gz

  [ -s $tarfile ] || { echo "Downloading fftw-3.0.1.tar.gz"; wget ${url}${tarfile}; }
  [ -s $tarfile ] || { echo "Failed to download $tarfile"; exit 1; }

  cd $BUILD
  dir=${tarfile%.tar.gz}
  [ -d $dir ] || { echo "unpacking fftw"; tar -xzf $TAR/$tarfile; }

  cd $dir
  ./configure --prefix=$OPSLRS_EXT_INSTALL_DIR/fftw-3.0.1 || { echo "problem with fftw configure"; exit 1; }
  make || { echo "make failed for fftw-3.0.1"; exit 1; }
  make install || { echo "make install failed for fftw-3.0.1"; exit 1; }
  echo "Finished fftw-3.0.1 build"

fi

##############xerces
 
if [ $item = 7 ]; then

  cd $TAR
  url=https://nwp-saf.eumetsat.int/downloads/aapp_data_files/OPS-LRS/external_libs/

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
 
flexdir=flex-flex-2.5.39        #used by items 8 and 9

if [ $item = 8 ]; then

  flexmissing="$(gcc -lfl 2>&1 | grep 'cannot find')"
  if [ "$flexmissing" ]; then
    echo "flex is not centrally installed"
    if [ -s $OPSLRS_EXT_INSTALL_DIR/$flexdir/lib/libfl.a ]; then
      echo "but found at $OPSLRS_EXT_INSTALL_DIR/$flexdir/lib/libfl.a"
      flexmissing=
    fi
  fi

  if [ "$flexmissing" ]; then
  
#Flex install requires autopoint, which is part of gettext, see https://www.gnu.org/software/gettext/
#  http://ftp.gnu.org/pub/gnu/gettext/gettext-0.19.8.1.tar.gz

    autopointv="$(autopoint --version)"
    if [ $? != 0 ]; then
      echo "autopoint is not in the default PATH"
      url=http://ftp.gnu.org/pub/gnu/gettext
      tarfile=gettext-0.19.8.1.tar.gz
      dir=gettext-0.19.8.1
      if [ ! -x $OPSLRS_EXT_INSTALL_DIR/$dir/bin/autopoint ]; then
        echo "autopoint is a pre-requisite for flex: installing gettext"
        cd $TAR
        [ -s $tarfile ] || { echo "Downloading gettext"; wget ${url}/${tarfile}; }
        cd $BUILD
        [ -d $dir ] || { echo "unpacking gettext"; tar -xzf $TAR/$tarfile; }
        [ -d $dir ] || { echo "$dir not found, please check the gettext tar file"; exit 1; }
        cd $dir
        echo "configuring gettext"
        ./configure --prefix=$OPSLRS_EXT_INSTALL_DIR/$dir || { echo "problem with gettext configure"; exit 1; }
        echo "building gettext"
        make || { echo "make failed for $dir"; exit 1; }
        make install
      else
        echo "found autopoint at $OPSLRS_EXT_INSTALL_DIR/$dir/bin"
      fi
      echo "adding to PATH: $OPSLRS_EXT_INSTALL_DIR/$dir/bin"
      PATH=$OPSLRS_EXT_INSTALL_DIR/$dir/bin:$PATH
      autopointv="$(autopoint --version)" || { echo "autopoint still not found; need to troubleshoot"; exit 1; }
    fi

#Flex releases are linked from https://github.com/westes/flex/releases, e.g.
#  https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz
#  https://github.com/westes/flex/archive/flex-2.5.39.tar.gz
#  https://github.com/westes/flex/archive/v2.6.0.tar.gz
#For OPS-LRS it may be safest to use an old release. 

    cd $TAR
    url=https://github.com/westes/flex/archive
    tarfile=flex-2.5.39.tar.gz
    dir=$flexdir

    [ -s $tarfile ] || { echo "Downloading flex"; wget ${url}/${tarfile}; }

    cd $BUILD
    [ -d $dir ] || { echo "unpacking flex"; tar -xzf $TAR/$tarfile; }
    [ -d $dir ] || { echo "$dir not found, please check the flex tar file"; exit 1; }

    cd $dir
    echo "run autogen.sh in $PWD"
    ./autogen.sh
    echo "configure flex"
    ./configure --prefix=$OPSLRS_EXT_INSTALL_DIR/$dir || { echo "problem with flex configure"; exit 1; }
    echo "building flex"
    make || { echo "make failed for $dir"; exit 1; }
    make install

    if [ -s $OPSLRS_EXT_INSTALL_DIR/$dir/lib/libfl.a ]; then
      echo "Finished flex build (you can ignore preceding error messages)"
      echo "libfl.a has been created successfully"
    else
      echo "Failed to create libfl.a"
      exit 1
    fi

  else
    echo "libfl.a is installed"
  fi

fi

##############OPS-LRS version 8 

if [ $item = 9 ]; then

#This script unpacks the tar files currently on the NWPSAF server.

#Check the tar files

  cd $TAR
  tarfile=OPS_V8.4-AAPP-l-20211216.tgz
  [ -s $tarfile ] || { echo "Please put $tarfile in directory $TAR"; exit 1; }

#Unpack the tar files

  echo "Unpacking $TAR/$tarfile"
  cd $BUILD
  tar -xzf $TAR/$tarfile
  cd OPS_V8.4-AAPP-l-20211216

#Modify the configure script so that it works with perl 5.26 and later (see AAPP bugs page)
#Not needed for OPS_V8.4
#
#  echo "Modifying the OPS-LRS configure script"
#  cp -p configure configure_old
#  sed 's#do "config/$opts{arch}"#do "./config/$opts{arch}"#' configure_old >configure
#  diff configure configure_old

#Copy libfl.a if it has been created by previous step

  libfl=$OPSLRS_EXT_INSTALL_DIR/$flexdir/lib/libfl.a
  if [ -s $libfl ]; then
    echo "copying libfl.a"
    cp $libfl src/EXT/env/lib
  fi

#For gfortran, check whether libgfortranbegin.a is present. It is obsolete on modern systems.
#If not present, remove it from Linux-gfortran config file.

  if [ $FORTRAN_COMPILER = gfortran ]; then
    gfortranbeginmissing="$(gcc -lgfortranbegin 2>&1 | grep 'cannot find')"
    if [ "gfortranbeginmissing" ]; then
      echo "removing -lgfortranbegin from config/Linux-gfortran"
      sed -i 's/-lgfortranbegin//' config/Linux-gfortran
    fi
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
    if [ $? != 0 ]; then
      echo "Warning: Linux-Intel has been requested but icc is not available. Using Linux-gfortran instead"
      arch=Linux-gfortran
    fi
  fi

  echo "running the OPS-LRS configure script"
  set -x
  ./configure --aapp-prefix=$INSTALL/AAPP_$AAPP_VERSION \
    --xrcs-prefix=$OPSLRS_EXT_INSTALL_DIR/xerces-c-1.7.0 \
    --fftw-prefix=$OPSLRS_EXT_INSTALL_DIR/fftw-3.0.1 \
    --prefix=$OPSLRS_INSTALL_DIR \
    --arch=$arch \
    --optimize=normal \
    --site-id=$SITE_ID \
    --nthreads=$NTHREADS
  status=$?
  set +x

  if [ $status != 0 ]; then
    echo "Error: OPS-LRS configure failed"
    exit 1
  fi

  echo "Building OPS-LRS ..."
  make || { echo "OPS-LRS make failed"; exit 1; }
  make install || { echo "OPS-LRS make install failed"; exit 1; }
  
  echo "Finished OPS-LRS build"  
  
fi  

##############OPS-LRS aux files 

if [ $item = 10 ]; then

  cd $OPSLRS_INSTALL_DIR
  script=get_aux_files.sh
  url=https://nwp-saf.eumetsat.int/downloads/aapp_data_files/OPS-LRS/aux_data/
  [ -s $script ] || { echo "Downloading $script"; wget ${url}/${script}; }
  chmod +x $script

  dir=$OPSLRS_INSTALL_DIR/aux
  mkdir -p $dir

  echo "Downloading the aux files into $dir"
  ./get_aux_files.sh $dir
  echo "Finished downloading the aux files into $dir"
  echo "Note: you should run get_aux_files.sh periodically to check for updates,"
  echo "and monitor https://nwp-saf.eumetsat.int/site/forums/forum/aapp/announcements/"
fi  

#############kai 

if [ $item = 11 ]; then
  url=https://www.eumetsat.int/media/44334
  zipfile=kai-1.12.zip
  kdir=kai-1.12
  if [ ! -x $KAI_INSTALL_DIR/$kdir/bin/kai ]; then
    echo "installing kai"
    cd $TAR
    if [ ! -s $zipfile ]; then
      echo "Downloading kai"
      [ -s 44334 ] || wget --no-check-certificate $url
      url2=$(grep 'link rel="canonical"' 44334 | cut -d '"' -f 4)
      wget ${url2} || exit 1
    fi
    cd $BUILD
    [ -d $kdir ] || { echo "unpacking kai"; unzip $TAR/$zipfile; }
    [ -d $kdir ] || { echo "$kdir not found, please check the kai zip file"; exit 1; }
    cd $kdir
    echo "configuring kai"
    chmod +x configure
    ./configure --prefix=$KAI_INSTALL_DIR/$kdir || { echo "problem with kai configure"; exit 1; }
    echo "building kai"
    make || { echo "make failed for $kdir"; exit 1; }
    make install
  else
    echo "found kai at $KAI_INSTALL_DIR/$kdir/bin"
  fi
  if [ -f $AAPP_INSTALL_DIR/ATOVS_ENV8 ]; then
    . $AAPP_INSTALL_DIR/ATOVS_ENV8
    if [[ $PATH != *$KAI_INSTALL_DIR/$kdir/bin* ]]; then
      echo "updating PATH in $AAPP_INSTALL_DIR/ATOVS_ENV8"
      P_OLD=${PATH#*metop-tools/bin}              #ignore the first part of string in the substitution 
      P_NEW=${P_OLD}:$KAI_INSTALL_DIR/$kdir/bin
      sed -i "s|${P_OLD}|${P_NEW}|" $AAPP_INSTALL_DIR/ATOVS_ENV8
    fi
  fi
fi

