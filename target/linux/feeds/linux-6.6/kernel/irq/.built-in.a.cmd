savedcmd_kernel/irq/built-in.a := rm -f kernel/irq/built-in.a;  printf "kernel/irq/%s " irqdesc.o handle.o manage.o spurious.o resend.o chip.o dummychip.o devres.o autoprobe.o irqdomain.o proc.o msi.o ipi.o affinity.o | xargs aarch64-openwrt-linux-musl-ar cDPrST kernel/irq/built-in.a