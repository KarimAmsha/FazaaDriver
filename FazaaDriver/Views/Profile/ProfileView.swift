//
//  ProfileView.swift
//  Wishy
//
//  Created by Karim Amsha on 30.04.2024.
//

import SwiftUI
import PopupView

struct ProfileView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var initialViewModel = InitialViewModel(errorHandling: ErrorHandling())
    @StateObject private var authViewModel = AuthViewModel(errorHandling: ErrorHandling())
    @EnvironmentObject var appState: AppState

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        AsyncImageView(
                            width: 70,
                            height: 70,
                            cornerRadius: 12,
                            imageURL: UserSettings.shared.user?.image?.toURL(),
                            placeholder: Image(systemName: "person.crop.square"),
                            contentMode: .fill
                        )

                        Text(UserSettings.shared.user?.full_name ?? "")
                            .customFont(weight: .bold, size: 14)
                            .foregroundColor(.black121212())

                        Text(UserSettings.shared.user?.phone_number ?? "")
                            .customFont(weight: .bold, size: 14)
                            .foregroundColor(.black121212())
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Pre-define all rows
//                    let editProfileRow = settingsRow(title: "تعديل الملف الشخصي", icon: "person.crop.circle") {
//                        appRouter.navigate(to: .editProfile)
//                    }

//                    let walletRow = settingsRow(title: "المحفظة", icon: "creditcard") {
//                        appRouter.navigate(to: .walletView)
//                    }
//
//                    let rewardsRow = settingsRow(title: "نقاطي", icon: "star") {
//                        appRouter.navigate(to: .rewards)
//                    }

                    let contactRow = settingsRow(title: "تواصل معنا", icon: "message") {
                        appRouter.navigate(to: .contactUs)
                    }

//                    let addressRow = settingsRow(title: "عناويني", icon: "mappin.and.ellipse") {
//                        appRouter.navigate(to: .addressBook)
//                    }

                    let usagePolicyRow = settingsRow(title: "سياسة الاستخدام", icon: "heart") {
                        if let item = initialViewModel.constantsItems?.first(where: { $0.constantType == .using }) {
                            appRouter.navigate(to: .constant(item))
                        }
                    }

                    let privacyPolicyRow = settingsRow(title: "سياسة الخصوصية", icon: "lock") {
                        if let item = initialViewModel.constantsItems?.first(where: { $0.constantType == .privacy }) {
                            appRouter.navigate(to: .constant(item))
                        }
                    }

                    let shareAppRow = settingsRow(title: "مشاركة التطبيق", icon: "arrowshape.turn.up.right") {
                        appRouter.togglePopup(.shareApp)
                    }

                    let logoutRow = settingsRow(title: "تسجيل الخروج", icon: "rectangle.portrait.and.arrow.right", isDestructive: true) {
                        logout()
                    }

                    let deleteRow = settingsRow(title: "حذف الحساب", icon: "trash", isDestructive: true) {
                        deleteAccount()
                    }

                    // Settings List
                    VStack(spacing: 0) {
//                        editProfileRow
//                        walletRow
//                        rewardsRow
                        contactRow
//                        addressRow
                        usagePolicyRow
                        privacyPolicyRow
                        shareAppRow
                        logoutRow
                        deleteRow
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top)
            }
        }
        .navigationBarBackButtonHidden()
        .background(Color.background())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    AsyncImageView(
                        width: 36,
                        height: 36,
                        cornerRadius: 8,
                        imageURL: UserSettings.shared.user?.image?.toURL(),
                        placeholder: Image(systemName: "person.crop.square"),
                        contentMode: .fill
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: 16, height: 16)
                            .background(Circle().fill(Color.black121212()))
                            .overlay(Image(systemName: "gearshape.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.white))
                            .offset(x: 8, y: 8), alignment: .bottomTrailing
                    )
                    .onTapGesture {
                        appRouter.navigate(to: .editProfile)
                    }
                    
                    Text("الملف الشخصي! 🙆🏻‍♀️")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                }
            }
        }
        .onAppear {
            getConstants()
        }
    }

    @ViewBuilder
    func settingsRow(title: String, icon: String, badge: String? = nil, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .customFont(weight: .bold, size: 14)
                        .foregroundColor(isDestructive ? .red : .black121212())

                    Text(title)
                        .customFont(weight: .bold, size: 14)
                        .foregroundColor(isDestructive ? .red : .black121212())

                    if let badge = badge {
                        Spacer()
                        Text(badge)
                            .font(.caption)
                            .padding(6)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }

                    Spacer()

                    Image(systemName: "chevron.left")
                        .customFont(weight: .bold, size: 14)
                        .foregroundColor(.black121212())
                }

                CustomDivider()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppRouter())
        .environmentObject(AppState())
}

extension ProfileView {
    private func getConstants() {
        initialViewModel.fetchConstantsItems()
    }

    private func logout() {
        let alertModel = AlertModel(icon: "",
                                    title: LocalizedStringKey.logout,
                                    message: LocalizedStringKey.logoutMessage,
                                    hasItem: false,
                                    item: nil,
                                    okTitle: LocalizedStringKey.logout,
                                    cancelTitle: LocalizedStringKey.back,
                                    hidesIcon: true,
                                    hidesCancel: true) {
            authViewModel.logoutUser {
                appState.currentPage = .home
            }
            appRouter.dismissPopup()
        } onCancelAction: {
            appRouter.dismissPopup()
        }

        appRouter.togglePopup(.alert(alertModel))
    }

    private func deleteAccount() {
        let alertModel = AlertModel(icon: "",
                                    title: LocalizedStringKey.deleteAccount,
                                    message: LocalizedStringKey.deleteAccountMessage,
                                    hasItem: false,
                                    item: nil,
                                    okTitle: LocalizedStringKey.deleteAccount,
                                    cancelTitle: LocalizedStringKey.back,
                                    hidesIcon: true,
                                    hidesCancel: true) {
            authViewModel.deleteAccount {
                appState.currentPage = .home
            }
            appRouter.dismissPopup()
        } onCancelAction: {
            appRouter.dismissPopup()
        }

        appRouter.togglePopup(.alert(alertModel))
    }
}

struct ShareSheetView: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
