savedcmd_arch/arm64/built-in.a := rm -f arch/arm64/built-in.a;  printf "arch/arm64/%s " kernel/built-in.a mm/built-in.a net/built-in.a crypto/built-in.a | xargs aarch64-openwrt-linux-musl-ar cDPrST arch/arm64/built-in.a