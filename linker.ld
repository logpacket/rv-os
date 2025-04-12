/* 
 * linker.ld - 커스텀 링커 스크립트 for QEMU AArch64
 */

ENTRY(_start)

SECTIONS
{
    /* QEMU의 ARM64 머신은 보통 0x40080000에서 시작 */
    . = 0x40080000;
    
    /* 커널 시작 */
    _kernel_start = .;

    /* 실행 코드와 읽기 전용 데이터 */
    .text :
    {
        KEEP(*(.text.boot))    /* 부트 코드 섹션 */
        KEEP(*(.text.vectors)) /* 예외 벡터 테이블 */
        *(.text*)              /* 일반 코드 */
        *(.rodata*)            /* 읽기 전용 데이터 */
        . = ALIGN(4096);       /* 페이지 정렬 */
    }

    /* 초기화된 데이터 */
    .data :
    {
        *(.data*)
        . = ALIGN(16);
    }
    
    /* BSS 섹션 (초기화되지 않은 데이터) */
    .bss :
    {
        _bss_start = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(16);
        _bss_end = .;
    }
    
    /* 스택 정의 (16KB) */
    .stack :
    {
        . = ALIGN(16);
        _stack_start = .;
        . += 16 * 1024;  /* 16KB 스택 */
        _stack_end = .;
    }
    
    /* 페이지 테이블 공간 예약 */
    .page_tables :
    {
        . = ALIGN(4096);
        _page_tables_start = .;
        . += 16 * 4096;  /* 16 페이지 테이블 (필요에 따라 조정) */
        _page_tables_end = .;
    }

    /* 커널 끝 */
    _kernel_end = .;
    
    /* 불필요한 섹션 버리기 */
    /DISCARD/ :
    {
        *(.comment)
        *(.note*)
        *(.eh_frame*)
    }
}
