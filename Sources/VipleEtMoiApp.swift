import SwiftUI

@main
public struct VipleEtMoiApp: App {
    @StateObject private var appModel = VipleEtMoiViewModel()

    public init() {}

    public var body: some Scene {
        WindowGroup {
            VipleEtMoiMainTabView()
                .environmentObject(appModel)
                .preferredColorScheme(.dark)
        }
    }
}
