import SwiftUI

// MARK: - Onglet 2 : Mes Services & Contrats Agence IT / Télécom (Gestion par Profil, Options & Souscription)

public struct ServicesHubView: View {
    @EnvironmentObject private var appModel: VipleEtMoiViewModel

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                VipleAnimatedBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        if appModel.isAuthenticated {
                            ProfileSwitcherBarView()
                        }

                        // Services actifs du profil sélectionné
                        if !appModel.filteredServices.isEmpty {
                            Text(appModel.selectedProfile != nil
                                 ? "SERVICES DE \(appModel.selectedProfile!.firstName.uppercased()) (\(appModel.filteredServices.count))"
                                 : "VOS SERVICES & LIGNES ACTIVES (\(appModel.filteredServices.count))")
                                .font(.system(size: 11.5, weight: .black, design: .rounded))
                                .foregroundStyle(VipleEtMoiPalette.cyan)

                            ForEach(appModel.filteredServices) { service in
                                ServiceManagementCard(service: service)
                            }
                        }

                        // Catalogue pour ajouter un service
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("CATALOGUE VIPLE (AGENCE IT, MOBILE, BOX 5G, TV & SIP)")
                                    .font(.system(size: 11.5, weight: .black, design: .rounded))
                                    .foregroundStyle(VipleEtMoiPalette.amber)
                                Spacer()
                            }

                            Text("Nous proposons des Box 5G Très Haut Débit clé en main (sans offre fibre), des forfaits mobiles pour toute la famille ou l'entreprise, la téléphonie SIP, les décodeurs TV et tous les contrats de l'Agence IT Viple.")
                                .font(.system(size: 12))
                                .foregroundStyle(VipleEtMoiPalette.textMuted)

                            ForEach(appModel.catalog) { offer in
                                CatalogOfferCard(offer: offer) {
                                    appModel.preselectedCatalogCategory = offer.category
                                    appModel.isShowingSubscribeSheet = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
            .navigationTitle("Mes Services & IT")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        appModel.preselectedCatalogCategory = nil
                        appModel.isShowingSubscribeSheet = true
                    } label: {
                        Text("\(Image(systemName: "plus.circle.fill")) Souscrire")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                    }
                    .tint(VipleEtMoiPalette.cyan)
                }
            }
            .refreshable {
                await appModel.refreshBootstrap()
            }
        }
    }
}

private struct ServiceManagementCard: View {
    @EnvironmentObject private var appModel: VipleEtMoiViewModel
    let service: VipleEtMoiServiceModel

    var body: some View {
        let color = VipleEtMoiPalette.categoryColor(service.category)

        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(VipleEtMoiPalette.categoryLabel(service.category), systemImage: VipleEtMoiPalette.categoryIcon(service.category))
                    .font(.system(size: 11.5, weight: .black, design: .rounded))
                    .foregroundStyle(color)

                Spacer()

                Text("Profil : \(service.assignedProfileName)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(color.opacity(0.28)))
            }

            Text(service.title)
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text("Identifiant : \(service.identifierLabel) • \(String(format: "%.2f € / mois", service.priceMonthlyTtc))")
                .font(.system(size: 12.5, weight: .semibold))
                .foregroundStyle(VipleEtMoiPalette.textMuted)

            // Options activables en 1 clic (ex: Blocage hors-forfait pour le forfait du fils)
            if !service.options.isEmpty {
                Divider().overlay(Color.white.opacity(0.08))

                Text("OPTIONS & PROTECTIONS DU SERVICE")
                    .font(.system(size: 10.5, weight: .black, design: .rounded))
                    .foregroundStyle(VipleEtMoiPalette.textMuted)

                ForEach(service.options) { opt in
                    Button {
                        Task {
                            await appModel.toggleServiceOption(serviceId: service.id, optionCode: opt.code)
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: opt.enabled ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 18))
                                .foregroundStyle(opt.enabled ? VipleEtMoiPalette.emerald : VipleEtMoiPalette.textMuted)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(opt.label)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(.white)
                                Text(opt.description)
                                    .font(.system(size: 11))
                                    .foregroundStyle(VipleEtMoiPalette.textMuted)
                            }
                            Spacer()
                            Text(opt.priceMonthlyTtc > 0 ? String(format: "+%.2f €", opt.priceMonthlyTtc) : "Inclus")
                                .font(.system(size: 11, weight: .black))
                                .foregroundStyle(opt.enabled ? VipleEtMoiPalette.emerald : VipleEtMoiPalette.textMuted)
                        }
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack {
                Menu {
                    ForEach(appModel.profiles) { prof in
                        Button {
                            Task {
                                await appModel.assignServiceToProfile(serviceId: service.id, profileId: prof.id)
                            }
                        } label: {
                            Label("Attribuer à \(prof.firstName)", systemImage: "person.crop.circle.badge.checkmark")
                        }
                    }
                } label: {
                    Label("Attribuer à un autre profil", systemImage: "person.2.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(VipleEtMoiPalette.cyan)
                }

                Spacer()

                Button(role: .destructive) {
                    Task {
                        await appModel.deleteService(serviceId: service.id)
                    }
                } label: {
                    Label("Résilier", systemImage: "trash")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(VipleEtMoiPalette.rose)
                }
            }
            .padding(.top, 4)
        }
        .padding(16)
        .vipleGlassCard()
    }
}

