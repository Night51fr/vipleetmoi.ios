import SwiftUI

// MARK: - Onglet 5 : Mon Compte Viple & Gestion des Profils (Famille & Pro)

public struct AccountAndProfilesView: View {
    @EnvironmentObject private var appModel: VipleEtMoiViewModel

    @State private var fullName: String = ""
    @State private var accountMode: String = "Famille"
    @State private var companyName: String = ""
    @State private var siret: String = ""
    @State private var phone: String = ""
    @State private var address: String = ""
    @State private var postalCode: String = ""
    @State private var city: String = ""
    @State private var paymentIban: String = ""

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                VipleAnimatedBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        profilesManagerSection

                        accountDetailsSection

                        invoicesSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
            .navigationTitle("Mon Compte & Profils")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                syncForm()
            }
            .onChange(of: appModel.account?.email) { _, _ in
                syncForm()
            }
        }
    }

    private func syncForm() {
        guard let acc = appModel.account else { return }
        fullName = acc.fullName
        accountMode = acc.accountMode
        companyName = acc.companyName
        siret = acc.siret
        phone = acc.phone
        address = acc.address
        postalCode = acc.postalCode
        city = acc.city
        paymentIban = acc.paymentIban
    }

    // MARK: - Gestionnaire des Profils (Ex: Chris + Prénom de mon fils + Pro)

    private var profilesManagerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("👨‍👩‍👦 VOS PROFILS FAMILLE & COLLABORATEURS")
                    .font(.system(size: 11.5, weight: .black, design: .rounded))
                    .foregroundStyle(VipleEtMoiPalette.cyan)
                Spacer()
                Button {
                    appModel.isShowingCreateProfileSheet = true
                } label: {
                    Label("Nouveau profil", systemImage: "plus.circle.fill")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(VipleEtMoiPalette.cyan)
                }
            }

            Text("Créez un profil pour chaque membre de votre foyer (ex: le prénom de votre fils pour suivre son forfait mobile) ou pour vos collaborateurs professionnels.")
                .font(.system(size: 12))
                .foregroundStyle(VipleEtMoiPalette.textMuted)

            if appModel.profiles.isEmpty {
                Button {
                    appModel.isShowingAuthSheet = true
                } label: {
                    Text("Connectez-vous pour gérer vos profils")
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(Capsule().fill(VipleEtMoiPalette.heroGradient))
                }
            } else {
                ForEach(appModel.profiles) { prof in
                    HStack(spacing: 12) {
                        Text(prof.avatarEmoji)
                            .font(.system(size: 24))
                            .frame(width: 46, height: 46)
                            .background(Circle().fill(Color(hex: prof.accentColor).opacity(0.25)))

                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 6) {
                                Text(prof.firstName)
                                    .font(.system(size: 15, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                                if prof.isPrimary {
                                    Text("Titulaire")
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundStyle(VipleEtMoiPalette.emerald)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Capsule().fill(VipleEtMoiPalette.emerald.opacity(0.18)))
                                }
                            }
                            Text("\(prof.roleLabel) • \(prof.servicesCount) service(s) (\(String(format: "%.2f €/mois", prof.monthlyTotalTtc)))")
                                .font(.system(size: 12))
                                .foregroundStyle(VipleEtMoiPalette.textMuted)
                        }

                        Spacer()

                        Button {
                            appModel.selectedProfileId = prof.id
                            appModel.selectedTab = 0
                        } label: {
                            Text("Voir conso")
                                .font(.system(size: 11.5, weight: .black))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color(hex: prof.accentColor)))
                        }

                        if !prof.isPrimary {
                            Button(role: .destructive) {
                                Task {
                                    await appModel.deleteProfile(profileId: prof.id)
                                }
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(VipleEtMoiPalette.rose)
                            }
                        }
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)))
                }
            }
        }
        .padding(16)
        .vipleGlassCard()
    }

    // MARK: - Coordonnées du Compte Viple Live ID (Mode Famille / Mode Pro)

    private var accountDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🪪 MON COMPTE VIPLE LIVE ID")
                    .font(.system(size: 11.5, weight: .black, design: .rounded))
                    .foregroundStyle(VipleEtMoiPalette.amber)
                Spacer()
                if appModel.isAuthenticated {
                    Button(role: .destructive) {
                        appModel.signOut()
                    } label: {
                        Text("Déconnexion")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(VipleEtMoiPalette.rose)
                    }
                }
            }

            if appModel.isAuthenticated {
                Picker("Usage du compte", selection: $accountMode) {
                    Text("🏠 Usage Familial & Personnel").tag("Famille")
                    Text("🏢 Usage Professionnel / Entreprise").tag("Pro")
                }
                .pickerStyle(.segmented)

                fieldRow("Nom & Prénom du titulaire", text: $fullName)
                if accountMode == "Pro" {
                    fieldRow("Raison sociale / Société", text: $companyName)
                    fieldRow("Numéro SIRET", text: $siret)
                }
                fieldRow("Téléphone de contact", text: $phone)
                fieldRow("Adresse postale", text: $address)
                HStack(spacing: 10) {
                    fieldRow("Code postal", text: $postalCode)
                    fieldRow("Ville", text: $city)
                }
                fieldRow("IBAN Prélèvement Viple (Optionnel)", text: $paymentIban)

                Button {
                    Task {
                        await appModel.updateAccountInfo(
                            fullName: fullName,
                            accountMode: accountMode,
                            companyName: companyName,
                            siret: siret,
                            phone: phone,
                            address: address,
                            postalCode: postalCode,
                            city: city,
                            paymentIban: paymentIban
                        )
                    }
                } label: {
                    Label("Enregistrer mes coordonnées", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(VipleEtMoiPalette.heroGradient))
                }
            } else {
                Text("Connectez-vous avec votre adresse e-mail Viple Live ID (la même que sur Livria Store et Livria Social) pour retrouver tous vos contrats et votre bibliothèque.")
                    .font(.system(size: 12.5))
                    .foregroundStyle(VipleEtMoiPalette.textMuted)

                Button {
                    appModel.isShowingAuthSheet = true
                } label: {
                    Label("Me connecter / Créer mon compte", systemImage: "person.crop.circle.badge.checkmark")
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(VipleEtMoiPalette.ink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color.white))
                }
            }
        }
        .padding(16)
        .vipleGlassCard()
    }

    private func fieldRow(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(VipleEtMoiPalette.textMuted)
            TextField(label, text: text)
                .font(.system(size: 13))
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.08)))
                .foregroundStyle(.white)
        }
    }

    // MARK: - Historique des Factures

    private var invoicesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("🧾 VOS FACTURES VIPLE (\(appModel.invoices.count))")
                .font(.system(size: 11.5, weight: .black, design: .rounded))
                .foregroundStyle(VipleEtMoiPalette.emerald)

            if appModel.invoices.isEmpty {
                Text("Aucune facture émise pour le moment.")
                    .font(.system(size: 12.5))
                    .foregroundStyle(VipleEtMoiPalette.textMuted)
            } else {
                ForEach(appModel.invoices) { inv in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(inv.periodLabel)
                                .font(.system(size: 13.5, weight: .bold))
                                .foregroundStyle(.white)
                            Text("\(inv.invoiceNumber) • Émise le \(inv.issuedAt)")
                                .font(.system(size: 11))
                                .foregroundStyle(VipleEtMoiPalette.textMuted)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(String(format: "%.2f €", inv.amountTtc))
                                .font(.system(size: 14, weight: .black))
                                .foregroundStyle(VipleEtMoiPalette.emerald)
                            Text(inv.status)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(VipleEtMoiPalette.textMuted)
                        }
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.05)))
                }
            }
        }
        .padding(16)
        .vipleGlassCard()
    }
}

