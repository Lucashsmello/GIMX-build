#!/bin/bash

VERSION=`cat version`
DATE=`date -R`
BRANCH="master"

echo "Version number? (default: "$VERSION")"

read NEW_VERSION

if [ -z $NEW_VERSION ]
then
  NEW_VERSION=$VERSION
fi

if [ -z $NEW_VERSION ]
then
  echo No version specified!
  exit
fi

echo $NEW_VERSION > version

if test -f cpu
then
  CPU=$(./cpu)
else
  CPU=1
fi

#checkout & compile GIMX
echo Clean previous build.
rm -rf GIMX
git clone -b $BRANCH --single-branch --depth 1 https://github.com/matlo/GIMX.git

MAJOR=$(echo $NEW_VERSION | awk -F"." '{print $1}')
MINOR=$(echo $NEW_VERSION | awk -F"." '{print $2}')
echo Major release number: $MAJOR
echo Minor release number: $MINOR
if [ -z $MAJOR ] || [ -z $MINOR ]
then
  echo Invalid release number!
  exit
fi

sed -i "s/FILEVERSION[ ]*[0-9]*,[0-9]*,[0-9]*,[0-9]*/FILEVERSION   $MAJOR,$MINOR,0,0/" GIMX/*/*.rc
sed -i "s/PRODUCTVERSION[ ]*[0-9]*,[0-9]*,[0-9]*,[0-9]*/PRODUCTVERSION  $MAJOR,$MINOR,0,0/" GIMX/*/*.rc
sed -i "s/[ ]*VALUE[ ]*\"FileVersion\",[ ]*\"[0-9]*.[0-9]*\"/    VALUE \"FileVersion\", \"$MAJOR.$MINOR\"/" GIMX/*/*.rc
sed -i "s/[ ]*VALUE[ ]*\"ProductVersion\",[ ]*\"[0-9]*.[0-9]*\"/    VALUE \"ProductVersion\", \"$MAJOR.$MINOR\"/" GIMX/*/*.rc

sed -i "s/#define[ ]*INFO_VERSION[ ]*\"[0-9]*.[0-9]*\"/#define INFO_VERSION \"$MAJOR.$MINOR\"/" GIMX/info.h
sed -i "s/#define[ ]*INFO_YEAR[ ]*\"2010-[0-9]*\"/#define INFO_YEAR \"2010-$(DATE '+%Y')\"/" GIMX/info.h

sed -i "s/#define[ ]*MyAppVersion[ ]*\"[0-9]*.[0-9]*\"/#define MyAppVersion \"$MAJOR.$MINOR\"/" inno.iss

make -C GIMX -j $CPU install

INNO_OPTIONS=""

TOOLS_DIR="tools"

TOOLS_USBDK_DIR="$TOOLS_DIR/usbdk"

USBDK_VERSION="1.0.12"
USBDK_PRODUCT_CODE_X64="{2D9B7372-C3A9-4C50-9149-058EF0CF512B}"
USBDK_PRODUCT_CODE_X86="{296A4498-8BC3-4212-8E37-6B8ADFF9399B}"
USBDK_MSI_X64="UsbDk_${USBDK_VERSION}_x64.msi"
USBDK_MSI_X86="UsbDk_${USBDK_VERSION}_x86.msi"

sed -i "s/#define[ ]*UsbdkVersion[ ]*\"[0-9]*.[0-9]*.[0-9]*\"/#define UsbdkVersion \"${USBDK_VERSION}\"/" inno.iss
sed -i "s/#define[ ]*UsbdkAppIdx64[ ]*\"{.*}\"/#define UsbdkAppIdx64 \"${USBDK_PRODUCT_CODE_X64}\"/" inno.iss
sed -i "s/#define[ ]*UsbdkAppIdx86[ ]*\"{.*}\"/#define UsbdkAppIdx86 \"${USBDK_PRODUCT_CODE_X86}\"/" inno.iss

if [ "$MSYSTEM" == "MINGW64" ]
then
  export MSYS2_ARG_CONV_EXCL="/dW64"
  INNO_OPTIONS+="/dW64"
fi

mkdir -p $TOOLS_USBDK_DIR

if ! test -f $TOOLS_USBDK_DIR/$USBDK_MSI_X64
then
  wget http://www.spice-space.org/download/windows/usbdk/$USBDK_MSI_X64 -O $TOOLS_USBDK_DIR/$USBDK_MSI_X64
fi

if [ "$MSYSTEM" == "MINGW32" ]
then
  if ! test -f $TOOLS_USBDK_DIR/$USBDK_MSI_X86
  then
    wget http://www.spice-space.org/download/windows/usbdk/$USBDK_MSI_X86 -O $TOOLS_USBDK_DIR/$USBDK_MSI_X86
  fi
fi

CP210X_ZIP="CP210x_VCP_Windows.zip"

CP210X_PRODUCT_CODE="F189C013BFD9D0C73BEC97AD2CFF0CF7CAD1E670"
sed -i "s/#define[ ]*SilabsCP210xAppId[ ]*\"{.*}\"/#define SilabsCP210xAppId \"${CP210X_PRODUCT_CODE}\"/" inno.iss

if ! test -f $TOOLS_DIR/$CP210X_ZIP
then
  cd tools
  wget http://gimx.fr/download/CP210x_VCP_Windows -O $CP210X_ZIP
  mkdir -p CP210x_VCP_Windows
  cd CP210x_VCP_Windows
  unzip ../CP210x_VCP_Windows.zip
  cd ../..
fi

if test -f /c/Program\ Files\ \(x86\)/Inno\ Setup\ 5/ISCC.exe
then
  /c/Program\ Files\ \(x86\)/Inno\ Setup\ 5/ISCC.exe $INNO_OPTIONS inno.iss
else
  /c/Program\ Files/Inno\ Setup\ 5/ISCC.exe $INNO_OPTIONS inno.iss
fi

if [ "$MSYSTEM" == "MINGW32" ]
then
  mv gimx-$NEW_VERSION.exe gimx-$NEW_VERSION-i386.exe
else
  mv gimx-$NEW_VERSION.exe gimx-$NEW_VERSION-x86_64.exe
fi
