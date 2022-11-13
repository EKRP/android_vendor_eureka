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
EK_VERSION="1.0"
EK_TYPE="COMMUNITY"

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
ui_print("             ");
ui_print("Eureka Recovery Project                  ");
ui_print("[DEVICE]: $EK_DEVICE");
ui_print("[VERSION]: $EK_VERSION    ");
delete_recursive("/sdcard/addons");
package_extract_dir("addons", "/sdcard/addons");
set_progress(0.500000);
package_extract_file("recovery.img", "/dev/block/by-name/recovery");
set_progress(0.700000);
ui_print("                                                  ");
ui_print("Eureka Recovery Installer Completed!");
set_progress(1.000000);
EOF
  cp -R "$EK_VENDOR/updater/update-binary" "$EK_WORK_DIR/META-INF/com/google/android/update-binary"
  cp "$RECOVERY_IMG" "$EK_WORK_DIR"

echo -e "Create ZIP ..."
echo -e ""
cd $EK_WORK_DIR
zip -r ${ZIP_NAME}.zip *

ZIPFILE=$(pwd)/$EK_OUT/$ZIP_NAME.zip
ZIPFILE_SHA1=$(sha1sum -b $ZIPFILE)
ZIPFILE_MD5=$(echo -n $ZIPFILE | md5sum | cut -d '-' -f1)

#Build Done Result..
echo ""
echo "Eureka Recovery Project"
echo "======================="
echo "DEVICE: $EK_DEVICE"
echo "VERSION: $EK_VERSION"
echo "-----------------------"
echo "File Info"
echo "========="
echo "ZIP: $ZIP_NAME.zip"
echo "OUT: ${PWD##*/}/$ZIP_NAME.zip"
echo "SIZE: $(getSize $ZIPFILE)"
echo "-----------------------"
echo "CHECKSUMS"
echo "========="
echo "SHA1: ${ZIPFILE_SHA1:0:40}"
echo "MD5: ${ZIPFILE_MD5}"
echo ""
echo "############BUILD DONE!############"
