# Notice: third-party text in the authored fixtures

Each `<group>/dependencies.dart` in this folder is a fixture for one arm-2 rebuild scope. It holds stand-in declarations
for what the widget depends on, with display strings, labels, dates and values that follow the source application. That
text comes from the open-source repositories the widgets were taken from. It is **not** original to this repository and is
**not** covered by its MIT licence. It stays under the licence of its source repository.

The licence and copyright notice of every source repository, with the licence texts, are in
[`THIRD_PARTY_NOTICES.md`](https://github.com/32bytess/flutter-rebuild-direction-data/blob/main/THIRD_PARTY_NOTICES.md) in
the data repository. [`SOURCES.md`](https://github.com/32bytess/flutter-rebuild-direction-data/blob/main/SOURCES.md) there
says which group came from which repository. The screen only let through MIT, Apache-2.0 and BSD-3-Clause code. The files
were changed from the originals: they were cut out, made self-contained and completed by hand.

**What these files are.** The 84 groups in `index.json` are the safe copy that the scripts read, so a hand-edited fixture
is never regenerated. Every file has a byte-identical copy in the data repository (`arm2-mining/fixtures/<group>/` or
`arm2-widgets/<group>/`), checked by hash. The data repository is the place to read them as data. This folder is where the
tools find them.

**Which ones enter a result.** 52 of the 84 groups were measured on the phone. The other 32 were authored but never
measured, so they enter no result. The measured fixtures are pinned by hash in `../measured_freeze.json`.

They were drafted with a language model assistant (Claude) under instructions given in the prompt, and reviewed by the
author. See the "Authored fixtures and the use of a language model" section in `config/README.md` and in the top-level
README.
