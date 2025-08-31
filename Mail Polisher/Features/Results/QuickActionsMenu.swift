import SwiftUI

struct QuickActionsMenu: View {
    // External state
    let lastMessageText: String?
    let isBusy: Bool

    // Actions injected from parent
    let onShorter: () -> Void
    let onFormal: () -> Void
    let onWarmer: () -> Void
    let onUrgent: () -> Void
    let onAltTime: (() -> Void)?
    let onAddDetails: (() -> Void)?

    // Local UI state
    @State private var isExpanded = false
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            if isExpanded { actions.transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top))) }
        }
        .background(backgroundMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(.white.opacity(0.2), lineWidth: 1.5)
        )
        .shadow(color: scheme == .dark ? .black.opacity(0.5) : .black.opacity(0.2),
                radius: isExpanded ? 16 : 8, x: 0, y: isExpanded ? 8 : 4)
        .scaleEffect(isBusy ? 0.98 : 1.0)
        .opacity(isBusy ? 0.75 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isExpanded)
        .animation(.easeInOut(duration: 0.25), value: isBusy)
    }

    // MARK: - Views
    private var header: some View {
        HStack(spacing: 12) {
            Button(action: toggle) {
                ZStack {
                    Circle()
                        .fill(isExpanded ? Color.blue.opacity(0.15) : Color.clear)
                        .frame(width: 42, height: 42)
                        .overlay(Circle().strokeBorder(isExpanded ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1))
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "wand.and.stars.inverse")
                        .font(.system(size: isExpanded ? 24 : 22, weight: .medium))
                        .foregroundStyle(isExpanded ? .blue : .secondary)
                        .scaleEffect(isExpanded ? 1.1 : 1.0)
                }
            }
            .buttonStyle(ScaleButtonStyle())
            .disabled(isBusy)
            .accessibilityLabel(isExpanded ? "Close quick actions" : "Open quick actions")

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text("Quick Actions")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                    if !isExpanded {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12))
                            .foregroundStyle(.yellow)
                            .opacity(0.8)
                    }
                }
                if !isExpanded {
                    Text("Enhance your message")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary.opacity(0.8))
                        .transition(.opacity)
                }
            }
            Spacer(minLength: 0)
            if isExpanded {
                HStack(spacing: 6) {
                    Circle().fill(.green).frame(width: 8, height: 8)
                    Text("Ready")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .transition(.opacity)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }

    private var actions: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                ActionPill(title: "Shorter", icon: "scissors", tint: .blue, disabled: isBusy, action: onShorter)
                ActionPill(title: "Formal", icon: "briefcase.fill", tint: .indigo, disabled: isBusy, action: onFormal)
            }
            HStack(spacing: 10) {
                ActionPill(title: "Warmer", icon: "heart.fill", tint: .pink, disabled: isBusy, action: onWarmer)
                ActionPill(title: "Urgent", icon: "bolt.fill", tint: .orange, disabled: isBusy, action: onUrgent)
            }
            if showsAltTime || showsAddDetails {
                HStack(spacing: 10) {
                    if showsAltTime {
                        ActionPill(title: "Alt Time", icon: "calendar.badge.clock", tint: .green, disabled: isBusy) { onAltTime?() }
                    }
                    if showsAddDetails {
                        ActionPill(title: "Add Details", icon: "plus.circle.fill", tint: .teal, disabled: isBusy) { onAddDetails?() }
                    }
                    if !(showsAltTime && showsAddDetails) { Spacer() }
                }
            }
            if !suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "lightbulb.fill").font(.system(size: 12)).foregroundStyle(.yellow)
                        Text("Smart Tips")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.top, 4)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(suggestions, id: \.self) { s in
                                Text(s)
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background((scheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2)),
                                                in: Capsule())
                                    .overlay(Capsule().strokeBorder(Color.gray.opacity(0.3), lineWidth: 0.5))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 16)
    }

    // MARK: - Logic
    private var backgroundMaterial: Material { scheme == .dark ? .regularMaterial : .thickMaterial }

    private var showsAltTime: Bool {
        guard let t = lastMessageText?.lowercased() else { return false }
        return t.contains("meeting") || t.contains("schedule") || t.contains("appointment") || t.contains("call")
    }

    private var showsAddDetails: Bool { (lastMessageText?.count ?? 0) < 280 }

    private var suggestions: [String] {
        var out: [String] = []
        if let text = lastMessageText {
            let low = text.lowercased()
            if text.count > 200 { out.append("Too long") }
            if !low.contains("please") && !low.contains("thank") { out.append("Add politeness") }
            if low.contains("asap") || low.contains("urgent") { out.append("Set deadline") }
            if !low.contains("best") && !low.contains("regards") { out.append("Add closing") }
        }
        return out.isEmpty ? ["Improve tone", "Check clarity"] : out
    }

    private func toggle() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { isExpanded.toggle() }
    }
}

// MARK: - Pill
struct ActionPill: View {
    let title: String
    let icon: String
    let tint: Color
    let disabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 14, weight: .semibold))
                Text(title).font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(tint.opacity(0.3), lineWidth: 1))
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.96))
        .foregroundStyle(.primary)
        .disabled(disabled)
        .opacity(disabled ? 0.6 : 1.0)
    }
}

// MARK: - Shared Button Style
struct ScaleButtonStyle: ButtonStyle {
    let scale: Double
    init(scale: Double = 0.95) { self.scale = scale }
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
