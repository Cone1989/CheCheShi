#!/bin/sh

# 这个在xcode cloud克隆代码后使用

set -e

# 更多环境变量，参考：https://developer.apple.com/documentation/xcode/environment-variable-reference
# 进入项目目录
cd $CI_PRIMARY_REPOSITORY_PATH

# 获取当前工作流的名称
# 这些工作流会在xcode和itunesConnect中显示，可以单独选一个开始执行。
# 目前GT支持的工作流有以下几种：
# - Overnight Build


if [[ $CI_WORKFLOW == "FirstWorkflow" ]]; then
    # 对于GT，如果workflow是Archive，那么执行UI测试
    # CI_DERIVED_DATA_PATH 编译目录
    # CI_WORKSPACE_PATH 项目目录
    # CI_PROJECT_FILE_PATH
    # CI_RESULT_BUNDLE_PATH 单测结果输入地址
    (./ci_scripts/lambdatest/generate_testsuite_ipa.sh $CI_DERIVED_DATA_PATH "$CI_WORKSPACE_PATH/repository" $CI_PROJECT_FILE_PATH $CI_RESULT_BUNDLE_PATH)
fi

echo "项目目录：$CI_PRIMARY_REPOSITORY_PATH"
echo "工作流名称：$CI_WORKFLOW"
echo "编译数据目录：$CI_DERIVED_DATA_PATH"
echo "工程目录：$CI_WORKSPACE_PATH"
echo "不知道是什么：$CI_PROJECT_FILE_PATH"
echo "测试结果目录：$CI_RESULT_BUNDLE_PATH"
