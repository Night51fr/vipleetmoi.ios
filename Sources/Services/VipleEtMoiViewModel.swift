import Foundation
import SwiftUI

// MARK: - ViewModel Principal « Viple & Moi » (Gestion par Profil Famille & Pro, Contrats IT/Mobile/SIP/TV/Box 5G, Viple Contractuel & Livria)

@MainActor
public final class VipleEtMoiViewModel: ObservableObject {
    @Published public var selectedTab: Int = 0
    @Published public var selectedProfileId: Int? = nil // nil = Tous les profils ; sinon ID du profil sélectionné (ex: Prénom de mon fils)
    @Published public var isShowingAuthSheet: Bool = false
    @Published public var isShowingCreateProfileSheet: Bool = false
    @Published public var isShowingSubscribeSheet: Bool = false
    @Published public var preselectedCatalogCategory: String? = nil

    @Published public var activeToastMessage: String? = nil
    @Published public var isLoading: Bool = false
    @Published public var authErrorMessage: String? = nil

    // Données synchronisées (Zéro donnée de démo)
    @Published public var isAuthenticated: Bool = false
    @Published public var account: VipleEtMoiAccountModel? = nil
    @Published public var profiles: [VipleEtMoiProfileModel] = []
    @Published public var services: [VipleEtMoiServiceModel] = []
    @Published public var contracts: [VipleContractuelItemModel] = []
    @Published public var invoices: [VipleEtMoiInvoiceModel] = []
    @Published public var livriaOrders: [VipleLivriaOrderModel] = []
    @Published public var livriaLibrary: [VipleLivriaShelfItemModel] = []
    @Published public var livriaCatalog: [VipleLivriaCatalogBookModel] = []
    @Published public var catalog: [VipleCatalogOfferModel] = []

    private let defaults = UserDefaults.standard
    private let savedEmailKey = "viple.et.moi.ios.email"

    public init() {
        let savedEmail = defaults.string(forKey: savedEmailKey)
        if let savedEmail, !savedEmail.isEmpty {
            self.isAuthenticated = true
        }
        Task {
            await refreshBootstrap(email: savedEmail)
        }
    }

    public var currentEmail: String {
        account?.email ?? defaults.string(forKey: savedEmailKey) ?? ""
    }

    public var selectedProfile: VipleEtMoiProfileModel? {
        guard let selectedProfileId else { return nil }
        return profiles.first(where: { $0.id == selectedProfileId })
    }

    // Services filtrés selon le profil sélectionné (ex: dès qu'on clique sur le prénom de son fils, on voit ses lignes et son suivi conso)
    public var filteredServices: [VipleEtMoiServiceModel] {
        guard let selectedProfileId else { return services }
        return services.filter { $0.assignedProfileId == selectedProfileId }
    }

    public var pendingContractsCount: Int {
        contracts.filter { !$0.isSigned }.count
    }

