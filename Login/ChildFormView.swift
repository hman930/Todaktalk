import Foundation
import SwiftUI
import FirebaseFirestore

struct ChildProfile: Identifiable {
    let id = UUID()
    var birthdate: Date = Date()
    var gender: String = ""
    var personality: String = ""
    var preferredActivities: [String] = []
}

struct ChildFormView: View {
    @State private var children: [ChildProfile] = [ChildProfile()]
    @State private var selectedChildIndex = 0
    @State private var goToSelfInfo = false
    @Environment(\.dismiss) var dismiss

    let genderOptions = ["남", "여"]
    let personalityOptions = ["조용한", "차분한", "활발함"]
    let activityOptions = ["미술", "독서", "키즈카페", "야외놀이", "물놀이"]

    let kakaoId: String
    @Binding var isLoggedIn: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                contentView
            }
            .navigationDestination(isPresented: $goToSelfInfo) {
                SelfInfoView(kakaoId: kakaoId, isLoggedIn: $isLoggedIn)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("뒤로")
                            .foregroundColor(Color.softPink)
                            .bold()
                    }
                }
            }
        }
    }

    var contentView: some View {
        VStack(spacing: 24) {
            progressBar
            headerView
            childSelector
            birthdatePicker
            genderButtons
            personalityGrid
            activityGrid
            nextButton
        }
        .padding(.top)
    }

    var progressBar: some View {
        ProgressView(value: 0.66)
            .progressViewStyle(LinearProgressViewStyle(tint: Color.softPink))
            .padding(.horizontal)
    }

    var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("아이의 정보를 입력해주세요.")
                .font(.title2)
                .bold()
            Text("언제든지 프로필 수정할 수 있어요.")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    var childSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("아이 선택")
                .foregroundColor(Color.softPink)
                .padding(.horizontal)

            HStack {
                ForEach(children.indices, id: \.self) { index in
                    Button(action: { selectedChildIndex = index }) {
                        let label = ["첫째", "둘째", "셋째", "넷째", "다섯째"]
                        Text(index < label.count ? label[index] : "\(index+1)번째")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedChildIndex == index ? Color.softPink : .clear)
                            .foregroundColor(selectedChildIndex == index ? .white : .gray)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.softPink))
                            .cornerRadius(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                if children.count < 5 {
                    Button(action: {
                        children.append(ChildProfile())
                        selectedChildIndex = children.count - 1
                    }) {
                        Image(systemName: "plus")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.softPink))
                    }
                }

                if children.count > 1 {
                    Button(action: {
                        children.remove(at: selectedChildIndex)
                        selectedChildIndex = max(0, selectedChildIndex - 1)
                    }) {
                        Image(systemName: "minus")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .foregroundColor(.red)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.red))
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    var birthdatePicker: some View {
        let child = $children[selectedChildIndex]
        return VStack(alignment: .leading) {
            Text("생년월일")
                .foregroundColor(Color.softPink)
            DatePicker("날짜 선택", selection: child.birthdate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal)
    }

    var genderButtons: some View {
        let child = $children[selectedChildIndex]
        return VStack(alignment: .leading) {
            Text("성별")
                .foregroundColor(Color.softPink)
            HStack(spacing: 12) {
                ForEach(genderOptions, id: \.self) { gender in
                    Button {
                        child.gender.wrappedValue = gender
                    } label: {
                        Text(gender)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(child.gender.wrappedValue == gender ? Color.softPink : .clear)
                            .foregroundColor(child.gender.wrappedValue == gender ? .white : .gray)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.softPink))
                            .cornerRadius(16)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    var personalityGrid: some View {
        let child = $children[selectedChildIndex]
        return VStack(alignment: .leading) {
            Text("성격")
                .foregroundColor(Color.softPink)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                ForEach(personalityOptions, id: \.self) { option in
                    Button {
                        child.personality.wrappedValue = option
                    } label: {
                        Text(option)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(child.personality.wrappedValue == option ? Color.softPink : .clear)
                            .foregroundColor(child.personality.wrappedValue == option ? .white : .gray)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.softPink))
                            .cornerRadius(20)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    var activityGrid: some View {
        let child = $children[selectedChildIndex]
        return VStack(alignment: .leading, spacing: 4) {
            Text("선호활동")
                .foregroundColor(Color.softPink)
            Text("최대 3개까지 선택가능")
                .font(.caption)
                .foregroundColor(.gray)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                ForEach(activityOptions, id: \.self) { activity in
                    let isSelected = child.preferredActivities.wrappedValue.contains(activity)
                    Button {
                        if isSelected {
                            child.preferredActivities.wrappedValue.removeAll { $0 == activity }
                        } else if child.preferredActivities.wrappedValue.count < 3 {
                            child.preferredActivities.wrappedValue.append(activity)
                        }
                    } label: {
                        Text(activity)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(isSelected ? Color.softPink : .clear)
                            .foregroundColor(isSelected ? .white : .gray)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.softPink))
                            .cornerRadius(20)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    var nextButton: some View {
        Button("다 음") {
            let db = Firestore.firestore()
            let ref = db.collection("users").document(kakaoId)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            let childData = children.enumerated().map { (index, child) in
                return [
                    "child_birthdate": dateFormatter.string(from: child.birthdate),
                    "gender": child.gender,
                    "personality": child.personality,
                    "preferred_activities": child.preferredActivities,
                    "matching_target_index": index
                ]
            }

            ref.setData([
                "child_count": children.count,
                "children": childData,
                "child_personality": children.map { $0.personality }
            ], merge: true)

            goToSelfInfo = true
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.softPink)
        .foregroundColor(.white)
        .cornerRadius(20)
        .padding(.horizontal)
        .padding(.top)
    }
}

