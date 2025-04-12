.global arm64_entry
.extern rust_main

.section .text
arm64_entry:
    /* ARM64에서는 세그먼트 레지스터가 없음 */
    /* 대신 익셉션 레벨(EL)과 시스템 레지스터로 실행 환경 설정 */

    /* UART를 통해 메시지 출력 - QEMU PL011 UART 사용 */
    /* QEMU virt 모델에서는 UART0 주소가 0x09000000 */
    movz    x0, #0x0900, lsl #16  /* 0x09000000 값을 movz로 설정 */
    
    /* UART TX FIFO가 준비될 때까지 대기 */
    add     x2, x0, #0x18      /* 0x09000018 = UART FR (Flag Register) */
    
1:  ldr     w3, [x2]           /* FR 레지스터 값 읽기 */
    and     w3, w3, #0x20      /* TXFF 비트(5번째 비트) 확인 */
    cbnz    w3, 1b             /* TXFF가 1이면 대기 (FIFO full) */

    /* 직접 문자를 출력해서 디버깅 - 'H', 'E', 'L', 'L', 'O' 출력 */
    mov     w1, #72            /* ASCII 'H' */
    str     w1, [x0]
    mov     w1, #69            /* ASCII 'E' */
    str     w1, [x0]
    mov     w1, #76            /* ASCII 'L' */
    str     w1, [x0]
    mov     w1, #76            /* ASCII 'L' */
    str     w1, [x0]
    mov     w1, #79            /* ASCII 'O' */
    str     w1, [x0]
    mov     w1, #10            /* ASCII '\n' */
    str     w1, [x0]
    mov     w1, #13            /* ASCII '\r' */
    str     w1, [x0]
    
2:  /* Rust로 작성된 커널의 rust_main 함수 호출 */
    bl      rust_main

    /* 만약 커널이 반환되면 무한 루프 */
    b       hang

hang:
    wfe                        /* 이벤트 대기 모드 */
    b       hang               /* 무한 루프 */

.section .rodata
boot_message:
    .asciz "RUNNING ARM64 OS\n\r"
    .align 3
