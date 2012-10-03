
 Hi, Welcome to x64lab group.
  My name is Marc Rainer Kranz, i am a German 
  assembly programmer.

  You find me as "hopcode" on

 - http://sites.google.com/site/x64lab
 - http://groups.google.com/group/x64lab

 - board http://board.flatassembler.net/index.php
 - and on comp.lang.asm.x86 newsgroup

 Important note: x64lab is in Alfa development stage.
  at the moment i write this file (12.Aug.2012) it is at 
  its 0.0.114 build. it will become "beta" version after wrapping
  the last octet to 255. i will try to do my best in max 40 days
  from the current date. from now up to that beta-date 
  something may change completely. this is especially intended for
  dll plugins in the [plugin\*.*] and those user configuration 
  files in the [config] directory, respectively,

 - [config\accel.utf8]   keyboard accelerators
 - [config\config.utf8]  general config file
 - [config\devtool.utf8] config file for tools
 - [config\docking.bin]  repositional infos
 - [config\ext\*.*]      classes and file-extensions
 
  please, save them before unpacking a new build.
  you can stay up to date to check what has changed using 
  Google Projects and Mercurial feeds from

  http://code.google.com/feeds/p/x64lab/downloads/basic
  http://code.google.com/feeds/p/x64lab/hgchanges/basic

  -----------------------------------------------------------------

Summary:

  -1 What is exactly x64lab ?

  -2 Why mostly assembly coding ?

  -3 Why x64lab is free and opensource ?

  -4 Is it only Windows ?

  -5 Where can i find x64lab code ?

  -6 INSTALL notes

  -7 COMPILE notes

  -8 LICENSE

  -9 How does x64lab work ?

   -----------------------------------------------------------------

-1 What is exactly x64lab ?

   x64lab is an assembler framework. it is written
   completely in assembly using fasm and other tools. 
   it is aimed mainly as a framework to assembly programmers.

-2 Why mostly assembly coding ?

   because assembly is the most successful method
   to gain control of the machine. once having 
   understood the basic concepts, assembly coding speed up 
   your coding of hundreds times. i speak for my personal
   experience; what we need now is organization of our tools,
   an easy and safe way when editing files or using a toolchain.
   this is what x64lab is for.

-3 Why x64lab is free and opensource ?

   because it aims at being technology. technology
   is the expression of human capabilities. technology
   should be free for all to learn, improve and apply.

-4 Is it only Windows ?

   yes, at the moment. i have no idea how *NXes work.
   if you develop on other OS, make a designed proposal.
   nothing is impossible.

-5 Where can i find x64lab code ?

   online cloning the Mercurial from
     https://code.google.com/p/x64lab/

   or donwnload the latest (.7z) zipped version from
   http://code.google.com/p/x64lab/downloads/list

   -----------------------------------------------------------------

-6 Install notes:

   - create a local directory named "x64lab" and clone the project
     in there from the Mercurial repository online.
     alternatively, download the zipped packages and unzip them

      the "bin" prefixed package should be unpacked in x64lab
      the "src" prefixed package should be unpacked in x64lab\develop

   -----------------------------------------------------------------

-7 Compile notes:
   - i am compiling it using fasm 1.69.34. for eventual
     problems using newer versions of fasm, please let me know.
     i will try to adapt it.

   - download the latest version of fasm assembler
     from http://flatassembler.net/download.php
     and extract the package in a folder created just for it.
     You should only need the executable from the package,
     i.e: fasm.exe. all other needed files reside already
     in the x64lab directory.

   - having installed x64lab, edit the file 
     [x64lab\develop\setenv.bat] to set the path for fasm. 
     if you have fasm.exe in [E:\fasm], 
     then set the path to it in this way

     path=%path%;E:\fasm

   - set the environment variable for x64lab that allows
     sources to be compiled. if you have x64lab in
     [E:\x64lab] then

     set x64devdir=E:\x64lab\develop
 
   - save the file [x64lab\develop\setenv.bat].
     launch it when needed.
     you will find some other useful batch files 
     in the [develop\] folder.

     # build_all.bat : to rebuild the whole package

     # setlang.bat   : to rebuild and set the lang.dll file

     # version.vbs   : to increment the version number
       it creates or update a version.txt file

     # lab_update.bat : to set the current build as the
       working version (after exiting current x64lab, if running)

     # repack.bat     : to pack src/bin zipped file


-8 License

    This Source Code Form is subject to the terms of the 
    Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed 
    with this file, You can obtain one at http://mozilla.org/MPL/2.0/ or read
    it from the file LICENSE.TXT

   - x64lab is Copyright © 2009-2012, Marc Rainer Kranz

   - dock64,top64,lang plugins are under the MPL 2.0 license as above
     but as separated modules

   - Fasm is Copyright © 2004-2012, Tomasz Grysztar.

   - Scilexer, Scintilla is Copyright 1998-2003 by Neil Hodgson

   - files in the [equates\] folder are my own modifications from
     excellent public domain provided by madmatt.

   - file macro\unsupported.inc is public domain

   - icons in the [config\x64lab.bmp] are from the Open Icon Library
     under the CC License at http://openiconlibrary.sourceforge.net/

   -----------------------------------------------------------------

-9 How does x64lab work ?

   - because x64lab is a self-building framework, the [develop]
     folder contains all what i need to recompile it and set it
     as the working version. all files should be utf-8 encoded.
     the release version set an %X64LAB% env variable pointing
     to the application executable. the debug version an %X64LABD% one

   - x64lab can load/unload DLL files at run-time, plugins
     and languages too. i use this load/unload method i thought up,
     just because i wanted to solve the problem about languages 
     (having them on-demand and unloading/loading them without 
     needing to relaunch the application)

   - x64lab uses a docking system i built taking inspiration from
     Qt. obviously it is not Qt, but something very flexible and
     very easy to use. it doesnt save the position for now but 
     this last feature is already urgent in my todo list.

   - x64lab uses very few unicode routine, whose methods 
     i am very proud of.

   - x64lab introduces a new feature of file/folder organization.
     i call it "folder orientation" and smartlinks. this should
     reduce mad clicking by 2/3.

   - x64lab works good but it is not perfect and still in ALPHA.
     you can do whatever you want with my code. the guideline
     of using my code are set in the MPL 2.0 license.
     the MPL 2.0 license allows us to build for example a plugin
     and use it in x64lab whatever its internal code may be: 
     open source or not, freeware, shareware etc.

   - x64lab uses config files in a open source new format called
     TOP (Text Object Parser). i invented that format and
     that tecnology myself because i was bored of standard .ini files 
     and the redundancy of .xml & C. formats. i needed something
     powerful like CSV files, but capable to store nesting objects too.

     a TOP format file is always an utf-8 encoded file. also
     forget ANSI on editing it ! x64lab doesnt read/write into 
     Windows registry.

   - x64lab creates/uses some subdirectories to work.
     they are:

     [backup]   backup files
     [config]   for config files
     [plugin]   plugin/dll files
     [project]  projects and workspaces
     [tool]     to store tools
     [tmp]      tempo files
     [template] template files


   - Scintilla in x64lab loads and stores files by default in utf-8
     encoding for now. we will be able in a near future version
     to choose/recall encodings and charsets for each of them.

