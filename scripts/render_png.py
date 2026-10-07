"""Just enough PNG to answer "is this region one colour, and which".

A dependency-free decoder, because the question `scripts/render_gate.py` asks is small and
the alternative -- Pillow -- would put an image library in the path of a screening verdict
for the sake of two numbers. Handles what `integration_test`'s `takeScreenshot` actually
writes and refuses everything else by name rather than guessing: 8-bit, non-interlaced,
colour type 2 (RGB) or 6 (RGBA).
"""

from __future__ import annotations

import struct
import zlib
from pathlib import Path

PNG_MAGIC = b"\x89PNG\r\n\x1a\n"
_CHANNELS = {2: 3, 6: 4}


class UnsupportedPng(ValueError):
    """A PNG this decoder will not guess at."""


def _unfilter(raw: bytes, width: int, height: int, channels: int) -> bytearray:
    """The five PNG line filters, undone in place. One row of padding simplifies `up`."""
    stride = width * channels
    out = bytearray(height * stride)
    prev = bytearray(stride)
    pos = 0
    for y in range(height):
        ftype = raw[pos]
        pos += 1
        line = bytearray(raw[pos:pos + stride])
        pos += stride
        if ftype == 1:
            for i in range(channels, stride):
                line[i] = (line[i] + line[i - channels]) & 0xFF
        elif ftype == 2:
            for i in range(stride):
                line[i] = (line[i] + prev[i]) & 0xFF
        elif ftype == 3:
            for i in range(stride):
                left = line[i - channels] if i >= channels else 0
                line[i] = (line[i] + ((left + prev[i]) >> 1)) & 0xFF
        elif ftype == 4:
            for i in range(stride):
                a = line[i - channels] if i >= channels else 0
                b = prev[i]
                c = prev[i - channels] if i >= channels else 0
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pred = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[i] = (line[i] + pred) & 0xFF
        elif ftype != 0:
            raise UnsupportedPng(f"filter type {ftype}")
        out[y * stride:(y + 1) * stride] = line
        prev = line
    return out


def decode(path: Path) -> tuple[int, int, int, bytearray]:
    """(width, height, channels, pixel bytes). Raises `UnsupportedPng` rather than guessing."""
    blob = path.read_bytes()
    if blob[:8] != PNG_MAGIC:
        raise UnsupportedPng("not a PNG")
    width, height, depth, ctype, _comp, _filt, interlace = struct.unpack(
        ">IIBBBBB", blob[16:29])
    if depth != 8 or interlace != 0 or ctype not in _CHANNELS:
        raise UnsupportedPng(
            f"depth {depth}, colour type {ctype}, interlace {interlace}")
    idat = bytearray()
    pos = 8
    while pos < len(blob):
        length = struct.unpack(">I", blob[pos:pos + 4])[0]
        kind = blob[pos + 4:pos + 8]
        if kind == b"IDAT":
            idat += blob[pos + 8:pos + 8 + length]
        pos += 12 + length
        if kind == b"IEND":
            break
    channels = _CHANNELS[ctype]
    return width, height, channels, _unfilter(zlib.decompress(bytes(idat)),
                                              width, height, channels)


def region_histogram(path: Path, *, top: float = 0.35, bottom: float = 0.95,
                     step: int = 16) -> tuple[int, dict[tuple[int, int, int], int]]:
    """(sampled pixel count, RGB -> count) over a horizontal band of the screenshot.

    The band skips the top of the screen because `lib/main.dart` puts a `Scaffold` app bar
    there -- container chrome, identical in a healthy screenshot and a dead one -- and trims
    the bottom for the gesture bar.

    `step` samples on a grid rather than reading every pixel. The two states this exists to
    recognise are UNIFORM fills, which a 1-in-16 grid answers exactly; a widget that renders
    anything at all breaks uniformity long before the sampling could hide it.
    """
    width, height, channels, pixels = decode(path)
    stride = width * channels
    counts: dict[tuple[int, int, int], int] = {}
    total = 0
    for y in range(int(height * top), int(height * bottom), step):
        base = y * stride
        for x in range(0, width, step):
            i = base + x * channels
            rgb = (pixels[i], pixels[i + 1], pixels[i + 2])
            counts[rgb] = counts.get(rgb, 0) + 1
            total += 1
    return total, counts
