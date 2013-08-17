REBOL [
	Title:   "Red binary build script"
	Author:  "Nenad Rakocevic"
	File: 	 %build.r
	Tabs:	 4
	Rights:  "Copyright (C) 2011-2013 Nenad Rakocevic. All rights reserved."
	License: "BSD-3 - https://github.com/dockimbel/Red/blob/master/BSD-3-License.txt"
]

;-- Parameters
encapper: 		%enpro.exe
bin:			%bin/
cache-file:		%bin/sources.r

Windows?: system/version/4 = 3

red: %red
if Windows? [append red %.exe]

log: func [msg [string! block!]][
	print reform msg
]

;-- Clean previous generated files
log "Cleaning files..."
attempt [delete cache-file]
attempt [delete %bin/red.exe]

;-- Create a working folder for the generated files
unless exists? %bin/ [
	log "Creating build/bin/ folder..."
	make-dir bin
]

;-- Combines all required source files into one (%sources.r)
log "Combining all source files together..."
do %includes.r

;-- Encapping the Rebol interpreter with Red sources
log "Encapping..."
call/wait reform [encapper "precap.r -o" bin/:red]

;-- Adjusting PE header sub-system flag for PE executable (Windows)
if Windows? [
	log "Fixing `sub-system` PE flag..."
	buffer: read/binary bin/:red
	buffer/325: #"^(03)"
	write/binary bin/:red buffer
]

;-- Remove temporary files
attempt [delete cache-file]

log join "File output: build/bin/red" form red
