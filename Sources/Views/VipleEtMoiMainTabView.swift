import SwiftUI

// MARK: - Navigation Principale « Viple & Moi » (5 onglets clairs : Suivi Conso, Services & IT, Contrats, Bibliothèque Livria, Compte)

public struct VipleEtMoiMainTabView: View {
    @EnvironmentObject private var appModel: VipleEtMoiViewModel

    public init() {}

    public var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $appModel.selectedTab) {
                DashboardView()
                    .tabItem {
                        Label("Suivi & Profils", systemImage: "chart.pie.fill")
                    }
                    .tag(0)

                ServicesHubView()
                    .tabItem {
                        Label("Mes Services", systemImage: "square.stack.3d.up.fill")
                    }
                    .tag(1)

                ContractsView()
                    .tabItem {
                        Label("Contrats", systemImage: "signature")
                    }
                    .badge(appModel.pendingContractsCount)
                    .tag(2)

                LivriaLibraryAndOrdersView()
                    .tabItem {
                        Label("Ma Bibliothèque", systemImage: "books.vertical.fill")
                    }
                    .tag(3)

                AccountAndProfilesView()
                    .tabItem {
                        Label("Mon Compte", systemImage: "person.2.crop.square.stack.fill")
                    }
                    .tag(4)
            }
            .tint(VipleEtMoiPalette.cyan)

            if let toast = appModel.activeToastMessage {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(VipleEtMoiPalette.emerald)
                    Text(toast)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .background(
                    Capsule()
                        .fill(VipleEtMoiPalette.ink.opacity(0.95))
                        .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 5)
                )
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(99)
            }
        }
        .sheet(isPresented: $appModel.isShowingAuthSheet) {
            VipleEtMoiAuthSheetView()
                .environmentObject(appModel)
        }
        .sheet(isPresented: $appModel.isShowingCreateProfileSheet) {
            CreateProfileSheetView()
                .environmentObject(appModel)
        }
        .sheet(isPresented: $appModel.isShowingSubscribeSheet) {
            SubscribeServiceSheetView()
                .environmentObject(appModel)
        }
    }
}