    public func showToast(_ text: String) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            activeToastMessage = text
        }
        Task {
            try? await Task.sleep(nanoseconds: 3_200_000_000)
            if activeToastMessage == text {
                withAnimation {
                    activeToastMessage = nil
                }
            }
        }
    }

    // MARK: - 1. Synchronisation

    public func refreshBootstrap(email: String? = nil) async {
        let targetEmail = email ?? defaults.string(forKey: savedEmailKey)
        do {
            let res = try await VipleEtMoiAPIClient.shared.fetchBootstrap(email: targetEmail)
            self.isAuthenticated = res.isAuthenticated
            self.account = res.account
            self.profiles = res.profiles
            self.services = res.services
            self.contracts = res.contracts
            self.invoices = res.invoices
            self.livriaOrders = res.livriaOrders
            self.livriaLibrary = res.livriaLibrary
            self.livriaCatalog = res.livriaCatalog
            self.catalog = res.catalog
        } catch {
            print("[VipleEtMoi] Erreur bootstrap: \(error.localizedDescription)")
        }
    }

    // MARK: - 2. Connexion & Inscription Viple Live ID

    public func signIn(email: String, password: String) async {
        isLoading = true
        authErrorMessage = nil
        defer { isLoading = false }
        do {
            let res: VipleEtMoiBootstrapResponse = try await VipleEtMoiAPIClient.shared.postJSON("/auth/login", body: [
                "email": email,
                "password": password
            ])
            applyBootstrap(res)
            if let acc = res.account {
                defaults.set(acc.email, forKey: savedEmailKey)
                isShowingAuthSheet = false
                showToast("Bonjour \(acc.fullName) !")
            }
        } catch {
            authErrorMessage = error.localizedDescription
        }
    }

    public func registerAccount(
        email: String,
        password: String,
        fullName: String,
        accountMode: String,
        companyName: String,
        phone: String
    ) async {
        isLoading = true
        authErrorMessage = nil
        defer { isLoading = false }
        do {
            let res: VipleEtMoiBootstrapResponse = try await VipleEtMoiAPIClient.shared.postJSON("/auth/register", body: [
                "email": email,
                "password": password,
                "fullName": fullName,
                "accountMode": accountMode,
                "companyName": companyName,
                "phone": phone
            ])
            applyBootstrap(res)
            if let acc = res.account {
                defaults.set(acc.email, forKey: savedEmailKey)
                isShowingAuthSheet = false
                showToast("Bienvenue sur Viple & Moi, \(acc.fullName) !")
            }
        } catch {
            authErrorMessage = error.localizedDescription
        }
    }

    public func signOut() {
        defaults.removeObject(forKey: savedEmailKey)
        isAuthenticated = false
        account = nil
        profiles = []
        services = []
        contracts = []
        invoices = []
        livriaOrders = []
        livriaLibrary = []
        selectedProfileId = nil
        showToast("Vous êtes déconnecté.")
        Task {
            await refreshBootstrap(email: nil)
        }
    }

    private func applyBootstrap(_ res: VipleEtMoiBootstrapResponse) {
        self.isAuthenticated = res.isAuthenticated
        self.account = res.account
        self.profiles = res.profiles
        self.services = res.services
        self.contracts = res.contracts
        self.invoices = res.invoices
        self.livriaOrders = res.livriaOrders
        self.livriaLibrary = res.livriaLibrary
        self.livriaCatalog = res.livriaCatalog
        self.catalog = res.catalog
    }

    // MARK: - 3. Gestion des Profils (Famille & Pro)

    public func createProfile(
        firstName: String,
        roleLabel: String,
        profileType: String,
        avatarEmoji: String,
        accentColor: String,
        parentalControlActive: Bool,
        outOfPlanBlocked: Bool
    ) async -> Bool {
        guard !currentEmail.isEmpty else {
            isShowingAuthSheet = true
            return false
        }
        do {
            let res = try await VipleEtMoiAPIClient.shared.postRaw("/profiles/create", body: [
                "email": currentEmail,
                "firstName": firstName,
                "roleLabel": roleLabel,
                "profileType": profileType,
                "avatarEmoji": avatarEmoji,
                "accentColor": accentColor,
                "parentalControlActive": parentalControlActive,
                "outOfPlanBlocked": outOfPlanBlocked
            ])
            showToast((res["message"] as? String) ?? "Profil \(firstName) créé !")
            await refreshBootstrap()
            if let created = profiles.last {
                selectedProfileId = created.id
            }
            return true
        } catch {
            showToast(error.localizedDescription)
            return false
        }
    }

    public func deleteProfile(profileId: Int) async {
        do {
            let res = try await VipleEtMoiAPIClient.shared.postRaw("/profiles/delete", body: [
                "email": currentEmail,
                "profileId": profileId
            ])
            if selectedProfileId == profileId {
                selectedProfileId = nil
            }
            showToast((res["message"] as? String) ?? "Profil supprimé.")
            await refreshBootstrap()
        } catch {
            showToast(error.localizedDescription)
        }
    }

    public func assignServiceToProfile(serviceId: Int, profileId: Int) async {
        do {
            let res = try await VipleEtMoiAPIClient.shared.postRaw("/profiles/assign-service", body: [
                "email": currentEmail,
                "serviceId": serviceId,
                "profileId": profileId
            ])
            showToast((res["message"] as? String) ?? "Service rattaché au profil !")
            await refreshBootstrap()
        } catch {
            showToast(error.localizedDescription)
        }
    }

    // MARK: - 4. Souscription & Gestion des Services Viple (Mobile, Box 5G, TV, SIP, Hébergement, Infogérance, Création Web)

    public func subscribeService(
        offerCode: String,
        profileId: Int,
        identifierLabel: String
    ) async -> Bool {
        guard !currentEmail.isEmpty else {
            isShowingAuthSheet = true
            return false
        }
        do {
            let res = try await VipleEtMoiAPIClient.shared.postRaw("/services/subscribe", body: [
                "email": currentEmail,
                "offerCode": offerCode,
                "profileId": profileId,
                "identifierLabel": identifierLabel
            ])
            showToast((res["message"] as? String) ?? "Service préparé ! Signez votre contrat pour l'activer.")
            await refreshBootstrap()
            return true
        } catch {
            showToast(error.localizedDescription)
            return false
        }
    }

    public func toggleServiceOption(serviceId: Int, optionCode: String) async {
        do {
            let res = try await VipleEtMoiAPIClient.shared.postRaw("/services/toggle-option", body: [
                "email": currentEmail,
                "serviceId": serviceId,
                "optionCode": optionCode
            ])
            showToast((res["message"] as? String) ?? "Option mise à jour !")
            await refreshBootstrap()
        } catch {
            showToast(error.localizedDescription)
        }
    }

    public func deleteService(serviceId: Int) async {
        do {
            let res = try await VipleEtMoiAPIClient.shared.postRaw("/services/delete", body: [
                "email": currentEmail,
                "serviceId": serviceId
            ])
            showToast((res["message"] as? String) ?? "Service retiré.")
            await refreshBootstrap()
        } catch {
            showToast(error.localizedDescription)
        }
    }

    // MARK: - 5. Signature Électronique « Viple Contractuel »

    public func signContract(contractNumber: String, signerName: String, signatureSummary: String) async -> Bool {
        do {
            let res = try await VipleEtMoiAPIClient.shared.postRaw("/contracts/sign", body: [
                "email": currentEmail,
                "contractNumber": contractNumber,
                "signerName": signerName,
                "signatureData": signatureSummary
            ])
            showToast((res["message"] as? String) ?? "Contrat signé et service activé !")
            await refreshBootstrap()
            return true
        } catch {
            showToast(error.localizedDescription)
            return false
        }
    }

    // MARK: - 6. Mise à jour du Compte & Bibliothèque Livria

    public func updateAccountInfo(
        fullName: String,
        accountMode: String,
        companyName: String,
        siret: String,
        phone: String,
        address: String,
        postalCode: String,
        city: String,
        paymentIban: String
    ) async {
        do {
            let res = try await VipleEtMoiAPIClient.shared.postRaw("/account/update", body: [
                "email": currentEmail,
                "fullName": fullName,
                "accountMode": accountMode,
                "companyName": companyName,
                "siret": siret,
                "phone": phone,
                "address": address,
                "postalCode": postalCode,
                "city": city,
                "paymentIban": paymentIban
            ])
            showToast((res["message"] as? String) ?? "Informations enregistrées !")
            await refreshBootstrap()
        } catch {
            showToast(error.localizedDescription)
        }
    }

    public func updateLivriaShelf(
        bookId: Int,
        status: String,
        progress: Double,
        rating: Int,
        format: String = "Physique"
    ) async {
        do {
            let res = try await VipleEtMoiAPIClient.shared.postRaw("/livria/library/update", body: [
                "email": currentEmail,
                "bookId": bookId,
                "status": status,
                "progress": progress,
                "rating": rating,
                "format": format
            ])
            showToast((res["message"] as? String) ?? "Bibliothèque Livria mise à jour !")
            await refreshBootstrap()
        } catch {
            showToast(error.localizedDescription)
        }
    }
}
