# Make support for ISIS tools
The current isis tools tree uses gnu make to build the various isis tools.
To keep the the makefiles simple, a set of macros and rules have been predefined
in an included file isis.mk.

This document describes the usage of isis.mk, but assumes some basic knowledge
of make and makefiles

## Structure of the makefile
The basic structure of the makefile is
```
# path to the top of the build tree
ROOT := ../
#
# optional pre include variables
# ...
include $(ROOT)/tools/isis.mk
#
# variable definitions and rules
# note target all:: must be defined
```
## Variables used by isis.mk
### Variables defined pre inclusion of isis.mk
* **ROOT** - this is set to the location of the top of the tools tree
* **LST** - this is set to the location of the listing file directory.
        It can be omitted if the current directory is used.
* **OBJ** -  this is set to the location of the object file directory.
        It can be omitted if the current directory is used.
* **PEXFILE** - this is set to the file name of the pexfile.
                It should be omitted if ngenpex is not being used
* **NOVERIFY** - set to non blank value if you wish to prevent the automatic
                 verify rule being created. Useful if you wish to create a
                 bespoke verify rule or verify isn't applicable. Most of the
                 time this can be omitted.

  If required the following should preferably be defined before isis.mk.

        Definitions after isis.mk must ensure path names are in unix format and
        for SRC and REF there should be no trailing space.
        The macro fixpath can be used to force this.

* **SRC** - this is set to the location of the source file directory.
        It can be omitted if the current directory is used.
* **REF** - this is set to the location of the reference file directory.
        It can be omitted if this is the plm80 v4 toolset
* **ISIS_F0** - this is set to the directory containing the isis drive F0 files
                It can be omitted if this is the current directory
* **COMPARE** - set to the program used to compare files. Not needed if
                the default omfcmp is being used.
                
        Note, when comparing files, path names are not translated to windows format,
        so some windows tools e.g fc may fail

## Variables modified or defined in isis.mk
* **ROOT** - the directory path is converted to unix format and any trailing / is removed
* **PATH** - environment variable updated to add the path to the unix tools
* **SHELL** - set to bash.exe
* **COMPARE** - set to $(ROOT)/tools/omfcmp if not defined
* **OBJ,LST,SRC,REF** - set to current directory if not defined, paths converted
                        to unix format and any traling / removed.
* **ISIS_F0** - set to current directory if not defined
* **ISIS** - set to the thames program with the -m option set
* **PLMPP** - set to the plmpp program
* **NGENPEX** - set to the ngenpex program
* **MKDEPEND** - set to the makedepend program
* **V40,V31,V30** - set to the locations of the plm80 v4.0, v3.1 and v3.0 tools respectively.
* **ISISTOOLS** - set to the $(V40) toolset. To use other versions change after isis.mk
* **ASM** - set to the asm80 tool within $(ISISTOOLS)
* **PLM80** - set to the plm80 tool within $(ISISTOOLS)
* **LINK** - set to the link tool within $(ISISTOOLS)
* **LIB** - set to the link tool within $(ISISTOOLS)
* **LOCATE** - set to the link tool within $(ISISTOOLS)
* **_masterfile** - this is set to the source master file if present. Master file
                    names end in *_all.plm*
* **space** - set to the space char - used in make macros
* **comma** - set to the comma char - used in make macros

### Variables defined pre or post inclusion of isis.mk
* **TARGETS** - the list of default files to build see **all** target below.
               It is also used with **distclean** and **verify** targets
* **PROTECT** - set to a list of files to keep as part of the distribution. This is
                only needed if *master files* are being used. The *master file, makefile,
                mk and any $(REF) directory* are protected automatically.
* **ASMFLAGS** - common options for asm80 - **print** and **object** should not be included
                as they are used internally
* **PLMFLAGS** - common options for plm80 - **print** and **object** should not be included
                as they are used internally
* **LINKFLAGS** - common options for link - **map** and **print** should not be included
                as they are used internally
* **LOCATEFLAGS** - common options for locate - **print** should not be included
                as is used internally
* **ISIS_Fn*** - where n is a digit 0-9.
                 Although thames now supports automatic directory - drive mapping,
                 it is occasionally necessary to explicitly define the mapping
                 of an ISIS drive. For example to define a specific directory for
                 include files. These variables must use the make export feature.
