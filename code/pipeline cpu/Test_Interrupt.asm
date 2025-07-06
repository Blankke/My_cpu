# Test program for ECALL and MRET instructions
# This program demonstrates system call (ECALL) and return from interrupt (MRET)

.text
.globl _start

_start:
    # Initialize some registers for testing
    addi x1, x0, 10       # x1 = 10
    addi x2, x0, 20       # x2 = 20
    add  x3, x1, x2       # x3 = x1 + x2 = 30
    
    # System call - this should trigger an interrupt
    ecall                 # Generate system call exception
    
    # This instruction should execute after returning from interrupt handler
    addi x4, x0, 1        # x4 = 1 (should execute after MRET)
    
    # Loop to prevent program from ending
loop:
    addi x5, x5, 1        # x5++
    beq  x0, x0, loop     # Infinite loop

# Interrupt handler (would be at interrupt vector 0x40000000)
interrupt_handler:
    # Save context (simplified - just one register)
    addi x10, x0, 0xFF    # Mark that we're in interrupt handler
    
    # Do some interrupt processing
    addi x11, x0, 42      # x11 = 42 (some interrupt work)
    
    # Return from interrupt
    mret                  # Return to interrupted program

.data
# No data section needed for this test
