#!/bin/sh

# 编译数据目录
DERIVED_DATA_PATH=$1
# 工程目录
WORKSPACE_PATH=$2
# .xcodeproj文件所在目录
XCODE_PROJECT_FILE_PATH=$3
# 测试结果目录
CI_RESULT_BUNDLE_PATH=$4

# ci_scripts目录
CI_SCRIPTS_FOLDER="$WORKSPACE_PATH/ci_scripts"
# ci_scripts下Payload目录
PAYLOAD_FOLDER_PATH="$CI_SCRIPTS_FOLDER/Payload"

ZIP_FILENAME="Payload.zip"
IPA_FILENAME="Payload.ipa"

# 运行UI测试的scheme
# -scheme GumtreeUITests UI测试
# -project $XCODE_PROJECT_FILE_PATH 指定项目
# -destination generic/platform=iOS 指定编译平台
# -derivedDataPath $DERIVED_DATA_PATH 指定Derived Data生成路径
# -resultBundleVersion 3 指定结果对应文件的格式版本，3是新版Result Bundle格式，支持详细的输出
# -resultBundlePath $CI_RESULT_BUNDLE_PATH 指定结果保存的路径
# -IDEPostProgressNotifications=YES 启动进度通知，可以实时跟踪构建进度
# CODE_SIGN_IDENTITY=- 禁用签名，用于开发和测试环境
# AD_HOC_CODE_SIGNING_ALLOWED=YES 允许临时签名
# COMPILER_INDEX_STORE_ENABLE=NO 禁用索引存储功能，减少编译时间
# -hideShellScriptEnvironment 隐藏shell脚本的环境变量信息，防止输出敏感信息
xcodebuild build -scheme GumtreeUITests -project $XCODE_PROJECT_FILE_PATH -destination generic/platform=iOS -derivedDataPath $DERIVED_DATA_PATH -resultBundleVersion 3 -resultBundlePath $CI_RESULT_BUNDLE_PATH -IDEPostProgressNotifications=YES CODE_SIGN_IDENTITY=- AD_HOC_CODE_SIGNING_ALLOWED=YES COMPILER_INDEX_STORE_ENABLE=NO -hideShellScriptEnvironment


# ci_scripts目录下创建Payload文件夹
mkdir -p $PAYLOAD_FOLDER_PATH; chmod +x $PAYLOAD_FOLDER_PATH

# 拷贝编译后生成的.app到Payload文件夹下
cp -r $DERIVED_DATA_PATH/Build/Products/Debug-iphoneos/GumtreeUITests-Runner.app $PAYLOAD_FOLDER_PATH

# 进入ci_scripts目录下，压缩Payload文件夹，压缩为Payload.zip
cd $CI_SCRIPTS_FOLDER; zip --symlinks -r $ZIP_FILENAME Payload

# 把zip变为ipa
cd $CI_SCRIPTS_FOLDER; mv $ZIP_FILENAME $IPA_FILENAME

# 删除之前的Payload文件夹
rm -r $PAYLOAD_FOLDER_PATH


# 判断ipa是否生成成功
if [[ -f "$CI_SCRIPTS_FOLDER/Payload.ipa" ]]; then
    echo "Payload.ipa exists in $CI_SCRIPTS_FOLDER folder"
else
    echo "Payload.ipa file does not exist in $CI_SCRIPTS_FOLDER folder"
fi

# 删除编译产出的文件
rm -r $DERIVED_DATA_PATH

# 删除测试结果文件
rm -r $CI_RESULT_BUNDLE_PATH
