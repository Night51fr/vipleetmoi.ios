import SwiftUI

// MARK: - Design System Animé & Coloré « Viple & Moi » (Famille & Pro)

public enum VipleEtMoiPalette: Sendable {
    public static let ink = Color(hex: "#080B1A")
    public static let surface = Color(hex: "#12172E")
    public static let cardGlass = Color(hex: "#1A2142")
    public static let primary = Color(hex: "#6366F1")    // Indigo Viple
    public static let cyan = Color(hex: "#06B6D4")       // Cyan Mobile / 5G
    public static let rose = Color(hex: "#EC4899")       // Rose TV / Web
    public static let amber = Color(hex: "#F59E0B")      // Ambre Serveurs / Livria
    public static let emerald = Color(hex: "#10B981")    // Émeraude Actif / Infogérance
    public static let textPrimary = Color.white
    public static let textMuted = Color(hex: "#94A3B8")

    public static let heroGradient = LinearGradient(
        colors: [Color(hex: "#4F46E5"), Color(hex: "#7C3AED"), Color(hex: "#EC4899")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let cyanGradient = LinearGradient(
        colors: [Color(hex: "#06B6D4"), Color(hex: "#3B82F6")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static let emeraldGradient = LinearGradient(
        colors: [Color(hex: "#10B981"), Color(hex: "#059669")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    public static func categoryColor(_ category: String) -> Color {
        switch category {
        case "forfait-mobile": return cyan
        case "box-5g": return Color(hex: "#8B5CF6")
        case "decodeur-tv": return rose
        case "telephonie-sip": return Color(hex: "#14B8A6")
        case "hebergement-serveur": return amber
        case "infogerance": return emerald
        case "creation-web-logiciels": return Color(hex: "#F43F5E")
        default: return primary
        }
    }

    public static func categoryIcon(_ category: String) -> String {
        switch category {
        case "forfait-mobile": return "iphone.gen3"
        case "box-5g": return "wifi.router.fill"
        case "decodeur-tv": return "tv.and.mediabox.fill"
        case "telephonie-sip": return "phone.connection.fill"
        case "hebergement-serveur": return "server.rack"
        case "infogerance": return "shield.lefthalf.filled.badge.checkmark"
        case "creation-web-logiciels": return "laptopcomputer.and.iphone"
        default: return "sparkles"
        }
    }

    public static func categoryLabel(_ category: String) -> String {
        switch category {
        case "forfait-mobile": return "Forfait Mobile"
        case "box-5g": return "Box 5G"
        case "decodeur-tv": return "Décodeur TV"
        case "telephonie-sip": return "Téléphonie SIP"
        case "hebergement-serveur": return "Hébergement & Serveurs"
        case "infogerance": return "Infogérance IT"
        case "creation-web-logiciels": return "Création Web & Logiciels"
        default: return "Service Viple"
        }
    }
}

public extension Color {
    init(hex: String) {
        let clean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: clean).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch clean.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 99, 102, 241)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Fond Animé Viple & Moi

public struct VipleAnimatedBackground: View {
    public init() {}

    public var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#070A18"), Color(hex: "#111633"), Color(hex: "#1B1035")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Circle()
                .fill(VipleEtMoiPalette.primary.opacity(0.18))
                .frame(width: 320, height: 320)
                .blur(radius: 65)
                .offset(x: -120, y: -220)
            Circle()
                .fill(VipleEtMoiPalette.cyan.opacity(0.14))
                .frame(width: 280, height: 280)
                .blur(radius: 60)
                .offset(x: 140, y: 180)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Barre Sélecteur de Profils (Famille & Pro : ex. Chris, Prénom de mon fils, Collaborateur)

public struct ProfileSwitcherBarView: View {
    @EnvironmentObject private var appModel: VipleEtMoiViewModel

    public init() {}

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // Pastille « Vue globale »
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                        appModel.selectedProfileId = nil
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 12, weight: .bold))
                        Text("Tous (\(appModel.services.count))")
                            .font(.system(size: 13, weight: .black, design: .rounded))
                    }
                    .foregroundStyle(appModel.selectedProfileId == nil ? .white : VipleEtMoiPalette.textMuted)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(
                        Capsule()
                            .fill(
                                appModel.selectedProfileId == nil
                                    ? AnyShapeStyle(VipleEtMoiPalette.heroGradient)
                                    : AnyShapeStyle(Color.white.opacity(0.07))
                            )
                    )
                }
                .buttonStyle(.plain)

                // Pastille de chaque profil (ex: Chris, Prénom de mon fils, etc.)
                ForEach(appModel.profiles) { profile in
                    let isSelected = appModel.selectedProfileId == profile.id
                    let accent = Color(hex: profile.accentColor)

                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                            appModel.selectedProfileId = profile.id
                        }
                    } label: {
                        HStack(spacing: 7) {
                            Text(profile.avatarEmoji)
                                .font(.system(size: 15))
                            VStack(alignment: .leading, spacing: 1) {
                                Text(profile.firstName)
                                    .font(.system(size: 13, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                                Text(profile.roleLabel)
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.75))
                            }
                            if profile.servicesCount > 0 {
                                Text("\(profile.servicesCount)")
                                    .font(.system(size: 10, weight: .black))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(Color.black.opacity(0.28)))
                            }
                        }
                        .padding(.horizontal, 13)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(isSelected ? accent : Color.white.opacity(0.07))
                                .overlay(
                                    Capsule()
                                        .stroke(isSelected ? Color.white.opacity(0.6) : accent.opacity(0.35), lineWidth: 1.5)
                                )
                        )
                        .scaleEffect(isSelected ? 1.03 : 1.0)
                    }
                    .buttonStyle(.plain)
                }

                // Bouton rapide « + Profil » (pour ajouter un enfant ou un collaborateur)
                Button {
                    appModel.isShowingCreateProfileSheet = true
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(VipleEtMoiPalette.cyan)
                        Text("Ajouter un profil")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(
                        Capsule()
                            .strokeBorder(style: StrokeStyle(lineWidth: 1.2, dash: [4]))
                            .foregroundStyle(VipleEtMoiPalette.cyan.opacity(0.7))
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 2)
        }
    }
}

// MARK: - Jauge Circulaire Animée de Suivi Conso

public struct AnimatedConsoRingView: View {
    public let used: Double
    public let maxVal: Double
    public let unit: String
    public let color: Color
    public let size: CGFloat

    public init(used: Double, maxVal: Double, unit: String, color: Color, size: CGFloat = 92) {
        self.used = used
        self.maxVal = maxVal
        self.unit = unit
        self.color = color
        self.size = size
    }

    private var ratio: Double {
        guard maxVal > 0 else { return 0 }
        return min(1.0, max(0.04, used / maxVal))
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.10), lineWidth: 9)

            Circle()
                .trim(from: 0, to: ratio)
                .stroke(
                    AngularGradient(
                        colors: [color, color.opacity(0.65), color],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 9, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: ratio)

            VStack(spacing: 1) {
                Text(String(format: used.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.1f", used))
                    .font(.system(size: size * 0.23, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                Text("/ \(Int(maxVal)) \(unit)")
                    .font(.system(size: size * 0.11, weight: .bold, design: .rounded))
                    .foregroundStyle(VipleEtMoiPalette.textMuted)
            }
        }
        .frame(width: size, height: size)
    }
}

public extension View {
    func vipleGlassCard() -> some View {
        self.background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(VipleEtMoiPalette.cardGlass.opacity(0.86))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.18), Color.white.opacity(0.04)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.28), radius: 14, x: 0, y: 6)
        )
    }
}
