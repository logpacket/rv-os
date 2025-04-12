.global kernel_entry
.extern rust_main

.section .text
kernel_entry:
    /* UART에 디버깅 메시지 출력 - 'O', 'S' 문자 */
    movz    x9, #0x0900, lsl #16 /* QEMU PL011 UART 베이스 주소 */
    mov     w10, #79             /* ASCII 'O' */
    str     w10, [x9]
    mov     w10, #83             /* ASCII 'S' */
    str     w10, [x9]
    
    /* 간소화된 부팅: 페이지 테이블 설정 건너뛰기 (초기 디버깅용) */
    /* 직접 rust_main 함수 호출 */
    bl      rust_main

    /* 여기에 도달하면 안됨 */
    b       hang

/* ARM에서는 페이지 테이블 설정이 다릅니다 */
setup_page_tables:
    /* 페이지 테이블 기본 주소 설정 */
    ldr     x0, =lvl1_page_table
    
    /* 항상 현재 위치에서 2MB 매핑 (identity mapping) */
    /* 1GB 단위로 4개의 큰 페이지를 매핑 */
    mov     x1, #0
    mov     x2, #4
    
1:  
    /* 1GB 블록 매핑 (level 1 descriptor) */
    lsl     x3, x1, #30             /* 1GB 단위로 주소 계산 */
    mov     w5, #0x401
    orr     x3, x3, x5            /* Block descriptor + access flag */
    str     x3, [x0, x1, lsl #3]   
    
    add     x1, x1, #1
    cmp     x1, x2
    b.lt    1b
    
    ret

/* MMU 활성화 */
enable_mmu:
    /* 페이지 테이블 주소 TTBR0_EL1에 로드 */
    ldr     x0, =lvl1_page_table
    msr     ttbr0_el1, x0
    
    /* TCR(Translation Control Register) 설정 */
    /* 4GB 주소 공간, 4KB 그래뉼, TTBR0 사용 */
    ldr     x0, =0x00000012345510
    msr     tcr_el1, x0
    
    /* MAIR(Memory Attribute Indirection Register) 설정 */
    /* 메모리 속성 설정 (0=장치, FF=정상) */
    ldr     x0, =0x000000000000FF44
    msr     mair_el1, x0
    
    /* SCTLR(System Control Register) 설정하여 MMU 활성화 */
    mrs     x0, sctlr_el1
    orr     x0, x0, #1              /* MMU 활성화 비트 설정 */
    msr     sctlr_el1, x0
    
    /* 명령어 동기화 장벽 */
    isb
    
    ret

/* 에러 발생 시 무한 루프 */
hang:
    wfe                     /* 이벤트 대기 */
    b       hang           /* 무한 루프 */

/* ARM에서는 x86의 GDT와 같은 세그먼트 개념이 없습니다 */
/* 대신 익셉션 레벨(Exception Level)을 사용합니다 */

.bss
.align 12  /* 4096바이트 정렬 (2^12) */
lvl1_page_table:
    .space 4096
lvl2_page_table:
    .space 4096 * 4  /* 4개의 레벨 2 페이지 테이블 */
stack_bottom:
    .space 4096 * 4  /* 16KB 스택 크기 */
stack_top:
