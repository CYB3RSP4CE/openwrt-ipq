savedcmd_arch/arm64/crypto/poly1305-core.o := aarch64-openwrt-linux-musl-gcc -Wp,-MMD,arch/arm64/crypto/.poly1305-core.o.d -nostdinc -I./arch/arm64/include -I./arch/arm64/include/generated  -I./include -I./arch/arm64/include/uapi -I./arch/arm64/include/generated/uapi -I./include/uapi -I./include/generated/uapi -include ./include/linux/compiler-version.h -include ./include/linux/kconfig.h -D__KERNEL__ -mlittle-endian -DKASAN_SHADOW_SCALE_SHIFT= -fmacro-prefix-map=./= -Werror -D__ASSEMBLY__ -fno-PIE -mabi=lp64 -fno-asynchronous-unwind-tables -fno-unwind-tables -DKASAN_SHADOW_SCALE_SHIFT= -g -Dpoly1305_init=poly1305_init_arm64  -DMODULE  -c -o arch/arm64/crypto/poly1305-core.o arch/arm64/crypto/poly1305-core.S 

source_arch/arm64/crypto/poly1305-core.o := arch/arm64/crypto/poly1305-core.S

deps_arch/arm64/crypto/poly1305-core.o := \
  include/linux/compiler-version.h \
    $(wildcard include/config/CC_VERSION_TEXT) \
  include/linux/kconfig.h \
    $(wildcard include/config/CPU_BIG_ENDIAN) \
    $(wildcard include/config/BOOGER) \
    $(wildcard include/config/FOO) \

arch/arm64/crypto/poly1305-core.o: $(deps_arch/arm64/crypto/poly1305-core.o)

$(deps_arch/arm64/crypto/poly1305-core.o):
