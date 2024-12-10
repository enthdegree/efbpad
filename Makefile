TARGETS = armcheck libfbink fbpad/fbpad kbreader/kbreader fbpad_mkfn/mkfn install
PLATFORM = pocketbook

all: $(TARGETS)

armcheck:
ifeq (,$(findstring arm-,$(CROSS_TC)))
	$(error Set up a CC toolchain (e.g. for NiLuJe `source koxtoolchain/refs/x-compile.sh pocketbook env`))
endif

libfbink: 
	$(PLATFORM)=1 make -C FBInk/ shared fbdepth 
	$(PLATFORM)=1 make -C FBInk/ install DESTDIR=$(shell pwd)/buildroot

fbpad/fbpad:
	make -C ./fbpad/ EINK=YES

kbreader/kbreader:
	make -C ./kbreader/

fbpad_mkfn/mkfn:
	make -C ./fbpad_mkfn/

install: $(TARGETS)
	cp ./fbpad/fbpad ./buildroot/bin/ 
	cp ./kbreader/kbreader ./buildroot/bin/ 
	cp ./fbpad_mkfn/mkfn ./buildroot/bin/

	mkdir -p release
	cp -r --dereference platform/pocketbook/* ./release
	cp -r --dereference ./buildroot ./release/applications/efbpad

clean:
	make -C ./fbpad/ clean
	make -C ./FBInk/ clean
	make -C ./fbpad_mkfn/ clean
	make -C ./kbreader/ clean
	rm -rf ./buildroot
	rm -rf ./release
