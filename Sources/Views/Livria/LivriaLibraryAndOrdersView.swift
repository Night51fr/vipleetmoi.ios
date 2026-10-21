import SwiftUI

// MARK: - Onglet 4 : Ma Bibliothèque Livria & Mes Achats (Synchronisés en direct avec Livria Store)

public struct LivriaLibraryAndOrdersView: View {
    @EnvironmentObject private var appModel: VipleEtMoiViewModel
    @State private var selectedSection: Int = 0 // 0 = Ma Bibliothèque, 1 = Mes Commandes & Suivi UPS
    @State private var isShowingAddBookSheet: Bool = false

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                VipleAnimatedBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        livriaHeroBanner

                        Picker("Rubrique Livria", selection: $selectedSection) {
                            Text("📚 Ma Bibliothèque (\(appModel.livriaLibrary.count))").tag(0)
                            Text("📦 Mes Achats (\(appModel.livriaOrders.count))").tag(1)
                        }
                        .pickerStyle(.segmented)

                        if selectedSection == 0 {
                            myLibrarySection
                        } else {
                            myOrdersSection
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
            .navigationTitle("Ma Bibliothèque Livria")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddBookSheet = true
                    } label: {
                        Text("\(Image(systemName: "plus.circle.fill")) Livre")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                    }
                    .tint(VipleEtMoiPalette.amber)
                }
            }
            .refreshable {
                await appModel.refreshBootstrap()
            }
            .sheet(isPresented: $isShowingAddBookSheet) {
                AddBookToLivriaShelfSheet()
                    .environmentObject(appModel)
            }
        }
    }

    private var livriaHeroBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("UNIVERS LIVRIA SYNCHRONISÉ", systemImage: "books.vertical.fill")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(VipleEtMoiPalette.amber)
                Spacer()
                Link(destination: URL(string: "https://livria.store")!) {
                    Text("Ouvrir livria.store →")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundStyle(VipleEtMoiPalette.cyan)
                }
            }

            Text("Retrouvez tous vos livres et commandes Livria")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text("Suivez votre avancement de lecture page par page, notez vos ouvrages et consultez l'expédition UPS de vos commandes Livria Store.")
                .font(.system(size: 12))
                .foregroundStyle(VipleEtMoiPalette.textMuted)
        }
        .padding(16)
        .vipleGlassCard()
    }

    // MARK: - Section Ma Bibliothèque

    private var myLibrarySection: some View {
        VStack(spacing: 12) {
            if appModel.livriaLibrary.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "book.closed.circle.fill")
                        .font(.system(size: 42))
                        .foregroundStyle(VipleEtMoiPalette.amber)
                    Text("Votre bibliothèque Livria est vide")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Ajoutez les livres que vous lisez actuellement ou que vous avez achetés sur Livria Store pour suivre votre progression.")
                        .font(.system(size: 12.5))
                        .foregroundStyle(VipleEtMoiPalette.textMuted)
                        .multilineTextAlignment(.center)

                    Button {
                        isShowingAddBookSheet = true
                    } label: {
                        Label("Ajouter un livre à ma bibliothèque", systemImage: "plus.circle.fill")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(VipleEtMoiPalette.ink)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(VipleEtMoiPalette.amber))
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .vipleGlassCard()
            } else {
                ForEach(appModel.livriaLibrary) { item in
                    LibraryBookCard(item: item)
                }
            }
        }
    }

    // MARK: - Section Mes Achats & Commandes UPS

    private var myOrdersSection: some View {
        VStack(spacing: 12) {
            if appModel.livriaOrders.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "shippingbox.circle.fill")
                        .font(.system(size: 42))
                        .foregroundStyle(VipleEtMoiPalette.cyan)
                    Text("Aucune commande passée pour le moment")
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Vos achats effectués sur l'application Livria Store ou sur livria.store s'affichent automatiquement ici avec leur suivi de livraison UPS.")
                        .font(.system(size: 12.5))
                        .foregroundStyle(VipleEtMoiPalette.textMuted)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .vipleGlassCard()
            } else {
                ForEach(appModel.livriaOrders) { order in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Commande \(order.reference)")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                            Spacer()
                            Text(String(format: "%.2f €", order.total))
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundStyle(VipleEtMoiPalette.emerald)
                        }

                        Text("Passée le \(order.createdAt) • Statut : \(order.status)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(VipleEtMoiPalette.textMuted)

                        ForEach(order.items) { line in
                            HStack {
                                Text("• \(line.quantity)x \(line.title)")
                                    .font(.system(size: 12.5, weight: .bold))
                                    .foregroundStyle(.white)
                                Spacer()
                                Text(line.format)
                                    .font(.system(size: 11))
                                    .foregroundStyle(VipleEtMoiPalette.textMuted)
                            }
                        }

                        if let tracking = order.trackingNumber, !tracking.isEmpty {
                            HStack {
                                Label("Suivi \(order.carrier) : \(tracking)", systemImage: "truck.box.fill")
                                    .font(.system(size: 11.5, weight: .bold))
                                    .foregroundStyle(VipleEtMoiPalette.cyan)
                                Spacer()
                                if let url = URL(string: order.deliveryUrl) {
                                    Link("Suivre le colis →", destination: url)
                                        .font(.system(size: 11.5, weight: .black))
                                        .foregroundStyle(VipleEtMoiPalette.amber)
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(16)
                    .vipleGlassCard()
                }
            }
        }
    }
}

