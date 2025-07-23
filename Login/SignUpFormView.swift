import Foundation
import SwiftUI
import FirebaseFirestore
import CoreLocation

// MARK: - 모델 정의
struct Region: Codable {
    let district: String
    let towns: [String]
}

// MARK: - JSON 로딩 함수
func loadRegionData() -> [Region] {
    guard let url = Bundle.main.url(forResource: "seoul_regions", withExtension: "json"),
          let data = try? Data(contentsOf: url),
          let regions = try? JSONDecoder().decode([Region].self, from: data) else {
        return []
    }
    return regions
}

// MARK: - 부모 정보 입력 화면
struct SignUpFormView: View {
    @Binding var kakaoId: String
    @Binding var isLoggedIn: Bool

    @State private var nickname = ""
    @State private var selectedDistrict = ""
    @State private var selectedTown = ""
    @State private var regionList: [Region] = []

    @State private var activeTime = "오전"
    @State private var parentStatus = "전업 육아중"
    @State private var nicknameError: String? = nil
    @State private var goToChildForm = false

    let activeTimes = ["오전", "오후"]
    let parentStatuses = ["전업 육아중", "육아휴직중", "직장인", "기타"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    ProgressView(value: 0.33)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color.softPink))
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("부모의 정보를 입력해주세요.")
                            .font(.title2)
                            .bold()
                        Text("언제든지 프로필 수정할 수 있어요.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("닉네임")
                            .foregroundColor(Color.softPink)

                        TextField("사용할 닉네임을 적어주세요.", text: $nickname)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: nickname) { newValue in
                                if newValue.count == 1 {
                                    nicknameError = "2자 이상으로 작성해주세요."
                                } else if newValue.count > 6 {
                                    nicknameError = "6자 이하로 작성해주세요."
                                } else {
                                    nicknameError = nil
                                }
                            }

                        if let error = nicknameError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.top, 2)
                        }
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("주 활동 지역")
                            .foregroundColor(Color.softPink) +
                        Text("   친구 매칭에 활용되는 정보입니다.")
                            .font(.footnote)
                            .foregroundColor(.gray)

                        HStack(spacing: 12) {
                            Text("서울특별시")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.softPink))
                                .foregroundColor(.blue)

                            Picker("구 선택", selection: $selectedDistrict) {
                                ForEach(regionList.map { $0.district }, id: \.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 120)
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.softPink))

                            Picker("동 선택", selection: $selectedTown) {
                                ForEach(regionList.first(where: { $0.district == selectedDistrict })?.towns ?? [], id: \.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(width: 120)
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.softPink))
                        }
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading) {
                        Text("주 활동 시간대")
                            .foregroundColor(Color.softPink)
                        HStack {
                            ForEach(activeTimes, id: \.self) { time in
                                Button {
                                    activeTime = time
                                } label: {
                                    Text(time)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(activeTime == time ? Color.softPink : .clear)
                                        .foregroundColor(activeTime == time ? .white : .gray)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.softPink)
                                        )
                                        .cornerRadius(20)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading) {
                        Text("부모 상태")
                            .foregroundColor(Color.softPink)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                            ForEach(parentStatuses, id: \.self) { status in
                                Button {
                                    parentStatus = status
                                } label: {
                                    Text(status)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity)
                                        .background(parentStatus == status ? Color.softPink : .clear)
                                        .foregroundColor(parentStatus == status ? .white : .gray)
                                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.softPink))
                                        .cornerRadius(20)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // ✅ 다음 버튼
                    Button("다 음") {
                        print("✅ 입력값:")
                        print("카카오 ID: \(kakaoId)")

                        if nickname.count < 2 {
                            nicknameError = "2자 이상으로 작성해주세요."
                        } else if nickname.count > 6 {
                            nicknameError = "6자 이하로 작성해주세요."
                        } else {
                            nicknameError = nil

                            // ✅ 주소 기반 지오코딩
                            let address = "\(selectedDistrict) \(selectedTown)"
                            geocodeAddress(address) { coordinate in
                                guard let coordinate = coordinate else { return }

                                let db = Firestore.firestore()
                                db.collection("users").document(kakaoId).setData([
                                    "parent_nickname": nickname,
                                    "region_address": address,
                                    "available_time": [activeTime],
                                    "parent_status": parentStatus,
                                    "region_lat": coordinate.latitude,
                                    "region_lng": coordinate.longitude
                                ], merge: true)

                                goToChildForm = true
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.softPink)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .onAppear {
                regionList = loadRegionData()
                selectedDistrict = regionList.first?.district ?? ""
                selectedTown = regionList.first?.towns.first ?? ""
            }
            .navigationDestination(isPresented: $goToChildForm) {
                ChildFormView(kakaoId: kakaoId, isLoggedIn: $isLoggedIn)
            }
        }
    }
}

// MARK: - 주소 → 좌표 변환
func geocodeAddress(_ address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(address) { placemarks, error in
        if let coordinate = placemarks?.first?.location?.coordinate {
            completion(coordinate)
        } else {
            print("❌ 지오코딩 실패: \(error?.localizedDescription ?? "")")
            completion(nil)
        }
    }
}

