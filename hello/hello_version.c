// SPDX-License-Identifier: GPL-2.0
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/utsname.h>
#include <linux/timekeeping32.h>

static char *who = "anonymous";
module_param(who, charp, 0);

static unsigned long start_sec;
static unsigned long end_sec;

static int __init hello_init(void)
{
	start_sec = get_seconds();

	printk(KERN_INFO "Hello, %s :)\nYou are using Kernel %s\n",
		who, utsname()->release);

	return 0;
}

static void __exit hello_exit(void)
{
	end_sec = get_seconds();

	printk(KERN_INFO "Goodbye.\n");
	printk(KERN_INFO "The module was alive %ld seconds.\n",
		end_sec - start_sec);
}

module_init(hello_init);
module_exit(hello_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Vanio Valchanov");

