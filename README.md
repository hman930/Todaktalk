# 🍼 Todaktalk - 토닥톡

**토닥톡**은 자녀의 성격, 관심사, 지역을 기반으로  
가장 잘 어울릴 친구를 찾아주는 **맞춤형 매칭 플랫폼**입니다.  
AI 추천 시스템, 챗봇 상담, 지도 기반 시각화 기능까지 탑재된  
부모와 아이 모두를 위한 스마트한 육아 커뮤니티 앱입니다.

---

## ✨ 주요 기능

- 🔐 **소셜 로그인 (카카오 / 네이버)**  
  간편한 인증을 통해 부모 정보 등록, 자녀 정보 연동

- 👶 **자녀 프로필 등록**  
  최대 5명까지 등록 가능 / 생년월일, 성별, 성격, 지역, 선호 활동 포함

- 🧠 **친구 매칭 알고리즘 (Flask API)**  
  자녀의 성격, 관심사, 연령, 지역 기반으로 유사한 친구 추천

- 🗺️ **지도 기반 Playground 분포 시각화**  
  Kakao Maps SDK를 활용해 우리 동네 아이 분포 및 놀이공간 시각화

- 🤖 **RAG 기반 챗봇 상담 (FastAPI + LLM)**  
  인근 시설 추천(TF-IDF), 육아 질문 응답(OpenAI 기반)

- ⏰ **하원시간 및 예방접종 알림 기능**  
  자녀별 하원시간/접종일 설정 → 알림 등록 가능

- 📱 **상단 고정 TopView UI 구성**  
  로고, 알림 아이콘, 햄버거 메뉴 항상 상단 고정 노출

---

## 🛠 기술 스택

| 구분         | 기술 구성                                   |
|--------------|--------------------------------------------|
| 프론트엔드   | `SwiftUI`, `UIKit`, `UIViewControllerRepresentable` |
| 지도 API     | `Kakao Maps SDK (Native)`                  |
| 백엔드       | `Flask` (친구 매칭), `FastAPI` (챗봇)        |
| 데이터베이스 | `Firebase Firestore`, `MySQL`               |
| AI 모델      | `OpenAI API`, `TF-IDF`, `LangChain` 기반 RAG |
| 챗봇 UI      | `Streamlit`, `SwiftUI ChatbotView`          |
| 로그 수집    | `AWS API Gateway`, `Lambda` (플레이 클릭 로그) |

---

## 📂 폴더 구조

```plaintext
Todaktalk/
├── App/
│   ├── LandingView.swift
│   ├── LoginView.swift
│   ├── SignUpFormView.swift
│   ├── ChildFormView.swift
│   ├── SelfInfoView.swift
│   └── ...
├── Match/
│   ├── match_algorithm.py
│   └── app.py
├── Chatbot/
│   ├── rag_chat.py
│   └── streamlit_ui.py
├── Map/
│   ├── PlaygroundMapViewController.swift
│   └── PlaygroundWrapperView.swift
└── Resources/
    └── Assets.xcassets

---

MIT License

Copyright (c) 2025 Todaktalk

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights  
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      
copies of the Software, and to permit persons to whom the Software is         
furnished to do so, subject to the following conditions:                       

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.                                

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  
SOFTWARE.


