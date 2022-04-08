# utils
various scripts


## led_brightness_pwm_table_gen
shell script that generates a brightness-to-duty-cyle table for LEDs
utilizing Weber-Fechner's law of perception

	Usage: led_brightness_pwm_table_gen [-c] [-i<indent>] [-n<num-coeff>] <steps> [<resolution>]
	    -c, --ctable       c mode: output table in c syntax
	    -i, --indent       indent to use for c mode (default: tab)
	    -n, --number       number of coefficients per line in c mode (default: 8)
	    -h, --help         show this help screen
	    -l, --low-active   GPIO is low active

	steps         number of table entries (e.g. 32)
	resolution    PWM resolution (default: 65535)

	See Weber-Fechner law for brightness perception.

	Examples:
	    $ led_brightness_pwm_table_gen -c 32
	    $ led_brightness_pwm_table_gen 8 10000


## terminal
shell script that implements a serial terminal based only on standard
tools like cat, stty, etc. and does everything that's needed for remote
access to Embedded Linux etc. and more.

	Usage:
	    terminal [device:/dev/ttyUSB0 [baudrate:115200]]
	    terminal {--help|-h}

- Public Domain -- do with it what you want, extend, sell, whatever
- can replace minicom, picocom, screen with under 250 lines of bash
- no ncurses or windows, just regular console with whatever backlog
  the terminal offers
- logging simply by tee-ing into a file
- supports break signal (Linux SysRq!) even over USB/serial
- has time synchronization short cut: you can set the local time on
  a remote Linux system where you are logged in (using date and hwclock)
- easy to extend
- can run scripts (but doesn't have "expect" functionality, so you
  need to work with delays)
