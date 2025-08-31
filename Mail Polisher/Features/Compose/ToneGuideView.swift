import SwiftUI

// MARK: - ToneGuideView
struct ToneGuideView: View {
    let selectedTone: Tone
    @Environment(\.colorScheme) private var scheme
    @State private var animateCards: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                toneCards
            }
            .padding(24)
        }
        .scrollIndicators(.hidden)
        .background(backgroundGradient)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateCards = true
            }
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        Color.clear
            .background(.ultraThinMaterial)
            .ignoresSafeArea()
    }
    
    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.25), .white.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .blur(radius: 6)
                    
                    Image(systemName: "textformat.alt")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.blue)
                        .shadow(color: .blue.opacity(0.5), radius: 8, x: 0, y: 0)
                }
                .scaleEffect(animateCards ? 1.0 : 0.8)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: animateCards)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tone Guide")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text("Choose the perfect tone for your message")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.secondary.opacity(0.9))
                }
                Spacer()
            }
            
            if !selectedTone.rawValue.isEmpty {
                HStack(spacing: 8) {
                    Text("Current:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    Text(selectedTone.rawValue)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                colors: toneGradientColors(for: selectedTone),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: Capsule()
                        )
                        .overlay(
                            Capsule().strokeBorder(.white.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.top, 4)
            }
        }
    }
    
    // MARK: - Tone Cards
    private var toneCards: some View {
        LazyVStack(spacing: 16) {
            ForEach(Array(Tone.allCases.enumerated()), id: \.element) { index, tone in
                ToneCard(
                    tone: tone,
                    isSelected: tone == selectedTone,
                    animationDelay: Double(index) * 0.1
                )
                .scaleEffect(animateCards ? 1.0 : 0.95)
                .opacity(animateCards ? 1.0 : 0)
                .offset(y: animateCards ? 0 : 20)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.08), value: animateCards)
            }
        }
    }
    
    // MARK: - Helpers
    private func toneGradientColors(for tone: Tone) -> [Color] {
        switch tone {
        case .formal:     return [.purple, .blue]
        case .friendly:   return [.orange, .yellow]
        case .direct:     return [.red, .pink]
        case .apologetic: return [.green, .mint]
        }
    }
}

// MARK: - ToneCard
struct ToneCard: View {
    let tone: Tone
    let isSelected: Bool
    let animationDelay: Double
    
    @Environment(\.colorScheme) private var scheme
    @State private var isPressed: Bool = false
    @State private var showDetails: Bool = false
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { showDetails.toggle() }
        } label: { cardContent }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isPressed)
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) { isPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) { isPressed = false }
            }
        }
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: toneGradientColors + [Color.white.opacity(0.1)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 48, height: 48)
                    Image(systemName: toneIcon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.white)
                        .shadow(radius: 4)
                }
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(tone.rawValue)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.primary)
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(.green)
                                .scaleEffect(1.2)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                        }
                        Image(systemName: showDetails ? "chevron.up.circle.fill" : "chevron.down.circle")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(showDetails ? 0 : 180))
                            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showDetails)
                    }
                    Text(tone.helpText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(showDetails ? nil : 2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            if showDetails {
                VStack(alignment: .leading, spacing: 12) {
                    Divider().background(.secondary.opacity(0.3))
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Best for:")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.primary)
                        ForEach(usageScenarios, id: \.self) { scenario in
                            HStack(alignment: .top, spacing: 8) {
                                Circle().fill(.secondary.opacity(0.6)).frame(width: 4, height: 4).padding(.top, 6)
                                Text(scenario)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.secondary.opacity(0.9))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    if let example = toneExample {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Example:")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.primary)
                            Text(example)
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .padding(12)
                                .background(.ultraThinMaterial.opacity(0.5),
                                            in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .strokeBorder(.secondary.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .top).combined(with: .opacity),
                                        removal: .move(edge: .top).combined(with: .opacity)))
            }
        }
        .padding(20)
        .background(cardBackground)
        .overlay(cardBorder)
        .shadow(color: .black.opacity(scheme == .dark ? 0.3 : 0.15),
                radius: isSelected ? 20 : 12, x: 0, y: isSelected ? 8 : 4)
    }
    
    // MARK: - Styles
    private var cardBackground: some View {
        ZStack {
            Color.clear.background(.ultraThinMaterial.opacity(0.8))
            if isSelected {
                LinearGradient(colors: toneGradientColors.map { $0.opacity(0.08) },
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            }
            LinearGradient(colors: [.white.opacity(0.1), .white.opacity(0.03), .clear],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .strokeBorder(
                LinearGradient(
                    colors: isSelected ? [.white.opacity(0.4), .white.opacity(0.2)]
                                       : [.white.opacity(0.25), .white.opacity(0.1)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ),
                lineWidth: isSelected ? 1.5 : 1
            )
    }
    
    // MARK: - Computed
    private var toneGradientColors: [Color] {
        switch tone {
        case .formal:     return [.purple, .blue]
        case .friendly:   return [.orange, .yellow]
        case .direct:     return [.red, .pink]
        case .apologetic: return [.green, .mint]
        }
    }
    
    private var toneIcon: String {
        switch tone {
        case .formal:     return "building.columns.fill"
        case .friendly:   return "heart.fill"
        case .direct:     return "exclamationmark.triangle.fill"
        case .apologetic: return "hand.raised.fill"
        }
    }
    
    private var usageScenarios: [String] {
        switch tone {
        case .formal:
            return ["Official announcements", "Legal communications", "Academic correspondence", "Executive communications"]
        case .friendly:
            return ["Welcome messages", "Thank you notes", "Team communications", "Celebration announcements"]
        case .direct:
            return ["Deadline reminders", "Important requests", "Clear instructions", "Urgent notifications"]
        case .apologetic:
            return ["Mistake acknowledgments", "Delay notifications", "Service issues", "Sincere apologies"]
        }
    }
    
    private var toneExample: String? {
        switch tone {
        case .formal:
            return "Dear Team, Please find attached the requested documentation..."
        case .friendly:
            return "Hi there! I hope this message finds you well..."
        case .direct:
            return "Please confirm by Friday so we can meet the deadline..."
        case .apologetic:
            return "I sincerely apologize for the inconvenience and take full responsibility..."
        }
    }
}
