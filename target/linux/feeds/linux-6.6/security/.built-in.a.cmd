savedcmd_security/built-in.a := rm -f security/built-in.a;  printf "security/%s " keys/built-in.a commoncap.o min_addr.o device_cgroup.o | xargs aarch64-openwrt-linux-musl-ar cDPrST security/built-in.a