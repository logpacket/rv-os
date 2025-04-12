#![no_std] // 표준 라이브러리 사용 안 함
#![no_main] // Rust의 일반적인 진입점 사용 안 함

use core::panic::PanicInfo;
use core::ptr;
use aarch64_cpu::asm;
use aarch64_cpu::registers;
use aarch64_cpu::registers::Writeable;


// UART 주소 - QEMU virt 머신 모델 기준 (실제 하드웨어는 다를 수 있음)
const UART_BASE: usize = 0x09000000;

// UART 레지스터 오프셋
const UART_DR: usize = 0x00;    // 데이터 레지스터
const UART_FR: usize = 0x18;    // 플래그 레지스터
const UART_FR_TXFF: u8 = 1 << 5;  // TX FIFO full

// 패닉 핸들러
#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    // 패닉 메시지 출력
    unsafe {
        uart_puts(b"PANIC: OS crashed!\n\r");
    }
    loop {}
}

/// UART 초기화
unsafe fn uart_init() {
    // 실제 하드웨어에서는 여기서 UART를 구성해야 하지만,
    // QEMU의 virt 모델은 기본적으로 초기화된 UART를 제공합니다.
}

/// UART를 통해 한 글자 출력 (volatile 연산 없이 직접 메모리 접근)
unsafe fn uart_putc(c: u8) {
    // 가능한 가장 단순한 구현: 항상 출력하고 대기하지 않음
    // QEMU의 가상 UART는 대부분 항상 출력 준비가 되어있음
    
    // 데이터 레지스터에 직접 쓰기 (포인터 사용)
    let uart_dr = (UART_BASE + UART_DR) as *mut u32;
    *uart_dr = c as u32;
}

/// UART를 통해 문자열 출력 - 더 간단한 구현
unsafe fn uart_puts(s: &[u8]) {
    // 간소화된 구현: 복잡한 이터레이터 대신 단순 인덱스 사용
    let mut i = 0;
    while i < s.len() {
        uart_putc(s[i]);
        i += 1;
    }
}

// ARM64 예외 벡터 테이블 초기화 함수
unsafe fn setup_exception_vectors() {
    // VBAR_EL1 (Vector Base Address Register)에 벡터 테이블 주소 설정
    // 이 예제에서는 간단한 더미 벡터 테이블을 사용합니다
    asm::barrier::isb(asm::barrier::SY);
    
    extern "C" {
        // 링크 시 심볼이 해석됨
        static _vectors: u64;
    }
    
    // 벡터 테이블 주소를 VBAR_EL1에 설정
    let vbar = &_vectors as *const u64 as u64;
    registers::VBAR_EL1.set(vbar);
    
    asm::barrier::isb(asm::barrier::SY);
    
    // 디버깅용 메시지
    uart_puts(b"Exception vectors initialized\n\r");
}

/// 커널 진입점
#[no_mangle]
pub extern "C" fn rust_main() -> ! {
    // ARM64 어셈블리에서 이 함수를 호출함
    
    // UART 초기화
    unsafe {
        // UART 초기화
        uart_init();
        
        // 화면에 명확한 경계선 표시
        uart_puts(b"\n\r======================\n\r");
        uart_puts(b"RV-OS booting via QEMU...\n\r");
        uart_puts(b"======================\n\r\n\r");
    }
    
    // UART를 통해 "RV-OS ARM64" 텍스트 출력
    let text = b"RV-OS ARM64 Boot\n\r";
    
    unsafe {
        uart_puts(text);
        
        // 중요: 예외 벡터 테이블 초기화
        setup_exception_vectors();
        
        // QEMU에게 OS가 성공적으로 부팅되었음을 알림
        uart_puts(b"QEMU boot completed - OS is running\n\r");
    }
    
    // CPU 무한 루프
    loop {
        // ARM에서의 전력 절약 모드 (WFE: Wait For Event)
        asm::wfe();
    }
}

// 기존 _start와 main 함수 제거 - 어셈블리에서 정의된 _start와 충돌 방지