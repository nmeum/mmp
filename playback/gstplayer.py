# -*- coding: utf-8 -*-
# This file is part of beets.
# Copyright 2016, Adrian Sampson.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

"""A wrapper for the GStreamer Python bindings that exposes a simple
music player.
"""

import urllib.parse
import _thread
import time

import gi
gi.require_version('Gst', '1.0')
from gi.repository import GLib, Gst

Gst.init(None)

class QueryError(Exception):
    pass

class GstPlayer(object):
    """A music player abstracting GStreamer's Playbin element.

    Create a player object, then call run() to start a thread with a
    runloop. Then call play_file to play music. Use player.playing
    to check whether music is currently playing.

    A basic play queue is also implemented (just a Python list,
    player.queue, whose last element is next to play). To use it,
    just call enqueue() and then play(). When a track finishes and
    another is available on the queue, it is played automatically.
    """

    def __init__(self, finished_callback=None):
        """Initialize a player.

        If a finished_callback is provided, it is called every time a
        track started with play_file finishes.

        Once the player has been created, call run() to begin the main
        runloop in a separate thread.
        """

        def _create_element(name):
            elem = Gst.ElementFactory.make(name)
            if elem is None:
                raise RuntimeError("Could not create element {}".format(elem))
            return elem

        self.player = _create_element("playbin")
        fakesink = _create_element("fakesink")

        self.player.set_property("video-sink", fakesink)
        bus = self.player.get_bus()
        bus.add_signal_watch()
        bus.connect("message", self._handle_message)

        self.path = None
        self.playing = False
        self.finished_callback = finished_callback
        self.cached_time = None

    def _get_state(self):
        """Returns the current state flag of the playbin."""
        _, state, _ = self.player.get_state(Gst.CLOCK_TIME_NONE)
        return state

    def _handle_message(self, bus, message):
        """Callback for status updates from GStreamer."""
        if message.type == Gst.MessageType.EOS:
            # file finished playing
            self.player.set_state(Gst.State.NULL)
            self.path = None
            self.playing = False
            self.cached_time = None
            if self.finished_callback:
                self.finished_callback()

        elif message.type == Gst.MessageType.ERROR:
            # error
            self.player.set_state(Gst.State.NULL)
            err, _ = message.parse_error()
            raise RuntimeError("GStreamer Error: {}".format(err))
            self.playing = False

    def play_file(self, path):
        """Immediately begin playing the audio file at the given
        path.
        """
        self.player.set_state(Gst.State.NULL)

        self.path = path
        uri = 'file://' + urllib.parse.quote(path)
        self.player.set_property("uri", uri)

        self.player.set_state(Gst.State.PLAYING)
        self.playing = True

    def play(self):
        """If paused, resume playback."""
        if self._get_state() == Gst.State.PAUSED:
            self.player.set_state(Gst.State.PLAYING)
            self.playing = True

    def pause(self):
        """Pause playback."""
        self.player.set_state(Gst.State.PAUSED)

    def stop(self):
        """Halt playback."""
        self.player.set_state(Gst.State.NULL)
        self.path = None
        self.playing = False
        self.cached_time = None

    def run(self):
        """Start a new thread for the player.

        Call this function before trying to play any music with
        play_file() or play().
        """

        # If we don't use the MainLoop, messages are never sent.

        def start():
            loop = GLib.MainLoop()
            loop.run()

        _thread.start_new_thread(start, ())

    def time(self):
        """Returns a tuple containing (position, length) where both
        values are integers in seconds. If no stream is available,
        returns (0, 0).
        """
        fmt = Gst.Format(Gst.Format.TIME)
        try:
            posq = self.player.query_position(fmt)
            if not posq[0]:
                raise QueryError("query_position failed")
            pos = posq[1] / (10 ** 9)

            lengthq = self.player.query_duration(fmt)
            if not lengthq[0]:
                raise QueryError("query_duration failed")
            length = lengthq[1] / (10 ** 9)

            self.cached_time = (pos, length)
            return (pos, length)

        except QueryError:
            # Stream not ready. For small gaps of time, for instance
            # after seeking, the time values are unavailable. For this
            # reason, we cache recent.
            if self.playing and self.cached_time:
                return self.cached_time
            else:
                return (0, 0)

    def seek(self, position):
        """Seeks to position (in seconds)."""
        cur_pos, cur_len = self.time()
        if position > cur_len:
            self.stop()
            return

        fmt = Gst.Format(Gst.Format.TIME)
        ns = position * 10 ** 9  # convert to nanoseconds
        self.player.seek_simple(fmt, Gst.SeekFlags.FLUSH, ns)

        # save new cached time
        self.cached_time = (position, cur_len)

    def block(self):
        """Block until playing finishes."""
        while self.playing:
            time.sleep(1)