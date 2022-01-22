# utils
various scripts

## terminal
shell script that implements a serial terminal based only on standard
tools like cat, stty, etc. and does everything that's needed for remote
access to Embedded Linux etc. and more.

- Public Domain -- do with it what you want, extend, sell, whatever
- can replace minicom, picocom, screen with under 250 lines of bash
- is easy to extend
- has time syncrhonization short cut: you can set the local time on
  a remote Linux system (using date and hwclock)
- can run scripts (but doesn't have "expect" functionality, so you
  need to work with delays)
