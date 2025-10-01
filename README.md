# GallerySync iOS

갤러리에 있는 이미지, 영상을 클라우드에 보관하고 관리하기 위한 iOS 앱

## 📱 기능

- **갤러리 접근**: 사용자의 사진 및 비디오 라이브러리에 접근
- **클라우드 동기화**: 선택한 미디어를 클라우드 스토리지에 업로드
- **자동 백업**: 새로운 사진/비디오 자동 백업 설정
- **동기화 관리**: 수동/자동 동기화 옵션
- **설정 관리**: 동기화 품질, 계정 설정 등

## 🏗️ 아키텍처

이 프로젝트는 **MVVM-C (Model-View-ViewModel-Coordinator)** 패턴을 사용합니다.

### 폴더 구조

```
GallerySync/
├── App/                    # 앱 생명주기
│   ├── AppDelegate/
│   └── SceneDelegate/
├── Core/                   # 핵심 아키텍처
│   ├── Coordinator/        # Coordinator 패턴
│   ├── Extensions/         # Swift Extensions
│   └── Protocols/          # 공통 프로토콜
├── Features/               # 기능별 모듈
│   ├── Gallery/           # 갤러리 화면
│   │   ├── View/          # UI 컴포넌트
│   │   ├── ViewModel/     # 비즈니스 로직
│   │   ├── Coordinator/   # 네비게이션 로직
│   │   └── Model/         # 데이터 모델
│   ├── CloudSync/         # 클라우드 동기화
│   └── Settings/          # 설정 화면
├── Network/                # 네트워크 계층
│   ├── API/               # API 엔드포인트
│   ├── Models/            # 네트워크 모델
│   └── Services/          # 네트워크 서비스
├── Storage/                # 데이터 저장
│   ├── CoreData/          # 로컬 데이터베이스
│   ├── UserDefaults/      # 설정 저장
│   └── Keychain/          # 보안 저장
├── Resources/              # 리소스 파일
│   ├── Assets/            # 이미지, 아이콘
│   ├── Storyboards/       # 스토리보드
│   ├── Fonts/             # 폰트 파일
│   └── Colors/            # 컬러 정의
└── Utils/                  # 유틸리티
    ├── Helpers/           # 헬퍼 클래스
    ├── Constants/         # 상수 정의
    └── Extensions/        # 확장 기능
```

## 🛠️ 기술 스택

- **언어**: Swift 5.0+
- **최소 iOS 버전**: iOS 14.0+
- **아키텍처**: MVVM-C (Model-View-ViewModel-Coordinator)
- **UI**: UIKit + Combine
- **네트워킹**: URLSession
- **데이터 저장**: CoreData, UserDefaults, Keychain
- **사진 접근**: PhotoKit

## 📋 주요 컴포넌트

### Coordinator 패턴
- **AppCoordinator**: 앱의 메인 흐름 관리
- **GalleryCoordinator**: 갤러리 화면 네비게이션
- **CloudSyncCoordinator**: 동기화 화면 관리
- **SettingsCoordinator**: 설정 화면 관리

### Services
- **PhotoLibraryService**: 사진 라이브러리 접근 및 관리
- **CloudSyncService**: 클라우드 업로드/다운로드
- **StorageService**: 로컬 데이터 저장

### ViewModels
- **GalleryViewModel**: 갤러리 데이터 및 상태 관리
- **CloudSyncViewModel**: 동기화 진행상황 관리
- **SettingsViewModel**: 설정 데이터 관리

## 🚀 시작하기

### 요구사항
- Xcode 13.0+
- iOS 14.0+
- Swift 5.0+

### 설치

1. 프로젝트 클론
```bash
git clone https://github.com/yourusername/gallery_ios.git
cd gallery_ios
```

2. Xcode에서 프로젝트 열기
```bash
open GallerySync.xcodeproj
```

3. 프로젝트 빌드 및 실행

### 권한 설정

Info.plist에 다음 권한을 추가해야 합니다:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>앱에서 사진과 비디오를 클라우드에 백업하기 위해 사진 라이브러리 접근 권한이 필요합니다.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>클라우드에서 다운로드한 사진을 저장하기 위해 사진 라이브러리 접근 권한이 필요합니다.</string>
```

## 🔧 설정

### 클라우드 서비스 설정

`CloudSyncService.swift`에서 클라우드 서비스 설정을 변경할 수 있습니다:

```swift
private let baseURL = "https://api.yourcloudservice.com"
```

### 상수 설정

`Constants.swift`에서 앱의 주요 설정값들을 관리합니다.

## 📱 사용법

1. **갤러리 접근**: 앱 실행 시 사진 라이브러리 권한 요청
2. **사진 선택**: 갤러리에서 업로드할 사진/비디오 선택
3. **클라우드 동기화**: 'Sync' 버튼을 눌러 선택한 미디어 업로드
4. **설정 관리**: 자동 동기화, 품질 설정 등 관리

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 👨‍💻 개발자

- **JokerTrickster** - *Initial work* - [GitHub](https://github.com/JokerTrickster)
- **logan** - *Developer*

---

**Last Updated**: 2025-09-30 00:00:00 KST
