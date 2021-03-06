#!/bin/sh

# This script was found at:
# https://gist.github.com/olmokramer/b28ff8ed5fd366e3ebb23b79915ec850

hash herbstclient xrandr

print_tags() {
	for tag in $(herbstclient tag_status "$1"); do
		name=${tag#?}
		state=${tag%$name}
		case "$state" in
		'#')
			printf '%%{F#5F819D} %s %%{F-}' "  $name  "
			;;
		'+')
			printf '%%{F#cccccc}%%{R} %s %%{R}%%{F-}' "  $name  "
			;;
		'!')
			printf '%%{F#f0c674} %s %%{F-}' "  $name  "
			;;
		'.')
			printf '%%{F#cccccc} %s %%{F-}' "  $name  "
			;;
		*)
			printf ' %s ' "  $name  "
		esac
	done
	printf '\n'
}

geom_regex='[[:digit:]]\+x[[:digit:]]\++[[:digit:]]\++[[:digit:]]\+'
geom=$(xrandr --query | grep "^$MONITOR" | grep -o "$geom_regex")
monitor=$(herbstclient list_monitors | grep "$geom" | cut -d: -f1)

print_tags "$monitor"

IFS="$(printf '\t')" herbstclient --idle | while read -r hook args; do
	case "$hook" in
	tag*)
		print_tags "$monitor"
		;;
	esac
done
