#!/usr/bin/env lua

-- 测试 tolua 库加载
print("=== 测试 tolua 库 ===")

-- 尝试加载库
local ok, tolua = pcall(require, "Plugins/linux/x86_64/tolua")

if ok then
    print("✅ tolua 库加载成功!")
    print("tolua 版本:", tolua._VERSION or "未知")
    
    -- 测试基本功能
    if tolua.int64 then
        print("✅ int64 模块可用")
    end
    
    if tolua.uint64 then
        print("✅ uint64 模块可用") 
    end
    
    print("tolua 模块内容:")
    for k, v in pairs(tolua) do
        print("  ", k, type(v))
    end
else
    print("❌ tolua 库加载失败:", tolua)
    print("这在Mac上是正常的，因为编译出的是Mac格式，不是Linux格式")
end