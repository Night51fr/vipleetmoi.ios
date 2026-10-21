import SwiftUI

// MARK: - Onglet 1 : Tableau de Bord & Suivi Conso par Profil (Famille & Pro)

public struct DashboardView: View {
    @EnvironmentObject private var appModel: VipleEtMoiViewModel

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                VipleAnimatedBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        welcomeHeroCard

                        if appModel.isAuthenticated {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("CHOISIR UN PROFIL (FAMILLE OU PRO)")
                                        .font(.system(size: 11, weight: .black, design: .rounded))
                                        .foregroundStyle(VipleEtMoiPalette.textMuted)
                                    Spacer()
                                    if let prof = appModel.selectedProfile {
                                        Text("Filtre : \(prof.firstName)")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(VipleEtMoiPalette.cyan)
                                    }
                                }
                                ProfileSwitcherBarView()
                            }

                            if appModel.pendingContractsCount > 0 {
                                pendingContractAlertBanner
                            }

                            activeProfileConsoSection
                        }

                        vipleUniversesShowcaseGrid
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
            .navigationTitle("Viple & Moi")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if appModel.isAuthenticated {
                            appModel.isShowingCreateProfileSheet = true
                        } else {
                            appModel.isShowingAuthSheet = true
                        }
                    } label: {
                        if appModel.isAuthenticated {
                            Text("\(Image(systemName: "person.badge.plus")) Profil")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                        } else {
                            Text("\(Image(systemName: "person.crop.circle.badge.checkmark")) Connexion")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                        }
                    }
                    .tint(VipleEtMoiPalette.cyan)
                }
            }
            .refreshable {
                await appModel.refreshBootstrap()
            }
        }
    }

    // MARK: - Carte d'Accueil Viple & Moi

    private var welcomeHeroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Text(appModel.selectedProfile?.avatarEmoji ?? appModel.account?.avatarEmoji ?? "✨")
                    .font(.system(size: 30))
                    .frame(width: 58, height: 58)
                    .background(Circle().fill(Color.white.opacity(0.18)))

                VStack(alignment: .leading, spacing: 4) {
                    if let profile = appModel.selectedProfile {
                        Text("Espace de \(profile.firstName)")
                            .font(.system(size: 21, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text("\(profile.roleLabel) • \(profile.servicesCount) service(s) rattaché(s)")
                            .font(.system(size: 12.5, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                    } else if let account = appModel.account {
                        Text("Bonjour, \(account.fullName) 👋")
                            .font(.system(size: 21, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Compte Viple (\(account.accountMode)) • \(appModel.profiles.count) profil(s) configuré(s)")
                            .font(.system(size: 12.5, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                    } else {
                        Text("Bienvenue sur Viple & Moi")
                            .font(.system(size: 21, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Gérez vos forfaits mobiles, Box 5G, contrats Agence IT et votre bibliothèque Livria.")
                            .font(.system(size: 12.5, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
                Spacer()
            }

            if !appModel.isAuthenticated {
                Button {
                    appModel.isShowingAuthSheet = true
                } label: {
                    HStack {
                        Image(systemName: "person.crop.circle.fill.badge.checkmark")
                        Text("Me connecter ou créer mon compte Viple")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                        Spacer()
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .foregroundStyle(VipleEtMoiPalette.ink)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(Color.white))
                }
            } else {
                HStack(spacing: 10) {
                    Button {
                        appModel.isShowingCreateProfileSheet = true
                    } label: {
                        Label("Créer un profil (Enfant / Pro)", systemImage: "person.badge.plus")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 13)
                            .padding(.vertical, 9)
                            .background(Capsule().fill(Color.white.opacity(0.18)))
                    }

                    Button {
                        appModel.isShowingSubscribeSheet = true
                    } label: {
                        Label("Ajouter une ligne / contrat", systemImage: "plus.circle.fill")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundStyle(VipleEtMoiPalette.ink)
                            .padding(.horizontal, 13)
                            .padding(.vertical, 9)
                            .background(Capsule().fill(Color.white))
                    }
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(VipleEtMoiPalette.heroGradient)
                .shadow(color: VipleEtMoiPalette.primary.opacity(0.35), radius: 16, x: 0, y: 8)
        )
    }

    // MARK: - Alerte Contrat à Signer

    private var pendingContractAlertBanner: some View {
        Button {
            appModel.selectedTab = 2
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "signature")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(VipleEtMoiPalette.amber)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(VipleEtMoiPalette.amber.opacity(0.18)))

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(appModel.pendingContractsCount) contrat(s) en attente de votre signature")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Touchez ici pour signer électroniquement sur Viple Contractuel et activer la ligne.")
                        .font(.system(size: 11.5))
                        .foregroundStyle(VipleEtMoiPalette.textMuted)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(VipleEtMoiPalette.amber)
            }
            .padding(14)
            .vipleGlassCard()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Section Suivi Conso Temps Réel du Profil Sélectionné

    private var activeProfileConsoSection: some View {
        let items = appModel.filteredServices

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(appModel.selectedProfile != nil
                     ? "SUIVI CONSO DE \(appModel.selectedProfile!.firstName.uppercased())"
                     : "SUIVI CONSO & LIGNES RATTACHÉES")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(VipleEtMoiPalette.cyan)
                Spacer()
                if !items.isEmpty {
                    let totalMonthly = items.reduce(0.0) { $0 + $1.priceMonthlyTtc }
                    Text(String(format: "Total : %.2f € / mois", totalMonthly))
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(VipleEtMoiPalette.emerald)
                }
            }

            if items.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.doc.horizontal.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(VipleEtMoiPalette.cyan)

                    if let prof = appModel.selectedProfile {
                        Text("Aucun forfait ou service rattaché à \(prof.firstName)")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Rattachez un Forfait Mobile, une Box 5G, un Décodeur TV ou un service IT au profil de \(prof.firstName) pour voir son suivi conso en direct dès que vous cliquez sur son prénom.")
                            .font(.system(size: 12.5))
                            .foregroundStyle(VipleEtMoiPalette.textMuted)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Aucun contrat ou ligne actif sur ce compte")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Ajoutez un premier service (Forfait Mobile, Box 5G, Téléphonie SIP, Décodeur TV ou Contrat Agence IT) et attribuez-le au profil de votre choix.")
                            .font(.system(size: 12.5))
                            .foregroundStyle(VipleEtMoiPalette.textMuted)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        appModel.isShowingSubscribeSheet = true
                    } label: {
                        Label(
                            appModel.selectedProfile != nil
                                ? "Rattacher une offre à \(appModel.selectedProfile!.firstName)"
                                : "Ajouter mon 1er forfait ou contrat Viple",
                            systemImage: "plus.circle.fill"
                        )
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 11)
                        .background(Capsule().fill(VipleEtMoiPalette.cyanGradient))
                    }
                }
                .padding(22)
                .frame(maxWidth: .infinity)
                .vipleGlassCard()
            } else {
                ForEach(items) { service in
                    ServiceConsoLiveCard(service: service)
                }
            }
        }
    }

    // MARK: - Grille des 7 Univers Viple (Agence IT, Mobile, Box 5G, SIP, TV)

    private var vipleUniversesShowcaseGrid: some View {
        let universes: [(code: String, title: String, subtitle: String, icon: String, color: Color)] = [
            ("forfait-mobile", "Forfait Mobile", "5G Famille, Junior & Pro", "iphone.gen3", VipleEtMoiPalette.cyan),
            ("box-5g", "Box 5G Maison & Pro", "Internet Très Haut Débit sans fibre", "wifi.router.fill", Color(hex: "#8B5CF6")),
            ("decodeur-tv", "Décodeur TV 4K", "Chaînes HD/4K & Bouquets", "tv.and.mediabox.fill", VipleEtMoiPalette.rose),
            ("telephonie-sip", "Téléphonie SIP", "Fixe IP & Standard Cloud", "phone.connection.fill", Color(hex: "#14B8A6")),
            ("hebergement-serveur", "Hébergement & VPS", "Serveurs Web, Cloud & Domaines", "server.rack", VipleEtMoiPalette.amber),
            ("infogerance", "Infogérance IT", "Maintenance parc & Cybersécurité", "shield.lefthalf.filled.badge.checkmark", VipleEtMoiPalette.emerald),
            ("creation-web-logiciels", "Création Web & Apps", "Sites internet & Logiciels sur mesure", "laptopcomputer.and.iphone", Color(hex: "#F43F5E")),
            ("livria", "Ma Bibliothèque Livria", "Achats, suivi UPS & lectures", "books.vertical.fill", VipleEtMoiPalette.primary)
        ]

        return VStack(alignment: .leading, spacing: 12) {
            Text("TOUS VOS UNIVERS VIPLE & AGENCE IT")
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(VipleEtMoiPalette.textMuted)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(universes, id: \.code) { item in
                    Button {
                        if item.code == "livria" {
                            appModel.selectedTab = 3
                        } else {
                            appModel.preselectedCatalogCategory = item.code
                            appModel.isShowingSubscribeSheet = true
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: item.icon)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(item.color)
                                .frame(width: 42, height: 42)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(item.color.opacity(0.16))
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.system(size: 13, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                Text(item.subtitle)
                                    .font(.system(size: 10.5))
                                    .foregroundStyle(VipleEtMoiPalette.textMuted)
                                    .lineLimit(2)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(12)
                        .vipleGlassCard()
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Carte Animée de Suivi Conso d'une Ligne / Contrat

public struct ServiceConsoLiveCard: View {
    @EnvironmentObject private var appModel: VipleEtMoiViewModel
    public let service: VipleEtMoiServiceModel

    public init(service: VipleEtMoiServiceModel) {
        self.service = service
    }

    public var body: some View {
        let color = VipleEtMoiPalette.categoryColor(service.category)

        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: VipleEtMoiPalette.categoryIcon(service.category))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(color)
                    .frame(width: 46, height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(color.opacity(0.16))
                    )

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(service.title)
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                        Spacer()
                        Text(service.status)
                            .font(.system(size: 10.5, weight: .black))
                            .foregroundStyle(service.isPendingSignature ? VipleEtMoiPalette.amber : VipleEtMoiPalette.emerald)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill((service.isPendingSignature ? VipleEtMoiPalette.amber : VipleEtMoiPalette.emerald).opacity(0.16))
                            )
                    }

                    Text("Profil : \(service.assignedProfileName) • \(service.identifierLabel)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(color)
                }
            }

            // Bloc Jauge Circulaire + Détails Conso
            HStack(spacing: 16) {
                AnimatedConsoRingView(
                    used: service.consoPrimaryUsed,
                    maxVal: service.consoPrimaryMax,
                    unit: service.consoPrimaryUnit,
                    color: color,
                    size: 88
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text(service.consoPrimaryLabel)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(VipleEtMoiPalette.emerald)
                            .font(.caption)
                        Text("\(service.consoSecondaryLabel) : \(service.consoSecondaryValue)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.88))
                    }

                    HStack(spacing: 10) {
                        Text(String(format: "Hors-forfait : %.2f €", service.outOfPlanEur))
                            .font(.system(size: 11.5, weight: .bold))
                            .foregroundStyle(service.outOfPlanBlocked ? VipleEtMoiPalette.emerald : VipleEtMoiPalette.amber)

                        if service.outOfPlanBlocked {
                            Text("🔒 Hors-forfait bloqué")
                                .font(.system(size: 10.5, weight: .black))
                                .foregroundStyle(VipleEtMoiPalette.emerald)
                        }
                    }

                    Text(String(format: "%.2f € / mois • %@", service.priceMonthlyTtc, service.commitmentLabel))
                        .font(.system(size: 11.5, weight: .semibold))
                        .foregroundStyle(VipleEtMoiPalette.textMuted)
                }
                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.05))
            )

            // Bouton d'action rapide si le contrat attend une signature ou pour changer de profil
            HStack(spacing: 10) {
                if service.isPendingSignature {
                    Button {
                        appModel.selectedTab = 2
                    } label: {
                        Label("Signer le contrat pour activer", systemImage: "signature")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(VipleEtMoiPalette.ink)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(VipleEtMoiPalette.amber))
                    }
                }

                Menu {
                    ForEach(appModel.profiles) { prof in
                        Button {
                            Task {
                                await appModel.assignServiceToProfile(serviceId: service.id, profileId: prof.id)
                            }
                        } label: {
                            Label("Rattacher à \(prof.firstName) (\(prof.roleLabel))", systemImage: "person.fill.checkmark")
                        }
                    }
                } label: {
                    Label("Changer de profil (\(service.assignedProfileName))", systemImage: "arrow.left.arrow.right.circle")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.white.opacity(0.08)))
                }

                Spacer()
            }
        }
        .padding(16)
        .vipleGlassCard()
    }
}
