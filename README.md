
# ANSI to UTF-8 file converter
Command line utility to convert ANSI encoded files to UTF-8.
It checks if a file is already in Unicode and only converts when it's not.

The new file gets the required BOM for the new encoding, so that editors can recognise it.
The original file is automatically backupped.

Conversion can be done for files and folders, optionally including subfolders.

## Installation
Not required. Just download AnsiToUtf8.exe command line utility to your computer. Win32 and Win64 versions are available in the Bin directory.

## Usage
`AnsiToUtf8 <filename or folder> <options>`
### Options
 - `-cp` <codepage>: Define an ANSI codepage for the file (default 1251).
 - `-subdirs`: Include subdirectories when converting a folder.
 - `-pattern`: Search pattern for files (default *.pas).
