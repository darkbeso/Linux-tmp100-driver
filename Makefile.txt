ifneq ($(KERNELRELEASE),)
obj-m := hello_version.o
else
KDIR := ../../../../../../linux/ 
all:
	$(MAKE) -C $(KDIR) M=$$PWD
endif
