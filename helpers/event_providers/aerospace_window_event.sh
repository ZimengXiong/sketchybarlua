#!/usr/bin/env bash

# aerospace window event callback for sketchybar
# triggered when windows are created, destroyed, or moved

# get the focused workspace
FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)

# trigger all relevant events
sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE="$FOCUSED_WORKSPACE"
sketchybar --trigger aerospace_window_event