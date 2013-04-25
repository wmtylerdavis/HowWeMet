#!/bin/sh

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "rsync -rp ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -rp "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .xcdatamodeld`.momd"
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename $1 .xcdatamodeld`.momd"
      ;;
    *)
      echo "cp -R ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
      cp -R "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
      ;;
  esac
}
install_resource 'Facebook-iOS-SDK/src/FacebookSDKResources.bundle'
install_resource 'uservoice-iphone-sdk/Resources/en.lproj'
install_resource 'uservoice-iphone-sdk/Resources/fr.lproj'
install_resource 'uservoice-iphone-sdk/Resources/it.lproj'
install_resource 'uservoice-iphone-sdk/Resources/nl.lproj'
install_resource 'uservoice-iphone-sdk/Resources/uv_article.png'
install_resource 'uservoice-iphone-sdk/Resources/uv_article@2x.png'
install_resource 'uservoice-iphone-sdk/Resources/uv_default_avatar.png'
install_resource 'uservoice-iphone-sdk/Resources/uv_default_avatar@2x.png'
install_resource 'uservoice-iphone-sdk/Resources/uv_idea.png'
install_resource 'uservoice-iphone-sdk/Resources/uv_idea@2x.png'
install_resource 'uservoice-iphone-sdk/Resources/uv_logo.png'
install_resource 'uservoice-iphone-sdk/Resources/uv_logo@2x.png'
install_resource 'uservoice-iphone-sdk/Resources/uv_vote_chicklet.png'
install_resource 'uservoice-iphone-sdk/Resources/uv_vote_chicklet@2x.png'
install_resource 'uservoice-iphone-sdk/Resources/uv_vote_chicklet_empty.png'
install_resource 'uservoice-iphone-sdk/Resources/uv_vote_chicklet_empty@2x.png'
install_resource 'uservoice-iphone-sdk/Resources/uv_x.png'
install_resource 'uservoice-iphone-sdk/Resources/uv_x@2x.png'
install_resource 'uservoice-iphone-sdk/Resources/zh-Hant.lproj'
