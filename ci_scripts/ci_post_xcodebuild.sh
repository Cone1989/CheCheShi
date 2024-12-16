#!/bin/sh

# 这个脚本在编译之后调用，即便xcodebuild命令失败也会调用。
# 在这里上传打包的产物等等操作

if [[ $CI_WORKFLOW == "Testing" ]]; then
    (./sonarqube/run_sonar_analysis.sh $SONAR_TOKEN "true" "$CI_WORKSPACE_PATH/repository" $CI_BRANCH $CI_RESULT_BUNDLE_PATH)
fi
