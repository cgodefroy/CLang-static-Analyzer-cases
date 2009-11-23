#!/bin/sh
~/checker/scan-build --status-bugs -k -V \
	-warn-objc-missing-dealloc \
	xcodebuild -sdk iphonesimulator2.2.1 -configuration Debug	


#scan-build -k -V xcodebuild
