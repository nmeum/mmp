# mmp

The mini music player, an alternative to MPD.

## Motivation

To-do.

## Status

To-do.

## Dependencies

This software provides the required glue code for combining:

* [gstreamer][gstreamer website]
* [libmpdserver][libmpdserver github]
* [beets webapi][https://beets.readthedocs.io/en/latest/plugins/web.html]

## Usage

Setup [libmpdserver][libmpdserver github] using:

	$ git clone --recursive https://github.com/nmeum/libmpdserver
	$ make -C libmpdserver libmpdserver.so

Install [beets][beets homepage], setup the [web plugin][beets web] and run:

	$ beet web

The `include_paths` options needs to be enabled for the web plugin.

Install [hy][hy homepage] and [py3-gst][py3-gst homepage]. Afterwards run:

	$ export LD_LIBRARY_PATH="<PATH TO LIBMPDSERVER REPOSITORY>"
	$ hy mmp.hy "<URL OF BEETS WEB PLUGIN>"

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
[gstreamer website]: https://gstreamer.freedesktop.org/
