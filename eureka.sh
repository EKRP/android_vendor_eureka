#!/bin/bash
##########################################################################
function getSize()
{
    if [ -f $1 ]; then
        echo $(du -sh $1)
    else
        echo "N/A"
    fi;
}

# Variables
BUILD_DATE=$(date +"%m%d%Y")
BUILD_TIME=$(date "+%H%M%S")
EK_VENDOR=vendor/eureka
EK_OUT=$OUT
EK_WORK_DIR=$(pwd)/zip
EK_META_DATA_DIR=$(pwd)/zip/META-INF
RECOVERY_IMG=$(pwd)/out/target/product/$(cut -d'_' -f2-3 <<<$TARGET_PRODUCT)/recovery.img
EK_DEVICE=$(cut -d'_' -f2-3 <<<$TARGET_PRODUCT)
ENV_FILE=$(pwd)/build/make/core/envsetup.mk
EK_VERSION=$(grep -o "EKRP_VERSION := .*" $ENV_FILE | sed 's/EKRP_VERSION := //'g)
EK_TYPE=$(grep -o "EKRP_TYPE := .*" $ENV_FILE | sed 's/EKRP_TYPE := //'g)

ZIP_NAME=EK-$EK_VERSION-$EK_TYPE-$EK_DEVICE-$BUILD_DATE-$BUILD_TIME

if [ -d "$EK_META_DATA_DIR" ]; then
        rm -rf "$EK_META_DATA_DIR"
        rm -rf "$EK_OUT"/*.zip
fi
mkdir -p "$EK_WORK_DIR/addons"
cp -a $EK_VENDOR/addons/. $EK_WORK_DIR/addons
mkdir -p "$EK_WORK_DIR/META-INF/com/google/android"

#create updater-script before packing ZIP..
  cat > "$EK_WORK_DIR/META-INF/com/google/android/updater-script" <<EOF
show_progress(1.000000, 0);
ui_print(" ");
ui_print(" ** Eureka Recovery Project **");
ui_print("MWNNNNNNNNNNNNNNWMN;cWNNNNNMWc");
ui_print("MO:::::::::::::dW0.xM0:::lXX'");
ui_print("MO:::lOOOOOOOOKWd.0Wx:::dW0.");
ui_print("MO:::dMkddddddd;;NNl:::kWx");
ui_print("MO:::dMdccccc' oWKc::cKWl");
ui_print("MO:::l0000KMK.OMO:::cXN;");
ui_print("MO::::::::NX xMO::::XW'");
ui_print("MO:::oXXXXXMK.kMk:::cKN;");
ui_print("MO:::dMdccccc, lN0c:::OWo");
ui_print("MO:::dM0OOOOOkkl,NNl:::dNO");
ui_print("MO:::lkkkkkkkkKMk.OWd:::lXX'");
ui_print("MO:::::::::::::xWX'dWO::::ONc");
ui_print("MWNNNNNNNNNNNNNNWMW::NNNNNNWMx");
ui_print(" ");
ui_print("[DEVICE]: $EK_DEVICE");
ui_print("[VERSION]: $EK_VERSION");
ui_print("[BUILDTYPE]: $EK_TYPE");
delete_recursive("/sdcard/addons");
package_extract_dir("addons", "/sdcard/addons");
set_progress(0.500000);
package_extract_file("ekrp.img", "/dev/block/by-name/recovery");
set_progress(0.700000);
ui_print(" ");
ui_print("Eureka Recovery Installer Completed!");
ui_print(" ");
ui_print("You can now restart into Eureka Recovery.");
ui_print(" ");
set_progress(1.000000);
EOF
  cp -R "$EK_VENDOR/updater/update-binary" "$EK_WORK_DIR/META-INF/com/google/android/update-binary"
  cp "$RECOVERY_IMG" "$EK_WORK_DIR"
  mv "$EK_WORK_DIR/recovery.img" "$EK_WORK_DIR/ekrp.img"

cd $EK_WORK_DIR
rm -rf *.zip
zip -qr ${ZIP_NAME}.zip *

ZIPFILE=$(pwd)$EK_OUT/$ZIP_NAME.zip
ZIPFILE_SHA1=$(sha1sum -b $ZIPFILE)
ZIPFILE_MD5=$(echo -n $ZIPFILE | md5sum | cut -d '-' -f1)

# CLEANUP
rm "$EK_WORK_DIR/ekrp.img"
rm -rf "$EK_WORK_DIR/addons"
rm -rf "$EK_WORK_DIR/META-INF"

#Build Done Result..
echo ""
echo "MWNNNNNNNNNNNNNNWMN;cWNNNNNMWc"
echo "MO:::::::::::::dW0.xM0:::lXX'"
echo "MO:::lOOOOOOOOKWd.0Wx:::dW0."
echo "MO:::dMkddddddd;;NNl:::kWx"
echo "MO:::dMdccccc' oWKc::cKWl"
echo "MO:::l0000KMK.OMO:::cXN;"
echo "MO::::::::NX xMO::::XW'"
echo "MO:::oXXXXXMK.kMk:::cKN;"
echo "MO:::dMdccccc, lN0c:::OWo"
echo "MO:::dM0OOOOOkkl,NNl:::dNO"
echo "MO:::lkkkkkkkkKMk.OWd:::lXX'"
echo "MO:::::::::::::xWX'dWO::::ONc"
echo "MWNNNNNNNNNNNNNNWMW::NNNNNNWMx"
echo ""
echo "** Eureka Recovery Project **"
echo "============================="
echo "DEVICE: $EK_DEVICE"
echo "VERSION: $EK_VERSION"
echo "BUILDTYPE: $EK_TYPE"
echo "-----------------------------"
echo "File Info"
echo "========="
echo "ZIP: $ZIP_NAME.zip"
echo "OUT: ${PWD##*/}/$ZIP_NAME.zip"
echo "SIZE: $(getSize $ZIPFILE)"
echo "-----------------------------"
echo "CHECKSUMS"
echo "========="
echo "SHA1: ${ZIPFILE_SHA1:0:40}"
echo "MD5: ${ZIPFILE_MD5}"
echo ""
echo "############BUILD DONE!############"