```
    For example to map ./include to drive F3 use
    export ISIS_F3 := ./include/
```
### Variables modified post inclusion of isis.mk
For more complex builds it may be necessary to modify variables post isis.mk.
Some of the more common examples are
* **ISISTOOLS** - If a file needs to be compiled with a specific version of a tool
                  you can set this variable to point to the appropriate version.
```
Examples
Using plm V3.1 for all plm builds
ISISTOOLS = $(V31)

Using plm V3.1 for a subset of files with V4.0 for the rest
list of files: ISISTOOLS = $(V31)

To support a command line specification of toolset e.g
    make V31 file.obj
define a rule
V31:
    $(eval ISISTOOLS=$(V31))
```

Other than the variables noted above and the macros noted below
no other names are reserved or modified.
### Macros defined in isis.mk
A number of macros are defined in isis.mk to simplify the invocation of the
isis build tools. Additionally a number of supporting macros are used that
may be of use in more complex makefiles.
#### Build macros
For these macros file names should be the unix style pathname. Thames maps these to
ISIS drive names, but see the note on ISIS_Fn above.
* **asm** - assemble a _file_.asm file, producing the specified object file and a
           listing file _file_.lst in the $(LST) directory.
            **ASMFLAGS** are used and optional target specific options can be given
           except for **print** and **object** which are used internally.
```
Usage:
    $(call asm,objfile,asmfile[,target specific options])
```
* **plm** - compile a _file_.plm file, producing the specified object file and a
           listing file _file_.lst in the $(LST) directory.
            **PLMFLAGS** are used and optional target specific options can be given
            except for **print** and **object** which are used internally.

        Pre running plm80 additional processing is done as follows
        if $(PEXFILE) is defined
            ngenpex will be run to generate any .ipx file
        else
            makedepend is run to generate a dependency file in .deps
 ```
Usage:
    $(call plm,objfile,asmfile[,target specific options])
```
* **link** - link a set of files producing the specified relocatable file and a
           listing file in the $(LST) directory. The listing file has the same name
           as the relocatable file but with the extension .lnk.
            **LINKFLAGS** are used and optional target specific options can be given
            except for **print** and **map** which are used internally.

        Note. Unlike other macros the listing file does not use the input
        filename as the basis of its name.
```
Usage:
    $(call link,relocfile,object files[,target specific options])
```
* **link-nocheck** - this is the same as link with the exception that unresolved
                     names are not treated as an error. It is designed to support
                     building overlay files.
```
Usage:
    $(call link-nocheck,relocfile,object files[,target specific options])
```
* **locate** - locates a file producing the specified file and a
           listing file in the $(LST) directory. The listing file has the same name
           as the relocatable file but with the extension .map.
            **LOCATEFLAGS** are used and optional target specific options can be given
            except for **print** which is used internally
```
Usage:
    $(call locate,target,relocfile[,target specific options])
```
* **locate-nocheck** - this is the same as locate with the exception that unsatisfied
                     names are not treated as an error. It is designed to support
                     building overlay files.
```
Usage:
    $(call locate-nocheck,target,relocfile files[,target specific options])
```
* **locate-overlaps** - this is the same as locate with the exception that overlaps
                     names are not treated as an error. It is designed to support
                     using obj2bin by including junk data to synthensise what was
                     in memory when Intel originally built isis.bin.
                     An alternative would be to use patchbin.
```
Usage:
    $(call locate-overlaps,target,relocfile files[,target specific options])
```
* **rm-symbols** - simple variant of locate that removes symbols from an existing
                   located file. No options are supported.
```
Usage:
    $(call rm-symbols,target,source)
```
* **lib** - build a specified library from a set of object files.
            Since lib does not have any print options, please use shell
            redirection to capture logs.
```
Usage:
    $(call lib,target,objects)
```
#### Support macros
##### Changing paths
The following macros convert an input list of files by replacing any existing
path of each file with a new path
```
Usage:
    $(call objdir,files)        # new path is $(OBJ)
    $(call srcdir,files)        # new path is $(SRC)
    $(call lstdir,files)        # new path is $(LST)
    $(call objdir,files)        # new path is $(OBJ)
    $(call v30dir,files)        # new path is $(V30)
    $(call v31dir,files)        # new path is $(V31)
    $(call v40dir,files)        # new path is $(V40)
```
##### Listing file names
Generate a listing file name based on the first file name passed in. This done
by taking the base file name, adding the appropriate extension and path $(LST)
```
Usage:
    $(call lnk,file)             # creates .lnk file name
    $(call map,file)             # creates .map file name
    $(call lst,file)             # creates .lst file name
```
##### Utility macros
These are mainly used internally however there may be occasional need to use them
elsewhere, especially fixpath
* **fixpath** - if specified file is blank convert to .
                else convert \ to / in file names and remove trailing / for all files
