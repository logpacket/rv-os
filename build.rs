use std::process::Command;
use std::path::Path;
use std::env;

fn main() {
    // 프로젝트 디렉터리 경로
    let out_dir = env::var("OUT_DIR").unwrap();
    let out_path = Path::new(&out_dir);

    // ARM64 어셈블리 파일 빌드 - aarch64 크로스 컴파일러 사용
    // 크로스 컴파일러는 이미 aarch64를 타겟으로 하므로 -arch 옵션 제거
    Command::new("aarch64-elf-as")
        .args(&["-o", &out_path.join("boot_header.o").to_str().unwrap()])
        .arg("src/boot/boot_header.S")
        .status()
        .expect("aarch64-elf-as 명령어 실행 실패 (boot_header)");

    Command::new("aarch64-elf-as")
        .args(&["-o", &out_path.join("boot.o").to_str().unwrap()])
        .arg("src/boot/boot.S")
        .status()
        .expect("aarch64-elf-as 명령어 실행 실패 (boot)");

    Command::new("aarch64-elf-as")
        .args(&["-o", &out_path.join("arm_entry.o").to_str().unwrap()])
        .arg("src/boot/arm_entry.S")
        .status()
        .expect("aarch64-elf-as 명령어 실행 실패 (arm_entry)");
        
    Command::new("aarch64-elf-as")
        .args(&["-o", &out_path.join("vectors.o").to_str().unwrap()])
        .arg("src/boot/vectors.S")
        .status()
        .expect("aarch64-elf-as 명령어 실행 실패 (vectors)");
    
    // 생성된 오브젝트 파일을 Rust에서 참조할 수 있도록 링크 지시어 출력
    println!("cargo:rustc-link-search=native={}", out_path.display());
    println!("cargo:rustc-link-lib=static=boot_header");
    println!("cargo:rustc-link-lib=static=boot");
    println!("cargo:rustc-link-lib=static=arm_entry");
    println!("cargo:rustc-link-lib=static=vectors");
    
    // 어셈블리 라이브러리 생성 - 크로스 컴파일러용 ar 도구 사용
    Command::new("aarch64-elf-ar")
        .args(&["crs", &out_path.join("libboot_header.a").to_str().unwrap(), 
               &out_path.join("boot_header.o").to_str().unwrap()])
        .status()
        .expect("aarch64-elf-ar 명령어 실행 실패 (boot_header)");
        
    Command::new("aarch64-elf-ar")
        .args(&["crs", &out_path.join("libboot.a").to_str().unwrap(), 
               &out_path.join("boot.o").to_str().unwrap()])
        .status()
        .expect("aarch64-elf-ar 명령어 실행 실패 (boot)");
        
    Command::new("aarch64-elf-ar")
        .args(&["crs", &out_path.join("libarm_entry.a").to_str().unwrap(), 
               &out_path.join("arm_entry.o").to_str().unwrap()])
        .status()
        .expect("aarch64-elf-ar 명령어 실행 실패 (arm_entry)");
        
    Command::new("aarch64-elf-ar")
        .args(&["crs", &out_path.join("libvectors.a").to_str().unwrap(), 
               &out_path.join("vectors.o").to_str().unwrap()])
        .status()
        .expect("aarch64-elf-ar 명령어 실행 실패 (vectors)");

    // 재링크 필요 시 링커 스크립트 변경 감지
    println!("cargo:rerun-if-changed=linker.ld");
    println!("cargo:rerun-if-changed=src/boot/boot_header.S");
    println!("cargo:rerun-if-changed=src/boot/boot.S");
    println!("cargo:rerun-if-changed=src/boot/arm_entry.S");
}
