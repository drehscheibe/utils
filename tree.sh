#!/bin/bash
# Melchior FRANZ <melchior.franz@ginzinger.com> -- Public Domain
# This file uses a few UTF-8 characters, which may look odd if the shell doesn't support UTF-8.

SELF=${0##*/}

MAX_LEVELS=1000
OUTPUT_MAX_LINES=1000000
LS_OPTIONS=-v1  # sort by version (2 before 11), one per line


usage() {
	cat <<-EOF

	Usage: $SELF [-a] [-L <max-level>] [-z [<num-lines>]] [<dir> ...]

	    -a, --all     also show hidden files and directories
	    -h, --help    show this help screen
	    -L, --level   set maximum depth level (default: $MAX_LEVELS)
	    -z, --dump    output $OUTPUT_MAX_LINES lines of every readable file
	                  (optional parameter: number of lines). ASCII files
	                  are printed verbatim, binary files are printed as
	                  hexdump.

	Examples:

	    $ $SELF -z /tmp/        ... print up to $OUTPUT_MAX_LINES lines
	    $ $SELF -z5 /tmp/       ... print up to 5 lines per file
	    $ $SELF --dump=5 /tmp/  ... print up to 5 lines per file

	EOF
}


# we aren't using echo here, because echo cannot print content "-e" or "-n", which are valid file names
if [ -t 1 ]; then # output goes to terminal -> use ANSI color codes
	print_color() { local c=$1; shift; printf "\e[${c}m%s\e[m" "$*"; }
else
	print_color() { shift; printf "%s" "$*"; }
fi


terminate() { echo -en "\e[m"; exit 0; } # turn off color
trap terminate EXIT INT HUP QUIT TERM


print_path() { # $1 - path
	if [ -h "$1" ]; then # symlink ... must be first, because the others follow the link
		print_color "36;1" "$1"
	elif [ -d "$1" ]; then # dir
		print_color "34;1" "$1"
	elif [ -b "$1" ]; then # blockdev
		print_color "33;1" "$1"
	elif [ -c "$1" ]; then # chardev
		print_color "33;1" "$1"
	elif [ -p "$1" ]; then # pipe
		print_color "33" "$1"
	elif [ -S "$1" ]; then # socket
		print_color "35;1" "$1"
	elif [ -x "$1" ]; then # executable
		print_color "32;1" "$1"
	elif [ -e "$1" ]; then # exists
		echo -n "$1"
	else
		print_color "90" "$1"
	fi
}


tree() { # $1 - level, $2 - indent, $3 - dir
	local level="$1"
	local indent="$2"
	local dir="$3"

	print_color "34;1" "$dir"
	[ -d "$dir" ] && [ -r "$dir" ] && echo || { print_color "31" " [error opening dir]" && echo && return 0; }
	[ $level -lt $MAX_LEVELS ] || return 0

	local wd="$PWD"
	cd -- "$dir"

	local num=$(ls $LS_OPTIONS 2>/dev/null | wc -l)

	if [ $num -gt 0 ]; then
		ls $LS_OPTIONS | while read entry; do
			num=$((num - 1))

			if [ $num -gt 0 ]; then
				echo -en "$indent├── "
				prefix="│   "
			else
				echo -en "$indent└── "
				prefix="    "
			fi

			if [ -h "$entry" ]; then # link
				if target="$(readlink -- "$entry")" && [ -e "$target" ]; then # regular link
					echo -e "$(print_path "$entry") -> $(print_path "$target")"
				else
					print_color "91" "$entry"
					echo -n " -> "
					if [ "$target" ]; then # target set and readable, but doesn't exist
						print_color "90" "$(print_path "$target")" && echo
					else
						print_color "31" "[error reading symbolic link information]" && echo
					fi
				fi

			elif [ -d "$entry" ]; then # directory -> recurse
				tree "$(($level + 1))" "$indent$prefix" "$entry"

			else
				print_path "$entry" && echo

				if [ "$OUTPUT" ] && [ -r "$entry" ]; then
					if head -c4096 "$entry" | grep -aq '[^[:print:][:space:]]'; then # probably binary
						xxd -l $((16 * $OUTPUT_MAX_LINES)) "$entry"
					else # probably text
						head -$OUTPUT_MAX_LINES "$entry"
					fi 2>/dev/null | while IFS= read line; do
						[ -t 1 ] && echo -e "$indent$prefix   ┊\e[33m$line\e[m" || echo "$indent$prefix   ┊$line"
					done
				fi
			fi
		done
	fi

	cd "$wd"
}


if ! args=$(getopt -l all,help,level:,dump:: -o ahL:z:: -- "$@"); then
	usage
	exit 1
fi

eval set -- "$args"
while [ $# -gt 0 ]; do
	case "$1" in
	-a|--all)
		LS_OPTIONS="$LS_OPTIONS -A" # "almost all"; everything but . and ..
		;;
	-h|--help)
		usage
		exit 0
		;;
	-L|--level)
		MAX_LEVELS=$2
		shift
		;;
	-z|--dump)
		if [ "$2" ]; then
			if [ $2 -ge 0 ] 2>/dev/null; then
				OUTPUT_MAX_LINES=$2
			else
				echo >&2 -e "$SELF: option -z/--dump: ignoring invalid number $2\n"
			fi
			shift
		fi
		OUTPUT=y
		;;
	--)
		shift
		break
		;;
	*)
		if [ "$1" ]; then
			echo >&2 -e "$SELF: invalid option: $1\n"
			usage
			exit 1
		fi
		;;
	esac
	shift
done

[ $# -gt 0 ] || set -- .  # no dir path given?

for path; do
	tree 0 "" "$path"
done
