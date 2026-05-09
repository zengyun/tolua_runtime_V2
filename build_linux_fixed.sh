#!/bin/bash

echo "=== 在Linux上编译tolua库（修复版本）==="

mkdir -p linux/x86_64
mkdir -p Plugins/linux/x86_64

echo "=== 编译LuaJIT ==="
cd luajit-2.1
make clean
make BUILDMODE=static CC="gcc -m64 -O2" XCFLAGS=-DLUAJIT_ENABLE_GC64 CFLAGS="-fPIC"
cp src/libluajit.a ../linux/x86_64/libluajit.a
make clean

echo "=== 编译PBC ==="
cd ../pbc/
make clean
make BUILDMODE=static CC="gcc -m64"
cp build/libpbc.a ../linux/x86_64/libpbc.a

cd ..

echo "=== 修复cjson兼容性问题 ==="
# 备份原文件
cp cjson/lua_cjson.c cjson/lua_cjson.c.bak

# 修复luaL_setfuncs重定义问题（Linux sed语法）
sed -i.tmp 's/static void luaL_setfuncs/static void luaL_setfuncs_cjson/g' cjson/lua_cjson.c
sed -i.tmp 's/luaL_setfuncs(/luaL_setfuncs_cjson(/g' cjson/lua_cjson.c
rm -f cjson/lua_cjson.c.tmp

echo "=== 编译主库 ==="
gcc -m64 -O2 -std=gnu99 -shared -fPIC \
 tolua.c \
 int64.c \
 uint64.c \
 pb.c \
 lpeg.c \
 struct.c \
 cjson/strbuf.c \
 cjson/lua_cjson.c \
 cjson/fpconv.c \
 luasocket/auxiliar.c \
 luasocket/buffer.c \
 luasocket/except.c \
 luasocket/inet.c \
 luasocket/io.c \
 luasocket/luasocket.c \
 luasocket/mime.c \
 luasocket/options.c \
 luasocket/select.c \
 luasocket/tcp.c \
 luasocket/timeout.c \
 luasocket/udp.c \
 luasocket/usocket.c \
 sproto.new/sproto.c \
 sproto.new/lsproto.c \
 pbc/binding/lua/pbc-lua.c \
 -o Plugins/linux/x86_64/tolua.so \
 -I./ \
 -Iluajit-2.1/src \
 -Iluasocket \
 -Isproto.new \
 -Ipbc \
 -Icjson \
 -Wl,--whole-archive \
 linux/x86_64/libluajit.a \
 linux/x86_64/libpbc.a \
 -Wl,--no-whole-archive -static-libgcc -static-libstdc++

# 检查编译结果
if [ -f "Plugins/linux/x86_64/tolua.so" ]; then
    echo "✅ 编译成功！"
    echo "生成的库文件："
    ls -lh Plugins/linux/x86_64/tolua.so
    file Plugins/linux/x86_64/tolua.so

    # 恢复原文件
    mv cjson/lua_cjson.c.bak cjson/lua_cjson.c

    echo ""
    echo "=== 编译完成！==="
    echo "生成的文件: Plugins/linux/x86_64/tolua.so"
else
    echo "❌ 编译失败"
    # 恢复原文件
    mv cjson/lua_cjson.c.bak cjson/lua_cjson.c
    exit 1
fi
