import SwiftUI
import UserNotifications

struct DismissalSettingsView: View {
    enum CareType: String, CaseIterable, Codable {
        case kindergarten = "유치원"
        case daycare = "어린이집"
    }

    enum FirstAlertTime: String, CaseIterable, Codable, Identifiable {
        case none = "없음"
        case tenMinutes = "10분 전"
        case thirtyMinutes = "30분 전"

        var id: String { rawValue }

        var offsetMinutes: Int {
            switch self {
            case .tenMinutes: return -10
            case .thirtyMinutes: return -30
            case .none: return 0
            }
        }
    }

    struct ChildDismissalSetting: Identifiable, Codable, Equatable {
        let id = UUID()
        var name: String = ""
        var careType: CareType = .kindergarten
        var dismissalTime: Date = Date()
        var firstAlert: FirstAlertTime = .none
        var alert2Enabled: Bool = false
    }

    @State private var settings: [ChildDismissalSetting] = []
    @State private var showingNewSetting = false
    @State private var newSetting = ChildDismissalSetting()

    var body: some View {
        NavigationView {
            VStack {
                if settings.isEmpty {
                    Text("아직 등록된 하원 알림이 없습니다.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(settings) { setting in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(setting.name) (\(setting.careType.rawValue))")
                                    .font(.headline)
                                Text("하원 시간: \(formatted(setting.dismissalTime))")
                                if setting.firstAlert != .none {
                                    Text("✅ 1차 알림: \(setting.firstAlert.rawValue)")
                                }
                                if setting.alert2Enabled {
                                    Text("✅ 2차 알림: 정각")
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                Button(action: {
                    newSetting = ChildDismissalSetting()
                    showingNewSetting = true
                }) {
                    Label("하원 알림 추가하기", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .padding()
                }
            }
            .navigationTitle("하원 알림 설정")
            .sheet(isPresented: $showingNewSetting) {
                NavigationView {
                    Form {
                        TextField("아이 이름", text: $newSetting.name)

                        Picker("시설 종류", selection: $newSetting.careType) {
                            ForEach(CareType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)

                        DatePicker("하원 시간", selection: $newSetting.dismissalTime, displayedComponents: .hourAndMinute)

                        Picker("1차 알림", selection: $newSetting.firstAlert) {
                            ForEach(FirstAlertTime.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(.segmented)

                        Toggle("2차 알림 (정각)", isOn: $newSetting.alert2Enabled)
                    }
                    .navigationTitle("하원 알림 추가")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("저장") {
                                requestNotificationPermission()
                                scheduleDismissalAlerts(for: newSetting)
                                settings.append(newSetting)
                                showingNewSetting = false
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("취소") {
                                showingNewSetting = false
                            }
                        }
                    }
                }
            }
        }
    }

    func formatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if !granted {
                print("❌ 알림 권한 거부됨")
            }
        }
    }

    func scheduleDismissalAlerts(for setting: ChildDismissalSetting) {
        if setting.firstAlert != .none {
            if let alert1Time = Calendar.current.date(byAdding: .minute, value: setting.firstAlert.offsetMinutes, to: setting.dismissalTime) {
                registerNotification(at: alert1Time, message: "⏰ \(setting.name) 하원 \(setting.firstAlert.rawValue)입니다!", id: "\(setting.id)-alert1")
            }
        }

        if setting.alert2Enabled {
            registerNotification(at: setting.dismissalTime, message: "🎒 \(setting.name)가 하원할 시간이에요!", id: "\(setting.id)-alert2")
        }
    }

    func registerNotification(at date: Date, message: String, id: String) {
        let content = UNMutableNotificationContent()
        content.title = "하원 알림"
        content.body = message
        content.sound = .default

        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 알림 등록 실패: \(error.localizedDescription)")
            }
        }
    }
}
