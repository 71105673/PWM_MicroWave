# 🌀 FPGA Microwave Project

## 📌 프로젝트 개요
Basys3 FPGA 보드와 DC 모터, L298N 모터 드라이버를 활용하여 전자레인지를 구현한 프로젝트입니다.  
PWM 기반 모터 제어와 FSM 설계를 통해 실제 전자레인지 동작(시간 설정, 시작, 동작, 종료)을 FPGA 상에서 재현했습니다.

- **개발 환경:** Verilog, Vivado  
- **하드웨어 구성:** Basys3, L298N, DC Motor  
- **사용 IO:** JA port, DIP Switch(0번), 버튼 5개, LED(0번)  

---

## ⚙️ 아키텍처
- **FSM (Control Unit):** `IDLE → SELECT_SEC → SELECT_MIN → RUN → FINISH`  
- **버튼 디바운싱:** 10ms 지연을 두어 채터링 방지  
- **PWM 출력:** RUN 상태에서 DC 모터 구동  
- **시뮬레이션:** 카운트 값을 축소하여 동작 검증 (예: 1000 → 10)  

---

## 🎯 주요 기능
- **시간 설정** : 버튼 입력으로 초/분 단위 설정  
- **동작 제어** : RUN 상태에서 모터 PWM 구동  
- **종료 처리** : 남은 시간이 0이 되면 FINISH로 전환 후 IDLE 상태 복귀  
- **디바운싱 처리** : 버튼 입력 안정화  

---

## 🧪 시뮬레이션 & 결과
- 버튼 디바운싱 검증 (10ms 지연 후 입력 값 반영)  
- FSM 전이 검증 (`IDLE → SELECT → RUN → FINISH → IDLE`)  
- PWM 출력 파형 확인 및 모터 구동 성공  

---

## 🔍 프로젝트 고찰
- 하드웨어 설계에서 **버튼 디바운싱과 FSM 제어의 중요성**을 체감  
- 실제 모터 제어를 FPGA로 구현하며 **디지털 설계와 임베디드 하드웨어 제어의 연계성**을 경험  
- FSM 구조 설계를 통해 **시스템 동작 흐름의 가시화와 확장성**을 확인  

---

## 📷 시각 자료
> 전체 구성 
>
> ![alt text](<image/스크린샷 2025-10-08 204848.png>) 

> Architecture
>
>![alt text](<image/스크린샷 2025-10-08 204853.png>) 

> FSM
>
>![alt text](<image/스크린샷 2025-10-08 204900.png>) 

> Simulation
>
> ![alt text](<image/스크린샷 2025-10-08 204909.png>) 
> ![alt text](<image/스크린샷 2025-10-08 204914.png>) 
> ![alt text](<image/스크린샷 2025-10-08 204921.png>) 
> ![alt text](<image/스크린샷 2025-10-08 204937.png>) 
> ![alt text](<image/스크린샷 2025-10-08 204944.png>) 
> ![alt text](<image/스크린샷 2025-10-08 204949.png>) 



## 동작 영상
<video controls src="microwave.mp4" title="Title"></video>
