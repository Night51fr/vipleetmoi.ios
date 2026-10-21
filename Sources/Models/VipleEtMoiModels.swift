import Foundation

// MARK: - Modèles de Données « Viple & Moi » (Swift 6 Sendable • Espace Client Famille & Pro)

public struct VipleEtMoiBootstrapResponse: Codable, Sendable {
    public let ok: Bool
    public let isAuthenticated: Bool
    public let account: VipleEtMoiAccountModel?
    public let profiles: [VipleEtMoiProfileModel]
    public let services: [VipleEtMoiServiceModel]
    public let contracts: [VipleContractuelItemModel]
    public let invoices: [VipleEtMoiInvoiceModel]
    public let livriaOrders: [VipleLivriaOrderModel]
    public let livriaLibrary: [VipleLivriaShelfItemModel]
    public let livriaCatalog: [VipleLivriaCatalogBookModel]
    public let catalog: [VipleCatalogOfferModel]
}

public struct VipleEtMoiAccountModel: Codable, Sendable, Equatable {
    public let id: Int
    public let email: String
    public let fullName: String
    public let accountMode: String // "Famille" ou "Pro"
    public let companyName: String
    public let siret: String
    public let phone: String
    public let address: String
    public let postalCode: String
    public let city: String
    public let paymentIban: String
    public let paymentCardLabel: String
    public let avatarEmoji: String
    public let accentColor: String
}

public struct VipleEtMoiProfileModel: Codable, Identifiable, Sendable, Equatable, Hashable {
    public let id: Int
    public let accountEmail: String
    public let firstName: String
    public let roleLabel: String
    public let profileType: String // "Titulaire", "Enfant", "Famille", "Pro"
    public let avatarEmoji: String
    public let accentColor: String
    public let isPrimary: Bool
    public let parentalControlActive: Bool
    public let outOfPlanBlocked: Bool
    public let servicesCount: Int
    public let monthlyTotalTtc: Double
}

public struct VipleEtMoiServiceOptionModel: Codable, Identifiable, Sendable, Equatable, Hashable {
    public var id: String { code }
    public let code: String
    public let label: String
    public let description: String
    public let priceMonthlyTtc: Double
    public let enabled: Bool
}

public struct VipleEtMoiServiceModel: Codable, Identifiable, Sendable, Equatable, Hashable {
    public let id: Int
    public let serviceReference: String
    public let accountEmail: String
    public let assignedProfileId: Int
    public let assignedProfileName: String
    public let category: String
    public let offerCode: String
    public let title: String
    public let subtitle: String
    public let identifierLabel: String
    public let priceMonthlyTtc: Double
    public let setupFeeTtc: Double
    public let commitmentLabel: String
    public let status: String
    public let consoPrimaryLabel: String
    public let consoPrimaryUsed: Double
    public let consoPrimaryMax: Double
    public let consoPrimaryUnit: String
    public let consoSecondaryLabel: String
    public let consoSecondaryValue: String
    public let outOfPlanEur: Double
    public let outOfPlanBlocked: Bool
    public let options: [VipleEtMoiServiceOptionModel]
    public let contractNumber: String
    public let contractPublicToken: String
    public let createdAt: String
    public let nextRenewalAt: String

    public var usageProgressRatio: Double {
        guard consoPrimaryMax > 0 else { return 0 }
        return min(1.0, max(0.0, consoPrimaryUsed / consoPrimaryMax))
    }

    public var isPendingSignature: Bool {
        status.localizedCaseInsensitiveContains("attente") || status.localizedCaseInsensitiveContains("pending")
    }
}

public struct VipleContractuelItemModel: Codable, Identifiable, Sendable, Equatable, Hashable {
    public let id: Int
    public let contractNumber: String
    public let publicToken: String
    public let title: String
    public let category: String
    public let description: String
    public let contentHtml: String
    public let status: String
    public let createdAt: String
    public let signedAt: String

    public var isSigned: Bool {
        status.localizedCaseInsensitiveContains("Signed") || status.localizedCaseInsensitiveContains("Signé")
    }
}

public struct VipleEtMoiInvoiceModel: Codable, Identifiable, Sendable, Equatable {
    public let id: Int
    public let invoiceNumber: String
    public let contractNumber: String
    public let periodLabel: String
    public let issuedAt: String
    public let amountTtc: Double
    public let status: String
}

public struct VipleCatalogOfferModel: Codable, Identifiable, Sendable, Equatable, Hashable {
    public var id: String { offerCode }
    public let offerCode: String
    public let category: String
    public let categoryLabel: String
    public let iconName: String
    public let accentHex: String
    public let title: String
    public let subtitle: String
    public let priceMonthlyTtc: Double
    public let setupFeeTtc: Double
    public let commitmentLabel: String
    public let consoPrimaryLabel: String
    public let consoPrimaryMax: Double
    public let consoPrimaryUnit: String
    public let consoSecondaryLabel: String
    public let consoSecondaryValue: String
    public let highlights: [String]
}

// MARK: - Modèles Livria synchronisés (Achats & Ma Bibliothèque)

public struct VipleLivriaOrderItemModel: Codable, Identifiable, Sendable, Equatable {
    public let id: Int
    public let bookId: Int
    public let title: String
    public let author: String
    public let coverUrl: String
    public let quantity: Int
    public let unitPrice: Double
    public let format: String
}

public struct VipleLivriaOrderModel: Codable, Identifiable, Sendable, Equatable {
    public let id: Int
    public let reference: String
    public let createdAt: String
    public let total: Double
    public let status: String
    public let carrier: String
    public let trackingNumber: String?
    public let deliveryUrl: String
    public let shippingAddress: String
    public let items: [VipleLivriaOrderItemModel]
}

public struct VipleLivriaShelfItemModel: Codable, Identifiable, Sendable, Equatable, Hashable {
    public let id: Int
    public let bookId: Int
    public let title: String
    public let author: String
    public let genre: String
    public let coverUrl: String
    public let status: String // "Reading", "Read", "WantToRead"
    public let rating: Int
    public let progress: Double
    public let format: String
    public let addedAt: String
    public let finishedAt: String

    public var frenchStatusLabel: String {
        switch status {
        case "Reading": return "📖 En cours de lecture"
        case "Read": return "✅ Terminé"
        default: return "🔖 À lire"
        }
    }
}

public struct VipleLivriaCatalogBookModel: Codable, Identifiable, Sendable, Equatable {
    public let id: Int
    public let title: String
    public let author: String
    public let genre: String
    public let coverUrl: String
    public let price: Double
}
