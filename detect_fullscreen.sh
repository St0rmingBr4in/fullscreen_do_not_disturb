#!/bin/sh

full_screen_detected="false"
verbose=true
do_not_disturb_query="xfconf-query -c xfce4-notifyd -p /do-not-disturb"

xprop_active_info () {
  xprop -id "$(xprop -root _NET_ACTIVE_WINDOW | awk '{print $5}')"
}

maybe_set_fullscreen_conf () {
  if we_are_fullscreen; then
    if [ "$full_screen_detected" != "true" ]; then
      $verbose && echo "fullscreen entry"

      do_not_disturb_user_setting=$($do_not_disturb_query)
      dpms_user_setting="$(xset -q | grep -q 'DPMS is Enabled' || echo -- "-")dpms"

      $do_not_disturb_query -s true
      xset -dpms

      full_screen_detected="true"
    fi
  else
    if [ "$full_screen_detected" = "true" ]; then
      $verbose && echo "fullscreen exit"

      $do_not_disturb_query -s "$do_not_disturb_user_setting"
      xset "$dpms_user_setting"

      full_screen_detected="false"
    fi
  fi
}

we_are_fullscreen () {
  xprop_active_info | grep -q _NET_WM_STATE_FULLSCREEN
}

delay=${1:-50}

case $delay in
*[!0-9]*)
  echo "Expecting a positive integer"
  exit 1
  ;;
esac

while true; do
  maybe_set_fullscreen_conf
  sleep "$delay"
done