```
Usage:
    $(call fixpath,files)

Example:
    SHARED = $(call fixpath,..\..\src\)
    HERE = $(call fixpath,$(HERE))  # assuming HERE is not already defined
sets
    SHARED = ../../src
    HERE = .
```
* **notlast** - returns all but the last item in a list
```
Usage:
    $(call notlast,list)
Example:
    $(call notlast,1 2 3 4 5)
returns
    1 2 3 4
```
* **mklist** - converts a space separated list into a comma separated list
```
Usage:
    $(call mklist,list)
Example:
    $(call mklist,a b c)
returns
    a,b,c
```
### Rules defined in isis.mk
As with normal make usage a number of predefined rules are added by isis.mk.
Several of these support the specific way I work but should not get in the way of
other usage.

In particular there is additional support for master files which contain all source in
a single file, with each sub file marked with a control L followed by the sub file name.
This combined file makes it easier to modify groups of files as I decompile / disasemble
them.

Additionally I use ngenpex, which is my enhanced version of the ISIS toolbox genpex
utility. If PEXFILE is specified then the .ipx files are generated automatically as
part of the plm build.

#### Implicit build rules
Only two implicit build rules are defined, one to build a .obj file from a .plm file,
the other to build a .obj from a .asm file. The rules are
```
$(OBJ)/%.obj: %.plm  | $(OBJ) $(LST)
    $(call plm,$@,$<)

$(OBJ)/%.obj: %.asm  | $(OBJ) $(LST)
    $(call asm,$@,$<)
```
The | $(OBJ) $(LST) is used to auto create directories
#### .PHONY targets
The following .PHONY targets are defined in isis.mk
* **all::** - the default rule. If a master file is detected it will make sure that
            the files are auto extracted. The main make file should also
            include a all:: rule.
* **clean::** - used to clean *.obj, *.abs, *.lst, *.lnk, *.map files. If $(OBJ)
                or $(LST) are not set to the current directory they are deleted.
                A clean:: rule can be added to the main makefile if required
* **distclean::** - in addition to the files deleted by clean::, this rule deletes
                    the $(TARGETS) files and any .deps directory.
                    If a master file is used all non protected files are deleted.
                    See **PROTECT** variable.
* **rebuild:** - runs targets distclean followed by all
* **verify:** - verifies the $(TARGETS) files with those of the same name in
               the $(REF) directory. If NOVERIFY is specified then this target is
               not generated by isis.mk, however one can be included in the main
               makefile.

To help with automated clean up isis.mk defines the target **.DELETE_ON_ERROR:**.
## Examples
The isis tools build tree contains multiple examples of makefiles using isis.mk,
however the following are fragments with commentary to help the reader better understand
how to write their own makefiles.

