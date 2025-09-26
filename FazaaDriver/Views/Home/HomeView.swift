//
//  HomeView.swift
//  Fazaa
//
//  Created by Karim Amsha on 28.04.2024.
//

import SwiftUI
import SkeletonUI
import RefreshableScrollView
import FirebaseMessaging

// صندوق الإحصائية
struct StatBox: View {
    var title: String
    var count: Int

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "#F2F3F7"))
                Image(systemName: "square.grid.2x2")
                    .foregroundColor(Color(hex: "#98A0AF"))
                    .font(.system(size: 28, weight: .medium))
            }
            .frame(height: 52)
            Text(title)
                .customFont(weight: .semiBold, size: 15)
                .foregroundColor(.black)
            Text("\(count)")
                .customFont(weight: .bold, size: 19)
                .foregroundColor(Color(hex: "#113E72"))
        }
        .frame(height: 110)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 13)
                .fill(Color(hex: "#F2F3F7"))
        )
    }
}

// الهوم فيو
struct HomeView: View {
    @StateObject var viewModel = OrderViewModel(errorHandling: ErrorHandling())
    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var userViewModel = UserViewModel(errorHandling: ErrorHandling())
    @StateObject private var locationManager = LocationManager2()
    @State private var currentIndex = 0
    let timer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 🔥 جزء الإحصائيات بالأعلى
                VStack(alignment: .trailing, spacing: 14) {
                    LazyVGrid(columns: [GridItem(), GridItem()], spacing: 14) {
                        StatBox(title: "قيد التنفيذ", count: viewModel.orderCount.progress)
                        StatBox(title: "المقبولة", count: viewModel.orderCount.accpeted)
                        StatBox(title: "المنتهية", count: viewModel.orderCount.finished)
                        StatBox(title: "الملغية", count: viewModel.orderCount.cancelded)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
            }
            .padding(.top)
        }
        .background(Color.white)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack(spacing: 8) {
                    AsyncImage(url: URL(string: UserSettings.shared.user?.image ?? "")) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 36, height: 36)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 36, height: 36)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(hex: "#DFE2E6"), lineWidth: 1))
                        case .failure:
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .foregroundColor(.gray)
                                .frame(width: 36, height: 36)
                        @unknown default:
                            EmptyView()
                        }
                    }

                    Text(LocalizedStringKey.statistics)
                        .customFont(weight: .bold, size: 20)
                        .foregroundColor(.black)
                }
            }
        }

        .onAppear {
            viewModel.getOrderCount()
            refreshFcmToken()
            locationManager.startUpdatingLocation()
            ChatViewModel.setUser()
        }
    }
    
    func refreshFcmToken() {
        Messaging.messaging().token { token, error in
            if let token = token {
                let params: [String: Any] = [
                    "id": UserSettings.shared.id ?? "",
                    "fcmToken": token
                ]
                userViewModel.refreshFcmToken(params: params, onsuccess: {})
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppRouter())
}