private struct CatalogOfferCard: View {
    let offer: VipleCatalogOfferModel
    let onSelect: () -> Void

    var body: some View {
        let color = Color(hex: offer.accentHex)

        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: offer.iconName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(color)
                    .frame(width: 42, height: 42)
                    .background(RoundedRectangle(cornerRadius: 12).fill(color.opacity(0.16)))

                VStack(alignment: .leading, spacing: 2) {
                    Text(offer.categoryLabel.uppercased())
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(color)
                    Text(offer.title)
                        .font(.system(size: 15.5, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 1) {
                    Text(String(format: "%.2f €", offer.priceMonthlyTtc))
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text("/ mois")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(VipleEtMoiPalette.textMuted)
                }
            }

            Text(offer.subtitle)
                .font(.system(size: 12.5))
                .foregroundStyle(.white.opacity(0.86))

            ForEach(offer.highlights, id: \.self) { point in
                HStack(spacing: 6) {
                    Image(systemName: "sparkle")
                        .font(.caption2)
                        .foregroundStyle(color)
                    Text(point)
                        .font(.system(size: 11.5))
                        .foregroundStyle(VipleEtMoiPalette.textMuted)
                }
            }

            Button(action: onSelect) {
                Text("Choisir cette offre & rattacher à un profil")
                    .font(.system(size: 12.5, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(color))
            }
            .padding(.top, 2)
        }
        .padding(15)
        .vipleGlassCard()
    }
}

// MARK: - Feuille de Souscription & Rattachement à un Profil (ex: Forfait Mobile pour son fils)

public struct SubscribeServiceSheetView: View {
    @EnvironmentObject private var appModel: VipleEtMoiViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedOfferCode: String = "mob-junior-20go"
    @State private var selectedProfileId: Int = 0
    @State private var customIdentifier: String = ""

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section("1. Choisissez l'offre Viple (Agence IT & Télécom)") {
                    Picker("Offre Viple", selection: $selectedOfferCode) {
                        ForEach(appModel.catalog) { offer in
                            Text("\(offer.categoryLabel) — \(offer.title) (\(String(format: "%.2f €/mois", offer.priceMonthlyTtc)))")
                                .tag(offer.offerCode)
                        }
                    }
                }

                Section("2. À quel profil rattacher ce service ?") {
                    if appModel.profiles.isEmpty {
                        Text("Connectez-vous ou créez un profil pour rattacher cette offre.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Profil utilisateur", selection: $selectedProfileId) {
                            ForEach(appModel.profiles) { prof in
                                Text("\(prof.avatarEmoji) \(prof.firstName) (\(prof.roleLabel))")
                                    .tag(prof.id)
                            }
                        }
                    }
                }

                Section("3. Numéro / Domaine / Référence (Optionnel)") {
                    TextField("Laissez vide pour attribution automatique (ex: 06..., domaine.fr)", text: $customIdentifier)
                }
            }
            .navigationTitle("Ajouter un Service Viple")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let preCat = appModel.preselectedCatalogCategory,
                   let match = appModel.catalog.first(where: { $0.category == preCat }) {
                    selectedOfferCode = match.offerCode
                } else if let first = appModel.catalog.first {
                    selectedOfferCode = first.offerCode
                }
                if let activePid = appModel.selectedProfileId {
                    selectedProfileId = activePid
                } else if let firstProf = appModel.profiles.first {
                    selectedProfileId = firstProf.id
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Valider & Générer le contrat") {
                        Task {
                            let ok = await appModel.subscribeService(
                                offerCode: selectedOfferCode,
                                profileId: selectedProfileId,
                                identifierLabel: customIdentifier
                            )
                            if ok {
                                dismiss()
                                appModel.selectedTab = 2 // Basculer vers Viple Contractuel pour signer
                            }
                        }
                    }
                }
            }
        }
    }
}