lib_2.1 makefile, commentary preceeded by ~~
```
# path to root of build tree
ROOT := ../..                       ~~ mandatory variable. Points to top of build tree
TARGETS := lib                      ~~ what we are building
PEXFILE:=lib.pex                    ~~ mandatory variable as lib uses ngenpex

include $(ROOT)/tools/isis.mk

# build options
LOCATEFLAGS:=SYMBOLS LINES          ~~ map file will show local symbols & debug info
PLMFLAGS:=DEBUG                     ~~ generate the debug info
LINKFLAGS:=



objs =	lib.obj lib1.obj isis1.obj isisa.obj isis2.obj lib3.obj lib4.obj
~~ objs lists the object files needed. Generated using the implicit plm rule

all:: $(TARGETS)                    ~~ mandatory default rule, builds lib
                                    ~~ note ::

lib: lib.rel                        ~~ how lib is built from a reloc file
    $(call locate,$@,$^,code(3680H) name(lib) stacksize(90) purge)
~~ cf. $(call locate,target,relocfile[,options])
~~ here target = $@ = lib
~~   relocfile = $^ = lib.rel
~~     options = code(3680H) name(lib) stacksize(90) purge

.INTERMEDIATE: lib.rel              ~~ the reloc file will be deleted after use
lib.rel: $(objs)                    ~~ how the reloc file is built
    $(call link,$@,$^ $(V40)/plm80.lib)
~~ cf. $(call link,relocfile,objects[,options])
~~ here relocfile = $@ = lib.rel
~~        objects = $^ $(V40)/plm80.lib = lib.obj lib1.obj isis1.obj isisa.obj
~~                                        isis2.obj lib3.obj lib4.obj
~~                                        ../../plm80v40/plm80.lib
~~       i.e. $(objs) + plm80.lib from the $(V40) directory
~~ options are not used
```
Part of tex makefile
```
ROOT=../..
REF=ref                         ~~ set reference directory
TARGETS=tex10.com tex12.com tex21.com tex21a.com    ~~ multiple targets

include $(ROOT)/tools/isis.mk

PLMFLAGS=code optimize 
ASMFLAGS=

all:: $(TARGETS)

tex10.com: tex10.abs                        ~~ rules to make .com & patch it
    $(ROOT)/tools/obj2bin $^ $@
    $(ROOT)/tools/patchbin patch10.txt $@

.
.
.

# intermediate files
.INTERMEDIATE: $(TARGETS:.com=.rel) $(TARGETS:.com=.abs)
~~ uses make features to define .rel and .abs files are intermediate
               
STACK=100             ~~ default stacksize
tex10.abs: STACK=60   ~~ overrides stacksize for tex10.abs
%.abs: %.rel          ~~ user defined rule to make abs files from rel files
    $(call locate,$@,$^,code(100h) stacksize($(STACK)) purge)

tex10.rel: tex10.obj x0100.obj          ~~ the rule for the rel file
    $(call link,$@,$^ $(V40)/plm80.lib)

.
.
.
```
plm80.lib makefile
```
# common makefile info
ROOT=../..
TARGETS=plm80.lib
PLMFLAGS=code optimize
ASMFLAGS=
include $(ROOT)/tools/isis.mk

OBJS=	p0000.obj p0002.obj p0004.obj p0007.obj p0011.obj p0014.obj \
    p0018.obj p0020.obj p0022.obj p0025.obj p0029.obj p0031.obj \
    p0034.obj p0036.obj p0039.obj p0042.obj p0045.obj p0048.obj \
    p0050.obj p0052.obj p0055.obj p0059.obj p0061.obj p0064.obj \
    p0066.obj p0069.obj p0071.obj p0073.obj p0075.obj p0077.obj \
    p0080.obj p0082.obj p0084.obj p0086.obj p0089.obj p0091.obj \
    p0094.obj p0096.obj p0098.obj p0101.obj p0103.obj p0105.obj \
    p0106.obj p0108.obj p0110.obj p0113.obj prmsk.obj psmsk.obj

all:: $(TARGETS)

plm80.lib: $(OBJS)          ~~ objects automatically built from asm files
    $(call lib,$@,$^)       ~~ the simple lib command using $@ and $^
```
Partial makefile from plm80_4.0
```
ROOT := ../..
SHARED := shared            ~~ plm has a shared source directory
PEXFILE :=$(SHARED)/plm.pex ~~ where the pex file is also kept
SRC := src                  ~~ define directories for src, lst and obj
LST := lst
OBJ := obj


include $(ROOT)/tools/isis.mk

# force shared folder to be on isis drive :f3:
export ISIS_F3 := $(SHARED)/ ~~ the .ipx files are in :f3: & :f2:
export ISIS_F2 := $(SRC)/    ~~ make sure the directories are mapped explicitly

PURGE := purge               ~~ if debug versions are required

TARGETS = plm80 plm80.ov0 plm80.ov1 plm80.ov2 plm80.ov3 plm80.ov4 plm80.ov5 plm80.ov6


LOCATEFLAGS:=SYMBOLS PUBLICS
PLMFLAGS:=
ASMFLAGS:=

objs = main.obj plma.obj plmb.obj memchk.obj movmem.obj fill.obj plmc.obj\
.
.
.

# the following require plm v3.1        ~~ certain objects require plm80 V3.1
$(call objdir,plm1b.obj plm2b.obj plm2g.obj): ISISTOOLS=$(V31)
~~ objdir used here. could have used addprefix $(OBJ)/
                                        
# add the extra place to look for source
vpath %.plm $(SHARED)    ~~ make sure implicit rules know to look in shared folder
vpath %.asm $(SHARED)

# force make to reinspect extracted source files
~~ for complex build directory structures make sometimes misses the
~~ dependencies on the auto extracted files. Whilst creating a dependency on
~~ all source files would work in this case using $(MAKE) $(TARGETS) is simpler
all::
    $(MAKE) $(TARGETS)       

.
.
.
# extra rule for clean
clean::                         ~~ extra rule over the default clean
    -rm -f $(SHARED)/*.ipx


```
Partial asm80_4.1 makefile
```
# path to root of build tree
ROOT:=../..
# path to build directories
SRC:=src
LST:=lst
OBJ:=obj

PEXFILE:=$(SRC)/asm80.pex

PROTECT := notes.txt            ~~ notes.txt will be treated as part of distribution

include $(ROOT)/tools/isis.mk

# override default tools
ISISTOOLS := $(V31)             ~~ asm80 built using plm v3.1
export ISIS_F3 = $(SRC)         ~~ include directory is :F3: so explicity define it

TARGETS := asm80 asm80.ov0 asm80.ov1 asm80.ov2 asm80.ov3 asm80.ov4 asm80.ov5 asxref
.
.
.
~~ here make does need to be re-invoked as the complex auto generated files
~~ are not detected otherwise
# this forces make to reinspect the *.plx files
all:: 
    $(MAKE) $(TARGETS)
.
.
.
~~ simple rule to create executables & overlays in the current directory
~~ from relocatable versions in the $(OBJ) directory
## build rules to make the program and overlays
# Symbols for overlays 0,1,2 and 3 are used in the build of asm80 so the apps are created by purging the symbols
%: $(OBJ)/% ; $(call rm-symbols,$@,$<)
.
.
.
~~ the build of asm80 has a number of files that build differently 
~~ based on conditional compilation
~~ rather than list the mapping explicitly these rules generate
~~ intermediate plm files with a suffix of s, m, n, or b from the
~~ master *.plx files. These are then compiled
~~ here $(PLMPP) is used to pre-process the files
# these are special build rules to process the plx files
$(OBJ)/%m.obj: $(SRC)/%.plx
    $(PLMPP) -sMACRO -o $(SRC)/$*m.plm $<
    $(call plm,$@,$(SRC)/$*m.plm)

$(OBJ)/%n.obj: $(SRC)/%.plx
    $(PLMPP) -o $(SRC)/$*n.plm $<
    $(call plm,$@,$(SRC)/$*n.plm)

$(OBJ)/%s.obj: $(SRC)/%.plx
    $(PLMPP) -sSMALL -o $(SRC)/$*s.plm $<
    $(call plm,$@,$(SRC)/$*s.plm)

$(OBJ)/%b.obj: $(SRC)/%.plx
    $(PLMPP) -sBIG -o $(SRC)/$*b.plm $<
    $(call plm,$@,$(SRC)/$*b.plm)




```
Example makefile for testing files
```
# path to root of build tree
ROOT := ..

PLMOPT := DEBUG OPTIMIZE
ASMOPT :=
LOCATEOPT:= PUBLICS SYMBOLS
include $(ROOT)/tools/isis.mk

~~ method of compiling with the toolset specified on the command line
~~ e.g. make V31 file.obj - would set tools to v3.1 and then compile the file
# on command line if you don't want V40 tools
# use make V31 target or make V30 target
.PHONY: all V31 V30
all::
    @echo usage: make [V30^|V31] target ..."

V31:
    $(eval ISISTOOLS:=$(V31))           ~~ set the toolset
    @echo ISIS tools V3.1 selected      ~~ confirm to user

V30:
    $(eval ISISTOOLS:=$(V30)) 
    @echo ISIS tools V3.0 selected


~~ simple rule to generate an ISIS application based on a single object file	
%: %.obj
    $(call link,$*.rel,$^ $(addprefix $(ISISTOOLS)/,system.lib plm80.lib))
    $(call locate,$@,$*.rel,purge)
    @rm $*.rel                          ~~ can't use .INTERMEDIATE so rm manually

~~ simple rule to generate a cp/m application based on a single object file
%.com: %.obj
    $(call link,$*.rel,$^ $(addprefix $(ISISTOOLS)/,plm80.lib))
    $(call locate,$*.abs,$*.rel,CODE(100h) purge)
    @rm $*.rel                          ~~ can't use .INTERMEDIATE so rm manually
    $(ROOT)/tools/obj2bin $*.abs $@
    @rm $*.abs                          ~~ can't use .INTERMEDIATE so rm manually


```
**Mark Ogden 1-May-2017**