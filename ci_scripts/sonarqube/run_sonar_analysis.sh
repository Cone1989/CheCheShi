#!/bin/sh

# Set the -e flag to stop running the script if a command returns a nonzero exit code
set -e

# Injected Arguments
SONAR_LOGIN="$1"
IS_CI="$2"
MAIN_DIRECTORY="$3"
BRANCH_NAME="$4"
RESULT_BUNDLE_PATH="$5"

# Variables
TEST_OUTPUT_FOLDER="$MAIN_DIRECTORY/test_output"
COVERAGE_FILE="$TEST_OUTPUT_FOLDER/sonarqube-generic-coverage.xml" # Path to the code coverage file
REPO_NAME="CheCheShi" # Name of the repository

# Navigate to main directory
cd $MAIN_DIRECTORY

# Check out repo if CI
if [[ $IS_CI == "true" ]]; then
    REPO_URL="https://github.com/Cone1989" # Github URL (minus repo name)

    # Need to perform a GIT checkout again as it appears to wipe the repository folder after running the tests
    git clone $REPO_URL/$REPO_NAME.git
    cd $REPO_NAME; git checkout $BRANCH_NAME

    # Move all files one folder up
    mv *.* ..

    # Go back up one directory
    cd ..
fi

# Avoid running brew cleanup/auto-update automatically
export HOMEBREW_NO_INSTALL_CLEANUP=TRUE
export HOMEBREW_NO_AUTO_UPDATE=1

# Install Python (this is required as glib - one of SonarScanner's dependencies now requires Python)
brew install --build-from-source python@3.12

# Install Sonar Scanner
brew install sonar-scanner

# Install JQ
brew install jq

# Create test_output folder & allow write access
mkdir -p $TEST_OUTPUT_FOLDER
chmod +x $TEST_OUTPUT_FOLDER

# Generate code coverage in the correct format
$MAIN_DIRECTORY/ci_scripts/sonarqube/xccov_to_sonarqube_generic.sh $RESULT_BUNDLE_PATH > $COVERAGE_FILE

# Allow access to coverage file
chmod +x $COVERAGE_FILE

# Replace absolute path within coverage file to relative
pathToReplace="\\/Volumes\\/workspace\\/repository\\/"
replacementPath="$REPO_NAME\\/"

sed -i -e "s/$pathToReplace/$replacementPath/g" $COVERAGE_FILE

# Sonar properties
SONAR_PROJECT_KEY="Cone1989_CheCheShi"
SONAR_HOST_URL="https://sonarcloud.io"
SONAR_ORGANISATION="Cone1989"
SONAR_EXCLUSIONS="ci_scripts/**/*,ios-app/ci_scripts/**/*,/Volumes/workspace/DerivedData/*,test_output/**/*,*Test*.swift,**/GumtreeTests/**/*,**/GumtreeUITests/**/*,**/GumtreeSnapshotTests/**/*,**/GumtreePerformanceTests/**/*,**/sonarcloud/**/*,**\*.json,**\*.js,**\*.ts,**\*.html,**/*View.swift,**/*Sheet.swift,**/*ViewFactory.swift,**/*Page.swift,**/Debug/*,**/*Request.swift,**/*Protocol.swift,**/AppDelegate.swift,**/AppLauncher.swift,**/GumtreeApp.swift,**/*Screen.swift,**/Dependencies.swift,ios-app/Gumtree/Common/Extensions/CasePath.swift,**/ViewModifiers/**/*,**/Styles/**/*,**/Shapes/**/*,**/Mock/**/*,ios-app/Gumtree/Common/Wrappers/GTAnalytics.swift,ios-app/Gumtree/Common/Extensions/Image_Extensions.swift,ios-app/Gumtree/Common/UI/Models/DesignTokens/**,ios-app/Gumtree/Common/Extensions/Color_Extensions.swift,ios-app/Gumtree/Common/Extensions/UITabBarAppearance_Extensions.swift,ios-app/GumtreeNotificationCustomization/NotificationService.swift,ios-app/Gumtree/Common/Extensions/ScrollView_Extensions.swift"
SONAR_SOURCE_ENCODING="UTF-8"
SONAR_COVERAGE_REPORTS_PATH="$TEST_OUTPUT_FOLDER/sonarqube-generic-coverage.xml"

# Run Sonar command
if [ -z ${CI_PULL_REQUEST_NUMBER} ]; then
    # Branch
    sonar-scanner -Dsonar.branch.name="$BRANCH_NAME" \
    -Dsonar.projectKey="$SONAR_PROJECT_KEY" \
    -Dsonar.host.url="$SONAR_HOST_URL" \
    -Dsonar.organization="$SONAR_ORGANISATION" \
    -Dsonar.login="$SONAR_LOGIN" \
    -Dsonar.c.file.suffixes=- \
    -Dsonar.cpp.file.suffixes=- \
    -Dsonar.objc.file.suffixes=- \
    -Dsonar.sources=. \
    -Dsonar.exclusions="$SONAR_EXCLUSIONS" \
    -Dsonar.junit.reportsPath="$TEST_OUTPUT_FOLDER" \
    -Dsonar.sourceEncoding="$SONAR_SOURCE_ENCODING" \
    -Dsonar.qualitygate.wait=true \
    -Dsonar.coverageReportPaths="$SONAR_COVERAGE_REPORTS_PATH"
else
    # Pull request
    sonar-scanner -Dsonar.projectKey="$SONAR_PROJECT_KEY" \
    -Dsonar.host.url="$SONAR_HOST_URL" \
    -Dsonar.organization="$SONAR_ORGANISATION" \
    -Dsonar.login="$SONAR_LOGIN" \
    -Dsonar.c.file.suffixes=- \
    -Dsonar.cpp.file.suffixes=- \
    -Dsonar.objc.file.suffixes=- \
    -Dsonar.sources=. \
    -Dsonar.qualitygate.wait=true \
    -Dsonar.exclusions="$SONAR_EXCLUSIONS" \
    -Dsonar.junit.reportsPath="$TEST_OUTPUT_FOLDER" \
    -Dsonar.sourceEncoding="$SONAR_SOURCE_ENCODING" \
    -Dsonar.coverageReportPaths="$SONAR_COVERAGE_REPORTS_PATH" \
    -Dsonar.pullrequest.provider="GitHub" \
    -Dsonar.pullrequest.github.repository="Cone1989/CheCheShi" \
    -Dsonar.pullrequest.key="$CI_PULL_REQUEST_NUMBER" \
    -Dsonar.pullrequest.branch="$CI_PULL_REQUEST_SOURCE_BRANCH" \
    -Dsonar.pullrequest.base="$CI_PULL_REQUEST_TARGET_BRANCH"
fi

