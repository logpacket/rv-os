.section .text.boot
.global _start

/* ARM 부트 헤더 - 이것은 ARM64 (AArch64) 바이너리의 시작 부분에 배치됩니다
 * ARM 기기는 일반적으로 U-Boot 또는 기기별 부팅 프로세스를 사용합니다
 */
_start:
    /* 프로세서 식별 및 분기 */
    mrs     x0, mpidr_el1        /* 멀티프로세서 ID 레지스터 읽기 */
    and     x0, x0, #0xFF        /* 최하위 8비트(CPU ID) */
    cbz     x0, master           /* 코어 0이면 마스터 코드로 이동 */
    
    /* 보조 코어는 무한 루프에 빠집니다 */
halt:
    wfe                          /* 이벤트 대기 모드 */
    b       halt                 /* 무한 루프 */

master:
    /* 스택 설정, 시스템이 부팅된 직후에는 스택이 준비되어 있지 않음 */
    /* 스택 포인터에 32MB 설정 (0x42000000) */
    movz    x9, #0x4200, lsl #16 /* QEMU virt 머신에서 안전하게 사용할 수 있는 스택 주소 */
    mov     sp, x9               /* 스택 포인터 설정 */
    
    /* UART 초기 메시지 출력을 위한 셋업 */
    /* QEMU PL011 UART 베이스 주소 (0x09000000) */
    movz    x9, #0x0900, lsl #16
    /* 'R' 문자 출력 */
    mov     w10, #82             /* ASCII 'R' */
    str     w10, [x9]
    /* 'V' 문자 출력 */
    mov     w10, #86             /* ASCII 'V' */
    str     w10, [x9]
    
    /* 다음 부팅 단계로 이동 */
    bl      kernel_entry