// MARK: - Feuille de Création d'un Profil Supplémentaire (Ex: Prénom de mon fils ou Collaborateur Pro)

public struct CreateProfileSheetView: View {
    @EnvironmentObject private var appModel: VipleEtMoiViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var firstName: String = ""
    @State private var roleLabel: String = "Mon fils"
    @State private var profileType: String = "Enfant"
    @State private var avatarEmoji: String = "👦"
    @State private var accentColor: String = "#06b6d4"
    @State private var parentalControlActive: Bool = true
    @State private var outOfPlanBlocked: Bool = true

    private let roleSuggestions = ["Mon fils", "Ma fille", "Conjoint(e)", "Parent", "Collaborateur Pro", "Poste Bureau / IT"]
    private let emojis = ["👦", "👧", "🧑", "👩", "👨", "👨‍💻", "👩‍💼", "🏢", "📱", "🚀"]
    private let colors = ["#06b6d4", "#6366f1", "#ec4899", "#10b981", "#f59e0b", "#8b5cf6"]

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section("Prénom ou nom du profil") {
                    TextField("Ex: Prénom de mon fils, Collaborateur...", text: $firstName)

                    Picker("Rôle", selection: $roleLabel) {
                        ForEach(roleSuggestions, id: \.self) { role in
                            Text(role).tag(role)
                        }
                    }
                    .onChange(of: roleLabel) { _, newRole in
                        if newRole.contains("fils") || newRole.contains("fille") {
                            profileType = "Enfant"
                            parentalControlActive = true
                            outOfPlanBlocked = true
                        } else if newRole.contains("Pro") || newRole.contains("Bureau") {
                            profileType = "Pro"
                            parentalControlActive = false
                        } else {
                            profileType = "Famille"
                        }
                    }
                }

