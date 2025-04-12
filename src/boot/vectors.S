.global _vectors
.section .text.vectors

/*
 * AArch64 예외 벡터 테이블
 * 각 엔트리는 16바이트 (4개 명령어) 정렬되어야 함
 */
.align 11  /* 2^11 = 2048 바이트 정렬 (벡터 테이블 요구사항) */

_vectors:
    /* 현재 EL, SPx에서의 동기식 예외 */
    b       exception_handler  /* 현재 EL, SP0에서의 동기식 예외 */
    .align  7
    /* 현재 EL, SPx에서의 IRQ */
    b       exception_handler
    .align  7
    /* 현재 EL, SPx에서의 FIQ */
    b       exception_handler
    .align  7
    /* 현재 EL, SPx에서의 SError */
    b       exception_handler
    .align  7
    
    /* 현재 EL, SP0에서의 동기식 예외 */
    b       exception_handler
    .align  7
    /* 현재 EL, SP0에서의 IRQ */
    b       exception_handler
    .align  7
    /* 현재 EL, SP0에서의 FIQ */
    b       exception_handler
    .align  7
    /* 현재 EL, SP0에서의 SError */
    b       exception_handler
    .align  7
    
    /* 하위 EL(aarch64)에서의 동기식 예외 */
    b       exception_handler
    .align  7
    /* 하위 EL(aarch64)에서의 IRQ */
    b       exception_handler
    .align  7
    /* 하위 EL(aarch64)에서의 FIQ */
    b       exception_handler
    .align  7
    /* 하위 EL(aarch64)에서의 SError */
    b       exception_handler
    .align  7
    
    /* 하위 EL(aarch32)에서의 동기식 예외 */
    b       exception_handler
    .align  7
    /* 하위 EL(aarch32)에서의 IRQ */
    b       exception_handler
    .align  7
    /* 하위 EL(aarch32)에서의 FIQ */
    b       exception_handler
    .align  7
    /* 하위 EL(aarch32)에서의 SError */
    b       exception_handler
    .align  7

/* 모든 예외를 처리하는 간단한 핸들러 */
exception_handler:
    /* 스택에 x0 저장 */
    sub     sp, sp, #16
    str     x0, [sp]
    
    /* UART를 통해 '!' 출력 */
    movz    x0, #0x0900, lsl #16  /* UART 베이스 주소 0x09000000 */
    mov     w1, #33               /* ASCII '!' */
    str     w1, [x0]
    
    /* 무한 루프 */
    b       exception_handler
