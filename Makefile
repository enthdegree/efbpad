TARGETS = armcheck libfbink fbpad/fbpad kbreader/kbreader fbpad_mkfn/mkfn install

all: $(TARGETS)

armcheck:
ifeq (,$(findstring arm-,$(CROSS_TC)))
	$(error Set up a CC toolchain (e.g. for NiLuJe `source koxtoolchain/refs/x-compile.sh kobo env`))
endif

libfbink: 
	mkdir -p ./build ; \
	MINIMAL=1 BITMAP=1 make -C FBInk/ kobo ; \
	tar -xf FBInk/Kobo/KoboRoot.tgz ; \
	mv ./usr/local/fbink/* ./build/ ;
	rm -rf ./usr

fbpad/fbpad:
	make -C ./fbpad/ EINK=YES

kbreader/kbreader:
	make -C ./kbreader/

fbpad_mkfn/mkfn:
	make -C ./fbpad_mkfn/

install: $(TARGETS)
	cp ./fbpad/fbpad ./build/bin/ 
	cp ./kbreader/kbreader ./build/bin/ 
	cp ./fbpad_mkfn/mkfn ./build/bin/ 

	mkdir -p ./root/mnt/onboard/.adds/efbpad/
	cp -r --dereference ./onboard/. ./root/mnt/onboard/
	cp -r --dereference ./build/. ./root/mnt/onboard/.adds/efbpad/
	tar -C ./root -czf KoboRoot.tgz .

clean:
	make -C ./fbpad/ clean
	make -C ./FBInk/ clean
	make -C ./fbpad_mkfn/ clean
	make -C ./kbreader/ clean
	rm -rf ./build
	rm -rf ./root
	rm -f KoboRoot.tgz