                Section("Icône & Couleur du profil") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(emojis, id: \.self) { em in
                                Button {
                                    avatarEmoji = em
                                } label: {
                                    Text(em)
                                        .font(.system(size: 24))
                                        .padding(8)
                                        .background(
                                            Circle()
                                                .fill(avatarEmoji == em ? Color(hex: accentColor).opacity(0.3) : Color.clear)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    HStack(spacing: 14) {
                        ForEach(colors, id: \.self) { hex in
                            Button {
                                accentColor = hex
                            } label: {
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary, lineWidth: accentColor == hex ? 3 : 0)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section("Sécurité & Suivi Conso") {
                    Toggle("Bloquer automatiquement le hors-forfait", isOn: $outOfPlanBlocked)
                    Toggle("Activer la protection Enfant / Adolescent", isOn: $parentalControlActive)
                }
            }
            .navigationTitle("Nouveau Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Créer le profil") {
                        Task {
                            let ok = await appModel.createProfile(
                                firstName: firstName,
                                roleLabel: roleLabel,
                                profileType: profileType,
                                avatarEmoji: avatarEmoji,
                                accentColor: accentColor,
                                parentalControlActive: parentalControlActive,
                                outOfPlanBlocked: outOfPlanBlocked
                            )
                            if ok { dismiss() }
                        }
                    }
                    .disabled(firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - Feuille de Connexion / Création de Compte Viple Live ID (Sans jargon technique)

public struct VipleEtMoiAuthSheetView: View {
    @EnvironmentObject private var appModel: VipleEtMoiViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var isRegisterMode: Bool = false
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var fullName: String = ""
    @State private var accountMode: String = "Famille"
    @State private var companyName: String = ""
    @State private var phone: String = ""

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Action", selection: $isRegisterMode) {
                        Text("Me connecter").tag(false)
                        Text("Créer mon compte").tag(true)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Votre Compte Viple (Unifié avec Livria)") {
                    TextField("Votre adresse e-mail", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()

                    if isRegisterMode {
                        TextField("Votre prénom et nom (ex: Chris)", text: $fullName)

                        Picker("Type d'espace", selection: $accountMode) {
                            Text("🏠 Famille & Particulier").tag("Famille")
                            Text("🏢 Professionnel & Entreprise").tag("Pro")
                        }

                        if accountMode == "Pro" {
                            TextField("Nom de votre entreprise", text: $companyName)
                        }

                        TextField("Téléphone mobile", text: $phone)
                            .keyboardType(.phonePad)
                    }

                    SecureField("Votre mot de passe", text: $password)
                }

                if let err = appModel.authErrorMessage {
                    Section {
                        Text(err)
                            .foregroundStyle(.red)
                            .font(.caption.bold())
                    }
                }

                Section {
                    Button {
                        Task {
                            if isRegisterMode {
                                await appModel.registerAccount(
                                    email: email,
                                    password: password,
                                    fullName: fullName,
                                    accountMode: accountMode,
                                    companyName: companyName,
                                    phone: phone
                                )
                            } else {
                                await appModel.signIn(email: email, password: password)
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if appModel.isLoading {
                                ProgressView()
                            } else {
                                Text(isRegisterMode ? "Créer mon espace Viple & Moi" : "Accéder à mon espace")
                                    .font(.system(size: 14, weight: .black))
                            }
                            Spacer()
                        }
                    }
                    .disabled(email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || password.isEmpty)
                }
            }
            .navigationTitle("Mon Compte Viple")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }
}
