

DB:=db
SCHEMA:=schema
USERID:=user
PSSWD:=xx


BLDRTN=./bldrtn.2
COPY=cp
ERASE=rm -f

tbsel:
	$(BLDRTN) $@  $(DB) $(SCHEMA)  $(USERID) $(PSSWD) MAIN

utilemb utilapi:
	$(BLDRTN) $@  $(DB) $(SCHEMA)  $(USERID) $(PSSWD) LIB


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

