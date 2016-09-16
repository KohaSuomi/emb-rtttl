#!/bin/bash -x

op=$1

app_dir=`pwd`
cd $app_dir
buildDir="./cbuild"
clib="./clib"
lib="./lib"
csharedDir="/usr/lib"

function compile {
  gccWiringPiDeps="-lwiringPi -lpthread"

  ##BUILD Perl XS madness using handy dandy swig <3
  mkdir -p $buildDir
  cp -r $clib/* $buildDir/
  cd $buildDir

  swig -perl5 XS.i

  gcc -c `perl -MConfig -e 'print join(" ", @Config{qw(ccflags optimize cccdlflags)}, \
        "-I$Config{archlib}/CORE")'` XS.c XS_wrap.c $gccWiringPiDeps

  gcc `perl -MConfig -e 'print $Config{lddlflags}'` XS.o XS_wrap.o -o XS.so $gccWiringPiDeps

  cd $app_dir
  cp $buildDir/XS.pm $lib/RTTTL/
  cp $buildDir/XS.so $lib/RTTTL/

  rm -r $buildDir
}
function link {
  cp $lib/RTTTL/XS.so $csharedDir/XS.so
}
function unlink {
  rm $csharedDir/XS.so
}

if [ $op == compile ]
then
  compile
elif [ "$op" == "link" ]
then
  link
elif [ "$op" == "unlink" ]
then
  unlink
else
  compile
  link
fi
