import SwiftUI

// MARK: - Onglet 3 : Viple Contractuel (Consultation des Contrats & Signature Électronique au Doigt)

public struct ContractsView: View {
    @EnvironmentObject private var appModel: VipleEtMoiViewModel
    @State private var contractToSign: VipleContractuelItemModel? = nil

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                VipleAnimatedBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        contractuelHeaderBanner

                        if appModel.contracts.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 42))
                                    .foregroundStyle(VipleEtMoiPalette.primary)
                                Text("Aucun contrat enregistré")
                                    .font(.system(size: 16, weight: .black, design: .rounded))
                                    .foregroundStyle(.white)
                                Text("Dès que vous souscrivez à un forfait mobile, une Box 5G ou un contrat Agence IT Viple, votre contrat officiel apparaît ici pour lecture et signature électronique.")
                                    .font(.system(size: 12.5))
                                    .foregroundStyle(VipleEtMoiPalette.textMuted)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(24)
                            .frame(maxWidth: .infinity)
                            .vipleGlassCard()
                        } else {
                            ForEach(appModel.contracts) { contract in
                                ContractItemCard(contract: contract) {
                                    contractToSign = contract
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
            .navigationTitle("Viple Contractuel")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await appModel.refreshBootstrap()
            }
            .sheet(item: $contractToSign) { contract in
                SignContractModalView(contract: contract)
                    .environmentObject(appModel)
            }
        }
    }

    private var contractuelHeaderBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("VIPLE CONTRACTUEL OFFICIEL", systemImage: "checkmark.seal.text.page.fill")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(VipleEtMoiPalette.amber)
                Spacer()
                Text("\(appModel.contracts.count) document(s)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.85))
            }

            Text("Signez et consultez tous vos contrats Viple en toute simplicité")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text("Chaque contrat est horodaté et certifié par Viple SAS. Signez directement au doigt sur votre écran pour activer immédiatement votre ligne ou votre prestation IT.")
                .font(.system(size: 12))
                .foregroundStyle(VipleEtMoiPalette.textMuted)
        }
        .padding(16)
        .vipleGlassCard()
    }
}

private struct ContractItemCard: View {
    let contract: VipleContractuelItemModel
    let onOpenSign: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(contract.contractNumber)
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundStyle(VipleEtMoiPalette.cyan)

                Spacer()

                Text(contract.isSigned ? "✅ Signé & Actif" : "✍️ À signer")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(contract.isSigned ? VipleEtMoiPalette.emerald : VipleEtMoiPalette.amber)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill((contract.isSigned ? VipleEtMoiPalette.emerald : VipleEtMoiPalette.amber).opacity(0.18))
                    )
            }

            Text(contract.title)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text(contract.description)
                .font(.system(size: 12.5))
                .foregroundStyle(VipleEtMoiPalette.textMuted)

            HStack {
                Text("Émis le \(contract.createdAt)")
                    .font(.system(size: 11))
                    .foregroundStyle(VipleEtMoiPalette.textMuted)

                if !contract.signedAt.isEmpty {
                    Text("• Signé le \(contract.signedAt)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(VipleEtMoiPalette.emerald)
                }

                Spacer()

                if !contract.isSigned {
                    Button(action: onOpenSign) {
                        Label("Lire & Signer", systemImage: "signature")
                            .font(.system(size: 12.5, weight: .black))
                            .foregroundStyle(VipleEtMoiPalette.ink)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(VipleEtMoiPalette.amber))
                    }
                } else if let url = URL(string: "https://contractuel.viplenetwork.com/c/\(contract.publicToken)") {
                    Link(destination: url) {
                        Label("Certificat", systemImage: "arrow.up.right.square")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(VipleEtMoiPalette.cyan)
                    }
                }
            }
        }
        .padding(16)
        .vipleGlassCard()
    }
}

// MARK: - Modale de Lecture & Signature Électronique au Doigt

private struct SignContractModalView: View {
    @EnvironmentObject private var appModel: VipleEtMoiViewModel
    @Environment(\.dismiss) private var dismiss
    let contract: VipleContractuelItemModel

    @State private var signerFullName: String = ""
    @State private var drawnPoints: [[CGPoint]] = []
    @State private var currentLine: [CGPoint] = []
    @State private var acceptedTerms: Bool = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(contract.title)
                            .font(.system(size: 18, weight: .black, design: .rounded))
                        Text("Référence : \(contract.contractNumber) • Catégorie : \(contract.category)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.secondary)
                        Divider()
                        Text(contract.description)
                            .font(.system(size: 13))
                        Text("Conditions Viple : Aucun frais caché. Activation immédiate du service et du suivi conso dès validation de votre signature électronique.")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.secondary.opacity(0.12)))

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Nom et prénom du signataire")
                            .font(.system(size: 12, weight: .bold))
                        TextField("Ex: Chris", text: $signerFullName)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Zone de signature tactile au doigt
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Dessinez votre signature au doigt ci-dessous :")
                                .font(.system(size: 12, weight: .bold))
                            Spacer()
                            Button("Effacer") {
                                drawnPoints.removeAll()
                                currentLine.removeAll()
                            }
                            .font(.system(size: 12, weight: .bold))
                        }

                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .frame(height: 170)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(VipleEtMoiPalette.primary, lineWidth: 2)
                                )

                            if drawnPoints.isEmpty && currentLine.isEmpty {
                                Text("Signez ici avec votre doigt ✍️")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.gray.opacity(0.6))
                            }

                            Canvas { context, _ in
                                for line in drawnPoints + [currentLine] {
                                    guard let first = line.first else { continue }
                                    var path = Path()
                                    path.move(to: first)
                                    for pt in line.dropFirst() {
                                        path.addLine(to: pt)
                                    }
                                    context.stroke(path, with: .color(.black), lineWidth: 3.0)
                                }
                            }
                            .frame(height: 170)
                            .gesture(
                                DragGesture(minimumDistance: 0.1)
                                    .onChanged { value in
                                        currentLine.append(value.location)
                                    }
                                    .onEnded { _ in
                                        drawnPoints.append(currentLine)
                                        currentLine.removeAll()
                                    }
                            )
                        }
                    }

                    Toggle("Je confirme avoir lu et accepté ce contrat Viple.", isOn: $acceptedTerms)
                        .font(.system(size: 12.5, weight: .semibold))

                    Button {
                        Task {
                            let strokeCount = drawnPoints.reduce(0) { $0 + $1.count }
                            let ok = await appModel.signContract(
                                contractNumber: contract.contractNumber,
                                signerName: signerFullName.isEmpty ? (appModel.account?.fullName ?? "Titulaire Viple") : signerFullName,
                                signatureSummary: "NativeFingerSignature(points:\(strokeCount))"
                            )
                            if ok { dismiss() }
                        }
                    } label: {
                        Label("Valider ma signature & Activer le service", systemImage: "checkmark.seal.fill")
                            .font(.system(size: 15, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Capsule().fill(VipleEtMoiPalette.emeraldGradient))
                    }
                    .disabled(!acceptedTerms)
                }
                .padding(16)
            }
            .navigationTitle("Signer le contrat")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                signerFullName = appModel.account?.fullName ?? ""
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }
}
