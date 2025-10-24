#!/usr/bin/env bash

# aerospace event callback for sketchybar
# this script is called by aerospace's exec-on-workspace-change

# the environment variable $AEROSPACE_FOCUSED_WORKSPACE is provided by aerospace
# trigger sketchybar to update with the correct variable name
sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE="$AEROSPACE_FOCUSED_WORKSPACE"