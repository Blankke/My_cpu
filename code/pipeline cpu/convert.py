#!/usr/bin/env python3
"""
转换objdump格式的汇编文件为test.dat格式
用于RISC-V CPU测试
"""

import re
import sys

def parse_objdump_to_dat(input_file, output_file):
    """将objdump格式的汇编转换为test.dat格式"""
    instructions = {}
    
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 匹配指令行的正则表达式
    # 格式: address:	instruction	assembly
    pattern = r'^\s*([0-9a-f]+):\s+([0-9a-f]{8})\s+'
    
    for line in content.split('\n'):
        match = re.match(pattern, line)
        if match:
            addr_str = match.group(1)
            instr_str = match.group(2)
            
            # 转换地址为整数
            addr = int(addr_str, 16)
            
            # 检查是否为4字节对齐
            if addr % 4 == 0:
                instructions[addr // 4] = instr_str
    
    # 找到最大地址
    if not instructions:
        print("没有找到有效的指令")
        return
    
    max_addr = max(instructions.keys())
    
    # 写入test.dat文件
    with open(output_file, 'w') as f:
        for i in range(max_addr + 1):
            if i in instructions:
                f.write(instructions[i] + '\n')
            else:
                f.write('00000013\n')  # nop指令
    
    print(f"成功生成 {output_file}，包含 {max_addr + 1} 条指令")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("用法: python convert.py input.s output.dat")
        sys.exit(1)
    
    parse_objdump_to_dat(sys.argv[1], sys.argv[2])