private struct LibraryBookCard: View {
    @EnvironmentObject private var appModel: VipleEtMoiViewModel
    let item: VipleLivriaShelfItemModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: URL(string: item.coverUrl)) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(VipleEtMoiPalette.heroGradient)
                            .overlay(
                                Image(systemName: "book.closed.fill")
                                    .foregroundStyle(.white)
                            )
                    }
                }
                .frame(width: 64, height: 94)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.frenchStatusLabel)
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(VipleEtMoiPalette.amber)

                    Text(item.title)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text("\(item.author) • Format \(item.format)")
                        .font(.system(size: 12))
                        .foregroundStyle(VipleEtMoiPalette.textMuted)

                    // Barre de progression de lecture
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Avancement de lecture")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(VipleEtMoiPalette.textMuted)
                            Spacer()
                            Text("\(Int(item.progress)) %")
                                .font(.system(size: 11, weight: .black))
                                .foregroundStyle(VipleEtMoiPalette.cyan)
                        }
                        ProgressView(value: item.progress, total: 100)
                            .tint(VipleEtMoiPalette.cyan)
                    }
                    .padding(.top, 4)
                }
            }

            HStack(spacing: 8) {
                Button {
                    let nextProgress = min(100, item.progress + 25)
                    let nextStatus = nextProgress >= 100 ? "Read" : "Reading"
                    Task {
                        await appModel.updateLivriaShelf(
                            bookId: item.bookId,
                            status: nextStatus,
                            progress: nextProgress,
                            rating: item.rating,
                            format: item.format
                        )
                    }
                } label: {
                    Label("+25 % lu", systemImage: "book.pages.fill")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(VipleEtMoiPalette.cyan.opacity(0.25)))
                }

                Button {
                    Task {
                        await appModel.updateLivriaShelf(
                            bookId: item.bookId,
                            status: "Read",
                            progress: 100,
                            rating: 5,
                            format: item.format
                        )
                    }
                } label: {
                    Label("Marquer terminé", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(VipleEtMoiPalette.emerald.opacity(0.25)))
                }

                Spacer()
            }
        }
        .padding(15)
        .vipleGlassCard()
    }
}

private struct AddBookToLivriaShelfSheet: View {
    @EnvironmentObject private var appModel: VipleEtMoiViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedBookId: Int = 0
    @State private var selectedStatus: String = "Reading"
    @State private var selectedFormat: String = "Physique"
    @State private var progress: Double = 20

    var body: some View {
        NavigationStack {
            Form {
                Section("Choisir un livre du catalogue Livria") {
                    Picker("Livre", selection: $selectedBookId) {
                        Text("Sélectionner un livre...").tag(0)
                        ForEach(appModel.livriaCatalog) { book in
                            Text("\(book.title) — \(book.author)").tag(book.id)
                        }
                    }
                }

                Section("Statut & Format") {
                    Picker("Statut", selection: $selectedStatus) {
                        Text("📖 En cours de lecture").tag("Reading")
                        Text("🔖 À lire").tag("WantToRead")
                        Text("✅ Terminé").tag("Read")
                    }
                    Picker("Format", selection: $selectedFormat) {
                        Text("Livre papier").tag("Physique")
                        Text("E-Book Numérique").tag("Numérique")
                        Text("Livre Audio").tag("Audio")
                    }
                    VStack(alignment: .leading) {
                        Text("Progression : \(Int(progress)) %")
                        Slider(value: $progress, in: 0...100, step: 5)
                    }
                }
            }
            .navigationTitle("Ajouter à Ma Bibliothèque")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") {
                        guard selectedBookId > 0 else { return }
                        Task {
                            await appModel.updateLivriaShelf(
                                bookId: selectedBookId,
                                status: selectedStatus,
                                progress: selectedStatus == "Read" ? 100 : progress,
                                rating: 5,
                                format: selectedFormat
                            )
                            dismiss()
                        }
                    }
                    .disabled(selectedBookId == 0)
                }
            }
        }
    }
}
