# 🎶 소록 (Solog) - 기억하고 싶은 모든 순간의 음악을 담다

<div align="center">

| App Store 다운로드 바로가기 |
|:---:|
| [![Download on the App Store](https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg)](https://apps.apple.com/kr/app/%EC%86%8C%EB%A1%9D/id6736941716) |

**"그때 그 순간, 우리가 함께 듣던 음악은 무엇이었나요?"**  
소록은 일상의 소중한 순간에 흐르던 음악을 사진과 함께 기록하고,  
언제든 다시 꺼내 들을 수 있도록 Apple Music과 Spotify 플레이리스트로 연결해 주는 서비스입니다.

</div>

<br>

![Main Banner](https://github.com/user-attachments/assets/04a2d787-c02e-4817-af23-a0d89330ccb7)

---

## :pushpin: Features

소록은 단순한 기록을 넘어, 음악과 일상을 하나로 잇는 경험을 제공합니다.

- **순간의 음악 기록**: 지금 들려오는 음악을 사진과 함께 플레이리스트 형태로 기록합니다.
- **외부 서비스 내보내기**: 기록된 플레이리스트를 **Apple Music** 및 **Spotify**로 즉시 내보내어 감상할 수 있습니다.
- **추억 공유**: 소중한 기록을 **Instagram Story**로 공유하여 친구들과 음악적 취향을 나눌 수 있습니다.

---

## 🏗 Architecture & Design Pattern

대규모 협업 환경에서의 코드 복잡도를 낮추고 유지보수성을 극대화하기 위해 다음과 같은 설계를 적용했습니다.

- **MVVM-C (Model-View-ViewModel + Coordinator)**:
    - SwiftUI의 내비게이션 종속성을 제거하기 위해 `BaseCoordinator` 레이어를 도입하여 화면 전환 로직을 뷰에서 완전히 분리했습니다.
- **의존성 관리 (Dependency Injection)**:
    - `ViewModelContainer`를 활용해 ViewModel과 Service 간의 결합도를 낮추고, 단위 테스트 및 코드 재사용성을 확보했습니다.
- **데이터 레이어 추상화**:
    - SwiftData(로컬)와 Firestore(리모트)를 통합 관리하는 `PersistenceService` 추상화 계층을 두어 데이터 소스 변경에 유연하게 대응했습니다.

---

## :sparkles: Skills & Tech Stack

기존 프로젝트에서 사용된 모든 기술 스택과 최신 도입 기술을 포함합니다.

### Development
<img src="https://img.shields.io/badge/Swift-FA7343?style=flat&logo=Swift&logoColor=white" height="25"/> <img src="https://img.shields.io/badge/SwiftUI-FF9E0F?style=flat&logo=Swift&logoColor=white" height="25"/> <img src="https://img.shields.io/badge/Swift_Concurrency-2179EE?style=flat&logo=swift&logoColor=white" height="25"/> <img src="https://img.shields.io/badge/SwiftData-FA7343?style=flat&logo=swift&logoColor=white" height="25"/> <img src="https://img.shields.io/badge/SwiftLint-2179EE?style=flat&logo=swift&logoColor=white" height="25"/>

### Services & Frameworks
<img src="https://img.shields.io/badge/MapKit-007AFF?style=flat&logo=apple&logoColor=white" height="25"/> <img src="https://img.shields.io/badge/ShazamKit-0087D1?style=flat&logo=shazam&logoColor=white" height="25"/> <img src="https://img.shields.io/badge/MusicKit-FF3366?style=flat&logo=applemusic&logoColor=white" height="25"/> <img src="https://img.shields.io/badge/Spotify%20SDK-1DB954?style=flat&logo=spotify&logoColor=white" height="25"/> <img src="https://img.shields.io/badge/Firebase%20Auth-FFCA28?style=flat&logo=firebase&logoColor=white" height="25"/> <img src="https://img.shields.io/badge/Firestore-DD2C00?style=flat&logo=firebase&logoColor=white" height="25"/>

### Infrastructure
<img src="https://img.shields.io/badge/Tuist-36404A?style=flat&logoColor=white" height="25"/> <img src="https://img.shields.io/badge/Sign%20in%20with%20Apple-000000?style=flat&logo=apple&logoColor=white" height="25"/>

---

## 🚀 Technical Challenges & Problem Solving

프로젝트 진행 중 직면한 기술적 한계와 이를 극복한 과정입니다.

### 1. 비동기 로직의 현대화와 데이터 안정성 (GCD ➔ Swift Concurrency)
- **Problem**: 다수의 외부 API(MusicKit, Spotify, Firestore) 연동 시 컴플리션 핸들러 중첩으로 인한 가독성 저하와 데이터 레이스 컨디션 우려가 있었습니다.
- **Solution**: 프로젝트 전체 비동기 아키텍처를 **Swift Concurrency**로 마이그레이션했습니다. 기존 Delegate 패턴을 `CheckedContinuation`으로 래핑하여 선언적인 코드를 작성하고, `Task`와 `Actor`를 통해 데이터 무결성을 보장했습니다.

### 2. 멀티 플랫폼 음악 서비스 통합 아키텍처
- **Problem**: 서로 다른 인증 체계(OAuth vs JWT)와 데이터 모델을 가진 Apple Music과 Spotify를 하나의 로직으로 제어해야 했습니다.
- **Solution**: 서비스 인터페이스를 프로토콜로 추상화하고, 각 플랫폼 전용 어댑터(`MusicService`, `SpotifyService`)를 구현하는 **Adapter Pattern**을 적용하여 클라이언트 코드의 복잡도를 낮췄습니다.

### 3. 지도 기반 대량 데이터 렌더링 최적화
- **Problem**: 사용자의 음악 기록(Annotation)이 많아질수록 지도 탐색 시 프레임 드랍이 발생했습니다.
- **Solution**: MapKit의 클러스터링 기능을 활용하여 인접한 데이터를 그룹화하고, 현재 화면 영역 내의 데이터만 효율적으로 로드하는 최적화 로직을 도입했습니다.

---

## :people_hugging: Contributors

| 정온유 | 홍지흔 | 박현수 | 우태훈 | 최서연 | 허예강 |
|:---:|:---:|:---:|:---:|:---:|:---:|
| (나인 - Nain) | (이블린 - Evelyn) | (수박 - Soopark) | (션 - Sean) | (구리스 - Guryss) | (라프 - Raf) |
| <img src="https://github.com/user-attachments/assets/40130ed1-a3cf-4614-ad73-a09def7919a2" width="130"> | <img src="https://github.com/user-attachments/assets/8cd9e191-7c12-40d7-a999-bdffe2a68ca3" width="130"> | <img src="https://github.com/user-attachments/assets/5dcc4366-924d-4ef5-a96b-f82a8066bc3d" width="130"> | <img src="https://github.com/user-attachments/assets/013ba835-a72e-4c16-aba6-d6e68f83335d" width="130"> | <img src="https://github.com/user-attachments/assets/e0883004-7389-4d72-b060-6ef5c78d593e" width="130"> | <img src="https://github.com/user-attachments/assets/31c568b9-028d-4fa2-900a-3135a8cfd746" width="130"> |
| 🎨 Designer | 🎨 Designer | [🛠️ Developer](https://github.com/00yhsp) | [🛠️ Developer](https://github.com/Sean9701) | [🛠️ Developer](https://github.com/Guryss) | [🛠️ Developer](https://github.com/ye-gang-jjang) |
