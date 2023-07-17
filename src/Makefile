CC         = nim c
CFLAGS     =
TARGET     = render
SRC        = main.nim
# these are for just watching when they are updated
REQUISITES = io/ppm.nim *.nim

$(TARGET): $(SRC) $(REQUISITES)
	$(CC) -d:release --opt:speed --threads:on -d:useMalloc -o=$@ $(SRC)

$(RUN):
	./$(TARGET)

all: clean $(TARGET) run

run:
	-./$(TARGET)

clean:
	-rm $(TARGET) 
