#pragma GCC push_options
#pragma GCC optimize("O0")
typedef unsigned short uint16_t;
typedef unsigned char uint8_t;
typedef unsigned int uint32_t;

#define SW_REG (*(volatile uint16_t *)0xF0000000)      // 16位开关
#define DISPLAY_REG (*(volatile uint32_t *)0xE0000000) // 显示设备

// 函数声明
__attribute__ ((noinline)) void guess(unsigned int cnt);

void start()
{
  asm("li\tsp,1024\n\t" // 设置栈指针
      "call main");     // 跳转到main
}
 __attribute__ ((noinline)) void wait(int instr_num) {
 while (instr_num--) ;
 }
void main()
{
    unsigned int cnt=1;
    while (1)
    {
        unsigned int sw=SW_REG;
        if(((sw >> 8) & 0x01) == 1)
        {
            guess(cnt);
        }
        else
        {
            cnt=cnt+1;
            if(cnt>511)
            cnt=1;
            wait(10);
        }
    }
}
void guess(unsigned int cnt)
{
    while(1)
    {
        unsigned int sw=SW_REG;
        if(((sw >> 8) & 0x01) != 1)
        {
            return;
        }
        
        switch (sw & 0x0018)
        {
            case 0x0008:
            {
                const uint8_t n = (sw >> 8) & 0xFF;
                if (n>cnt)
                {
                    DISPLAY_REG= 0xFF83F990;
                }
                else if (n<cnt)
                {
                    DISPLAY_REG= 0xC7C7C7C7;
                }
                else if (n==cnt)
                {
                    DISPLAY_REG=0x88C688C6;
                }
                break;
            }
            case 0x0010:
            {
                DISPLAY_REG=cnt;
                break;
            }
            default:
            {
                const uint8_t n = (sw >> 8) & 0xFF;
                DISPLAY_REG=n;
                break;
            }
        }
    }
}