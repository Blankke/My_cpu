# Test program for Exception Detection Unit
# This program tests ECALL, MRET, illegal instructions, and address misalignment

.text
.globl _start

_start:
    # Test normal instructions first
    addi x1, x0, 10       # Normal instruction: x1 = 10
    addi x2, x0, 20       # Normal instruction: x2 = 20
    add  x3, x1, x2       # Normal instruction: x3 = x1 + x2 = 30
    
    # Test ECALL - should trigger system call exception
    ecall                 # System call - should be detected by ExceptionDetectionUnit
    
    # This should execute after returning from exception handler
    addi x4, x0, 1        # x4 = 1
    
    # Test illegal instruction (this would be an undefined opcode)
    # .word 0xFFFFFFFF    # Uncomment this to test illegal instruction detection
    
    # Continue with normal execution
    addi x5, x0, 5        # x5 = 5
    
    # Infinite loop
loop:
    addi x6, x6, 1        # x6++
    beq  x0, x0, loop     # Branch always

# Exception handler at interrupt vector (0x40000000)
exception_handler:
    # Save some context
    addi x10, x0, 0xAA    # Mark that we're in exception handler
    
    # Handle the exception based on SCAUSE
    # For ECALL: do system call processing
    addi x11, x0, 42      # Some exception processing work
    
    # Return from exception
    mret                  # Should be detected by ExceptionDetectionUnit, return to saved PC

.data
# Test data section
test_data: .word 0x12345678
