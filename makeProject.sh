#!/bin/bash

clear

displayCompilerInfo() {
	printf "\n"
	printf "\n"
	echo -n "### Current Compiler"
	printf "\n"
	eval xcrun swift -version
	eval xcode-select --print-path
}

################################################################################

echo "### Brew"
echo " [1] : Install"
echo " [2] : Update"
echo " [3] : Skip"
echo -n "Option? "
read option
case $option in
    [1] ) /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" ;;
    [2] ) eval brew update ;;
   *) echo "Ignored...."
;;
esac

################################################################################

printf "\n"

echo "### Xcodegen"
echo " [1] : Install"
echo " [2] : Upgrade"
echo " [3] : No/Skip"
echo -n "Option? "
read option
case $option in
    [1] ) brew install xcodegen ;;
    [2] ) brew upgrade xcodegen ;;
   *) echo "Ignored...."
;;
esac

################################################################################

displayCompilerInfo

printf "\n"
printf "\n"

################################################################################

echo "### Clean DerivedData?"
echo " [1] : Yes"
echo " [2] : No/Skip"
echo -n "Option? "
read option
case $option in
    [1] ) rm -rf ~/Library/Developer/Xcode/DerivedData/* ;;
   *) echo "Ignored...."
;;
esac

################################################################################

printf "\n"

echo "Generating project...."
xcodegen -s ./XcodeGen/CTArchitecture.yml -p ./

################################################################################

echo "Opening project...."
open CTArchitecture.xcodeproj

################################################################################

echo "Generating graphviz...."
xcodegen dump --spec ./XcodeGen/CTArchitecture.yml --type graphviz --file ./Documents/Graph.viz
xcodegen dump --spec ./XcodeGen/CTArchitecture.yml --type json --file ./Documents/Graph.json

################################################################################

echo 'periphery...'
periphery scan

################################################################################

echo " ╔═══════════════════════╗"
echo " ║ Done! You're all set! ║"
echo " ╚═══════════════════════╝"
