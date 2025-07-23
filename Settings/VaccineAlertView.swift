//
//  VaccineAlertView.swift
//  Childcare_crew
//
//  Created by 안혜민 on 6/6/25.
//

import SwiftUI
import Firebase

struct VaccineAlertView: View {
    let kakaoId: String

    struct Child: Identifiable {
        let id = UUID()
        let name: String
        let birthdate: String
    }

    @State private var children: [Child] = []
    @State private var selectedIndex: Int = 0

    @State private var childBirthdate: Date = Date()
    @State private var vaccines: [VaccineSchedule] = []
    @State private var vaccineStatus: [String: Bool] = [:]
    @State private var showOnlyNext = true
    @State private var isLoading = false

    let menuColor = Color(red: 0.84, green: 0.93, blue: 1.0)

    var body: some View {
        VStack(alignment: .leading) {
            Text("백신 알림 설정")
                .font(.title2)
                .bold()

            // 아이 선택
            Picker("아이 선택", selection: $selectedIndex) {
                ForEach(children.indices, id: \.self) { idx in
                    Text("\(childOrderLabel(index: idx))").tag(idx)
                }
            }
            .pickerStyle(.segmented)

            // 생일 표시
            if children.indices.contains(selectedIndex) {
                HStack(spacing: 8) {
                    Text("\(childOrderLabel(index: selectedIndex)) 생일")
                        .font(.caption)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(menuColor)
                        .cornerRadius(6)

                    Text(children[selectedIndex].birthdate)
                        .font(.caption)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // 다음 접종만 보기 toggle
            Toggle("다음 접종만 보기", isOn: $showOnlyNext)
                .padding(.vertical, 8)

            Button("📬 접종 일정 불러오기") {
                fetchBirthdateAndVaccines()
            }

            if isLoading {
                ProgressView("불러오는 중...")
            } else {
                List {
                    ForEach(vaccines, id: \.vaccine) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("💉 \(item.vaccine)")
                                    .font(.headline)
                                Spacer()
                                if item.isOverdue {
                                    Image(systemName: vaccineStatus[item.vaccine] == true ? "checkmark.square.fill" : "square")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(.pink)
                                        .onTapGesture {
                                            let new = !(vaccineStatus[item.vaccine] ?? false)
                                            withAnimation {
                                                vaccineStatus[item.vaccine] = new
                                            }
                                            saveVaccineStatusToFirestore(vaccine: item.vaccine, status: new)
                                        }
                                } else {
                                    Toggle(isOn: Binding(
                                        get: { vaccineStatus[item.vaccine] ?? false },
                                        set: { newValue in
                                            vaccineStatus[item.vaccine] = newValue
                                            saveVaccineStatusToFirestore(vaccine: item.vaccine, status: newValue)
                                        }
                                    )) {
                                        EmptyView()
                                    }
                                    .toggleStyle(SwitchToggleStyle(tint: .pink))
                                }
                            }

                            Text("예정 월령: \(item.monthLabel)")
                            Text("예상일: \(item.dueDate)")
                            Text(item.isOverdue ? "⚠️ 이미 지난 일정" : "🕐 예정")
                                .foregroundColor(item.isOverdue ? .red : .green)
                                .font(.caption)
                        }
                        .padding(6)
                    }
                }

                Text("백신알림은 알림봇이 한 달 전에 알려줄거에요!")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            }
        }
        .padding()
        .onAppear {
            loadChildrenFromFirestore()
        }
    }

    func childOrderLabel(index: Int) -> String {
        let orders = ["첫째", "둘째", "셋째", "넷째", "다섯째"]
        return index < orders.count ? orders[index] : "아이"
    }

    // 아이 불러오기
    func loadChildrenFromFirestore() {
        let docRef = Firestore.firestore().collection("users").document(kakaoId)
        docRef.getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let childrenData = data["children"] as? [[String: Any]] {
                let parsed = childrenData.compactMap { dict -> Child? in
                    guard let birth = dict["child_birthdate"] as? String else { return nil }
                    return Child(name: "", birthdate: birth)
                }
                self.children = parsed
            }
        }
    }

    func fetchBirthdateAndVaccines() {
        guard children.indices.contains(selectedIndex) else { return }
        isLoading = true

        let birthStr = children[selectedIndex].birthdate
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let birthDate = formatter.date(from: birthStr) {
            self.childBirthdate = birthDate
            postToVaccineAPI(birthStr)
        }
    }

    func postToVaccineAPI(_ birthStr: String) {
        let url = URL(string: "http://127.0.0.1:8000/vaccine_schedule")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "birthdate": birthStr,
            "only_next": showOnlyNext
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            guard let data = data else { return }
            if let result = try? JSONDecoder().decode([VaccineSchedule].self, from: data) {
                DispatchQueue.main.async {
                    self.vaccines = result
                    self.loadVaccineStatusFromFirestore()
                }
            }
        }.resume()
    }

    func saveVaccineStatusToFirestore(vaccine: String, status: Bool) {
        let childId = selectedIndex.description
        let docRef = Firestore.firestore()
            .collection("users")
            .document(kakaoId)
            .collection("vaccine_status_\(childId)")
            .document(vaccine)

        docRef.setData(["done": status], merge: true)
    }

    func loadVaccineStatusFromFirestore() {
        let childId = selectedIndex.description
        let colRef = Firestore.firestore()
            .collection("users")
            .document(kakaoId)
            .collection("vaccine_status_\(childId)")

        colRef.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            var statusDict: [String: Bool] = [:]
            for doc in documents {
                let data = doc.data()
                if let done = data["done"] as? Bool {
                    statusDict[doc.documentID] = done
                }
            }
            DispatchQueue.main.async {
                self.vaccineStatus = statusDict
            }
        }
    }
}

// 백신 스케줄 모델
struct VaccineSchedule: Codable {
    let vaccine: String
    let monthLabel: String
    let dueDate: String
    let isOverdue: Bool

    enum CodingKeys: String, CodingKey {
        case vaccine = "백신"
        case monthLabel = "예정 접종월령"
        case dueDate = "예상 접종일"
        case isOverdue = "지남 여부"
    }
}
