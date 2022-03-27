# utils
various scripts


## led_brightness_pwm_table_gen
shell script that generates a brightness-to-duty-cyle table for LEDs
utilizing Weber-Fechner's law for perception


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
