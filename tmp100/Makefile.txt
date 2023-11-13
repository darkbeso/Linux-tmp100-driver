ARCH ?= arm
CROSS_COMPILE ?= arm-linux-gnueabihf-
KERNEL ?= ../../linux/.

ifneq ($(KERNELRELEASE),)
obj-m := tmp100.o
else
KDIR := $(KERNEL)
endif

all:
	$(MAKE) -C $(KDIR) M=$(PWD) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE)
clean:
	$(MAKE) -C $(KDIR) M=$(PWD) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) clean

