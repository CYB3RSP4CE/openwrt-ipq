savedcmd_lib/modules.order := {   cat lib/math/modules.order;   cat lib/crypto/modules.order;   cat lib/xz/modules.order;   cat lib/lzma/modules.order;   echo lib/crc-ccitt.o;   echo lib/crc16.o;   echo lib/crc-itu-t.o;   echo lib/crc7.o;   echo lib/libcrc32c.o;   echo lib/xxhash.o;   cat lib/zlib_inflate/modules.order;   cat lib/zlib_deflate/modules.order;   cat lib/lzo/modules.order;   cat lib/zstd/modules.order;   cat lib/raid6/modules.order;   echo lib/ts_kmp.o;   echo lib/ts_bm.o;   echo lib/ts_fsm.o;   echo lib/asn1_decoder.o;   echo lib/oid_registry.o; :; } > lib/modules.order