Overview
========

lua-build is a Makefile and a patch which allows to build a relocateable Lua
installation under Linux.  It creates a directory which can be moved freely
within the filesystem.  As such, it lays the foundation to create a
self-contained Lua installation which can be tarred up and deployed on to any
linux systems.  The approach has some overlap with LuaRocks but it had been
developed for an inhouse system.


Purpose
-------

Originally developed to host self-containing applications, it currently serves
as a testing and development harness for lua-t.


Usage
-----

Prepare your Makefile.custom by using an example from the customs folder. Then
run::

   make CUSTOM=your.custom.Makefile custom


LICENSE
-------

See LICENSE file.  Same License as Lua-5.3.
