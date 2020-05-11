

DB:=db
SCHEMA:=schema
USERID:=
PSSWD:=
#DB2PATH!= dirname $IBM_DB_HOME

DO_CONNECT:=yes

DB2_CONNECT_CREDENTIALS:=
ifneq ($(USERID),)
    DB2_CONNECT_CREDENTIALS="$(USERID) using $(PSSWD)"
endif

CURR_DIR=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
BLDRTN=./bldrtn.2
COPY=cp
ERASE=rm -f

EXTRA_C_FLAGS=-m64 -fpic
LIB=lib64
SHARED_LIB_FLAG=-shared

DB2_INCLUDE_PATH=$(DB2PATH)/include/


LINK_FLAGS=$(EXTRA_C_FLAGS)
SHARED_LINK_FLAGS=$(EXTRA_C_FLAGS) $(SHARED_LIB_FLAG)

EXTRA_LFLAG=-Wl,-rpath,$(DB2PATH)/$(LIB):\$$ORIGIN -Wl,-rpath-link,$(CURR_DIR)

# For Precompile
%.c: %.sqc
ifeq ($(DO_CONNECT),yes)
	db2 connect to $(DB) $(DB2_CONNECT_CREDENTIALS)
endif
	db2 prep $^ bindfile using $(CURR_DIR)/$(filter-out \.c,$@).bnd
ifeq ($(DO_CONNECT),yes)
	db2 connect reset
	db2 terminate
endif
 
# Generate Object
%.o: %.c 
	$(CC) $(EXTRA_C_FLAGS) -I$(DB2_INCLUDE_PATH) -c $< -o $@  -D_REENTRANT

%.so: utilemb.o utilapi.o
	$(CC) $(SHARED_LINK_FLAGS) -o $@ $< $(EXTRA_LFLAG) -L$(DB2PATH)/$(LIB) -ldb2 -lpthread

tbsel: tbsel.o libutilemb.so libutilapi.so
	$(CC) $(LINK_FLAGS) -o $@ $^ $(EXTRA_LFLAG) -L "./"  -L$(DB2PATH)/$(LIB) -ldb2 -lpthread  -lutilemb -lutilapi


.PHONY: all

all: tbsel


clean:
	- rm -v *.o
	- rm -v *.so
	- rm -v tbsel tbsel.c
	- rm -v *.bnd
	- rm -v *.log

bind:
	#utilemb
	#tbsel

all: utilemb utilapi tbsel

