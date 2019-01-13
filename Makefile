SRCDIR = src
OBJDIR = obj
BINDIR = bin
INCDIR = include
DIRS   = $(SRCDIR) $(OBJDIR) $(BINDIR) $(INDDIR)

EXEC = test

OBJ = \
	$(OBJDIR)/ll.o \
	$(OBJDIR)/test.o

deps = $(OBJ:%.o=%.o.d)

CC = gcc

CFLAGS += -g -O1 -pthread
# CFLAGS += -Wall -Werror -Wextra -Wunused
# CFLAGS += -std=gnu99 -D_GNU_SOURCE -pthread
# CFLAGS += -fno-strict-aliasing
# CFLAGS += -D_REENTRANT
# CFLAGS += -pedantic
CFLAGS += -I"$(INCDIR)"

all: $(EXEC)

$(OBJDIR)/%.o: $(SRCDIR)/%.c $(OBJDIR)
	@echo building object files...
	$(CC) $(CFLAGS) -o $@ -MMD -MF $@.d -c $<

$(EXEC): %: $(BINDIR) $(BINDIR)/%

$(BINDIR)/%: $(OBJ)
	@echo building binary...
	$(CC) $(CFLAGS) -o $@ $(OBJ)

$(DIRS):
	@mkdir -p $@

run: $(EXEC)
	@echo running tests...
	@$(BINDIR)/$(EXEC)

clean:
	@rm -rf $(BINDIR) $(OBJDIR)

.PHONY: all run clean

-include $(deps)