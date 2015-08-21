Overview
========


lua-build is a Makefile and a patch which allows to build a relocateable lua
installation under Linux.  It creates a directory which can be moved freely
within the filesystem. As such, it lays the foundation to create a
self-contained Lua installation which can be tarred up and deployed on othe
systems.  The approach has some overlap with LuaRocks but it had been developed
for an inhouse system.


Purpose
-------

Originally developed to host self-containing applications, it currently serves
as a testing and development harness for lua-t.


Usage
-----

Copy any file from customs
