#!/usr/bin/env sh

swaymsg -t get_tree | jq ".. | objects | select(.foreign_toplevel_identifier==\"$(windows -o eDP-1)\") | .id" | xargs -I? swaymsg [con_id=?] focus
