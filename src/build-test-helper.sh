#!/bin/bash

# A helper script to build specific targets.
# It prints either 'ok' or 'failed' depending on the outcome of the build.
# The output of the build is stored in /tmp/$LOG_FNAME. If the build failed, the
# modified file $TARGET_FNAME is stored in /tmp/$TARGET_FNAME.$LOG_FNAME.
#
# Parameters:
# 	LOG_FNAME	name of the logfile to write to
#	TARGET_FNAME	name of the file to change #defines
#	MAKE_TARGETS	targets that need to be built
#	MAKE_VARS	variable-value pairs that are sent to the Makefile
#	SET_VARS	variables that need to be defined
#	UNSET_VARS	variables that need to be unset

# Backup
cp "$TARGET_FNAME" "$TARGET_FNAME.bak"

# Define variables that are commented out
for VAR in $SET_VARS; do
  sed -i "s!^\s*//\s*#define $VAR!#define $VAR!" "$TARGET_FNAME"
done

# Comment already defined variables
for VAR in $UNSET_VARS; do
  sed -i "s!^\s*#define $VAR!// #define $VAR!" "$TARGET_FNAME"
done

# Build and log output
make -k $MAKE_VARS $MAKE_TARGETS > "/tmp/$LOG_FNAME.log" 2>&1

# Print status
if [ $? = 0 ]; then
    echo -e "[\e[32mok\e[0m]      $LOG_FNAME"
else
    echo -e "[\e[31mfailed\e[0m]  $LOG_FNAME"
    cp "$TARGET_FNAME" "/tmp/$TARGET_FNAME.$LOG_FNAME"
fi

# Replace backup
mv "$TARGET_FNAME.bak" "$TARGET_FNAME"
