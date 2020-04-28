# mmp

The mini music player, an alternative to MPD.

## Motivation

> All music player daemons suck. This one just sucks less.

I've been using [MPD][mpd homepage] as my primary music player for the
last decade or so. I like the idea of controlling my music player using
a network protocol but MPD itself tries to do too many things at once.
Since I am not interested in building my own music player clients, I
always intended to write an alternative implementation of the network
protocol used by MPD. My original attempt at doing so was
[mpvd][mpvd github] which provided an implementation of the
[MPD protocol][mpd protocol] for controlling the multimedia player
[mpv][mpv homepage]. Unfortunately, the protocol mapping turned out to
be more complicated than initially conceived and therefore the project
was later abandoned.

This project is a new attempt at replacing my [MPD][mpd homepage] setup
with a simpler software which handles playback and music database
management separately. Instead of mpv, it currently uses
[gstreamer][gstreamer homepage]. Additionally, it relies on the music
library manager [beets][beets homepage] for database management.

## Status

Proof of concept, buggy and totally incomplete at the moment.

## Dependencies

This software provides the required glue code for combining:

* [gstreamer][gstreamer homepage]
* [libmpdserver][libmpdserver github]
* [beets][beets homepage]

As such, this software has the following dependencies:

* The [hy][hy homepage] programming language
* The [gst-python][py3-gst homepage] module
* The [libmpdserver][libmpdserver github] parser library
* The [beets][beets homepage] music manager
	* Including the [web plugin][beets web]
	* Required configuration is described below

## Setup

The library libmpdserver is still in early stages of development. As
such, I haven't tagged releases or provided install scripts yet. For
this reason, just build the library manually for now using:

	$ git clone --recursive https://github.com/nmeum/libmpdserver
	$ make -C libmpdserver libmpdserver.so

Afterwards, setup the beets web plugin by following the upstream
[instructions][beets web]. This presupposes that [beets][beets homepage]
itself has already been setup. Regarding the configuration of this
plugin, the `include_paths` option **must** be enabled. For example, by
adding the following to your beets configuration file:

	web:
	  include_paths: True

Finally, invoke mmp itself using:

	$ export LD_LIBRARY_PATH="<PATH TO LIBMPDSERVER REPOSITORY>"
	$ hy mmp.hy "<URL OF BEETS WEB PLUGIN>"

## Tests

If [mpc][mpc homepage] is installed test can be invoked using:

	$ ./tests/run_tests.sh

## License

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero
General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.

[libmpdserver github]: https://github.com/nmeum/libmpdserver
[beets homepage]: https://beets.io/
[beets web]: https://beets.readthedocs.io/en/latest/plugins/web.html
[hy homepage]: https://docs.hylang.org
[py3-gst homepage]: https://gstreamer.freedesktop.org/bindings/python.html
[gstreamer homepage]: https://gstreamer.freedesktop.org/
[mpd homepage]: https://musicpd.org/
[mpd protocol]: https://musicpd.org/doc/html/protocol.html
[mpvd github]: https://github.com/nmeum/mpvd
[mpv homepage]: https://mpv.io/
[mpv protocol]: https://mpv.io/manual/master/#json-ipc
[mpc homepage]: https://www.musicpd.org/clients/mpc/
