import SwiftUI

// Simple chat message model (for UI)
struct ChatMessage: Identifiable, Equatable {
    enum Role { case user, assistant }
    let id = UUID()
    let role: Role
    let text: String
    let time: Date = .init()
}

struct ResultsView: View {
    @EnvironmentObject var router: Router
    @StateObject var vm: ResultsViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme

    @State private var showQuickActions = false
    @State private var cardAnimationOffset: CGFloat = 50
    @State private var cardAnimationOpacity: Double = 0
    @State private var headerScale: CGFloat = 0.8
    @State private var pulseAnimation = false
    @State private var sparkleRotation: Double = 0

    var body: some View {
        ZStack {
            backgroundGradient
            VStack(spacing: 0) {
                enhancedTopBar
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(vm.messages) { msg in
                                enhancedMessageBubble(for: msg)
                                    .id(msg.id)
                                    .scaleEffect(cardAnimationOffset == 0 ? 1 : 0.95)
                                    .opacity(cardAnimationOpacity)
                                    .offset(y: cardAnimationOffset)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(vm.messages.firstIndex(where: { $0.id == msg.id }) ?? 0) * 0.1), value: cardAnimationOffset)
                            }
                        }
                        .padding(.vertical, 24)
                        .padding(.horizontal, 20)
                    }
                    .scrollIndicators(.hidden)
                    .onChange(of: vm.messages.count) { _ in
                        if let lastID = vm.messages.last?.id {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                proxy.scrollTo(lastID, anchor: .bottom)
                            }
                        }
                    }
                }
                compactBottomSection
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupInitialAnimation()
            startAnimations()
        }
        .onDisappear { router.reset() }
        .alert("Error", isPresented: .constant(vm.error != nil)) {
            Button("OK") { vm.error = nil }
        } message: { Text(vm.error ?? "") }
    }

    // MARK: - Vibrant Animated Background
    private var backgroundGradient: some View {
        ZStack {
            // Dynamic multi-layer gradient matching ComposeView
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color.purple.opacity(0.05),
                    Color.blue.opacity(0.08),
                    Color.cyan.opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated floating orbs
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.purple.opacity(0.08), Color.clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 120
                        )
                    )
                    .frame(width: 220, height: 220)
                    .offset(x: pulseAnimation ? 40 : -40, y: pulseAnimation ? -30 : 30)
                    .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: pulseAnimation)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.blue.opacity(0.06), Color.clear],
                            center: .center,
                            startRadius: 15,
                            endRadius: 100
                        )
                    )
                    .frame(width: 180, height: 180)
                    .offset(x: pulseAnimation ? -30 : 30, y: pulseAnimation ? 50 : -50)
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: pulseAnimation)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.cyan.opacity(0.04), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 90
                        )
                    )
                    .frame(width: 160, height: 160)
                    .offset(x: pulseAnimation ? 25 : -25, y: pulseAnimation ? -40 : 40)
                    .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: pulseAnimation)
            }
            
            // Shimmer overlay
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.02),
                            Color.clear,
                            Color.white.opacity(0.01)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blendMode(.overlay)
        }
        .ignoresSafeArea()
    }

    // MARK: - Enhanced Top Bar
    private var enhancedTopBar: some View {
        HStack(alignment: .center, spacing: 16) {
            Button { dismiss() } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(.systemBackground).opacity(0.9),
                                    Color(.systemBackground).opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.purple, Color.blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .shadow(
                color: Color.purple.opacity(0.2),
                radius: 8,
                x: 0,
                y: 4
            )

            Spacer()

            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.purple.opacity(0.15),
                                    Color.blue.opacity(0.12),
                                    Color.cyan.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.3), Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.purple, Color.blue, Color.cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .rotationEffect(.degrees(sparkleRotation))
                        .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulseAnimation)
                        .animation(.linear(duration: 4).repeatForever(autoreverses: false), value: sparkleRotation)
                }
                .scaleEffect(headerScale)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: headerScale)

                VStack(spacing: 2) {
                    Text("Polished Results")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.primary, Color.purple.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Text("AI-Enhanced Email")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Enhanced Message Bubble
    @ViewBuilder
    private func enhancedMessageBubble(for msg: ChatMessage) -> some View {
        HStack {
            if msg.role == .assistant { Spacer(minLength: 32) }
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    if msg.role == .assistant {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.green.opacity(0.15), Color.mint.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [Color.green.opacity(0.3), Color.mint.opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.green, Color.mint],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulseAnimation)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Polished Result")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.primary, Color.green.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            Text("AI Enhanced")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary.opacity(0.8))
                        }
                        Spacer()
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.15), Color.indigo.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 28, height: 28)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [Color.blue.opacity(0.3), Color.indigo.opacity(0.2)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.blue, Color.indigo],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        Text("Your Request")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.primary, Color.blue.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                }

                Text(msg.text)
                    .textSelection(.enabled)
                    .font(.system(size: 16, weight: .regular))
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(
                        ZStack {
                            if msg.role == .assistant {
                                // Assistant bubble - glassmorphic with green tint
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color(.systemBackground).opacity(0.95))
                                
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.green.opacity(0.04),
                                                Color.mint.opacity(0.03),
                                                Color.clear
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            } else {
                                // User bubble - vibrant gradient
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.blue.opacity(0.8),
                                                Color.indigo.opacity(0.7),
                                                Color.purple.opacity(0.6)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(
                                msg.role == .assistant
                                ? LinearGradient(
                                    colors: [
                                        Color.green.opacity(0.2),
                                        Color.mint.opacity(0.15),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.4),
                                        Color.white.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .foregroundColor(msg.role == .assistant ? .primary : .white)

                if msg.role == .assistant {
                    HStack(spacing: 12) {
                        Button {
                            UIPasteboard.general.string = msg.text
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "doc.on.doc.fill")
                                    .font(.system(size: 14, weight: .medium))
                                Text("Copy")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.15), Color.cyan.opacity(0.1)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: Capsule()
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [Color.blue.opacity(0.3), Color.cyan.opacity(0.2)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.blue, Color.cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        }
                        .buttonStyle(.plain)

                        ShareLink(item: msg.text) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 14, weight: .medium))
                                Text("Share")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.15), Color.pink.opacity(0.1)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: Capsule()
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [Color.purple.opacity(0.3), Color.pink.opacity(0.2)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.purple, Color.pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                }
            }
            if msg.role == .user { Spacer(minLength: 32) }
        }
        .shadow(
            color: msg.role == .assistant
            ? Color.green.opacity(scheme == .dark ? 0.2 : 0.1)
            : Color.blue.opacity(scheme == .dark ? 0.3 : 0.15),
            radius: 12,
            x: 0,
            y: 6
        )
        .transition(.move(edge: msg.role == .assistant ? .leading : .trailing).combined(with: .opacity))
    }

    // MARK: - Enhanced Bottom Section
    private var compactBottomSection: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                QuickActionsMenu(
                    lastMessageText: vm.messages.last?.text,
                    isBusy: vm.isRefining,
                    onShorter: {
                        Task {
                            await vm.applyRefine(
                                instruction: "Shorten the text by 20%. Keep the content the same, remove filler.",
                                showUserBubble: true
                            )
                        }
                    },
                    onFormal: {
                        Task {
                            await vm.applyRefine(
                                instruction: "Write more formally in a business tone. Use standard salutation and closing.",
                                showUserBubble: true
                            )
                        }
                    },
                    onWarmer: {
                        Task {
                            await vm.applyRefine(
                                instruction: "Make the tone warmer and kinder; add a brief thank-you if appropriate.",
                                showUserBubble: true
                            )
                        }
                    },
                    onUrgent: {
                        Task {
                            await vm.applyRefine(
                                instruction: "Increase urgency; state a clear action and deadline.",
                                showUserBubble: true
                            )
                        }
                    },
                    onAltTime: {
                        Task {
                            await vm.applyRefine(
                                instruction: "Suggest alternative meeting times.",
                                showUserBubble: true
                            )
                        }
                    },
                    onAddDetails: {
                        Task {
                            await vm.applyRefine(
                                instruction: "Add concise details without changing the main message.",
                                showUserBubble: true
                            )
                        }
                    }
                )
                compactComposer
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                UnevenRoundedRectangle(cornerRadii: .init(topLeading: 24, topTrailing: 24))
                    .fill(Color(.systemBackground).opacity(scheme == .dark ? 0.9 : 0.95))
                    .overlay(
                        UnevenRoundedRectangle(cornerRadii: .init(topLeading: 24, topTrailing: 24))
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.purple.opacity(0.03),
                                        Color.blue.opacity(0.02),
                                        Color.cyan.opacity(0.015)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
            .overlay(
                UnevenRoundedRectangle(cornerRadii: .init(topLeading: 24, topTrailing: 24))
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.purple.opacity(0.2),
                                Color.blue.opacity(0.15),
                                Color.cyan.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    ),
                alignment: .top
            )
            .shadow(
                color: Color.purple.opacity(0.15),
                radius: 15,
                x: 0,
                y: -8
            )
        }
    }

    private var compactComposer: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.systemBackground).opacity(0.8))
                    .frame(height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.purple.opacity(0.2),
                                        Color.blue.opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                
                TextField("Refine your email...", text: $vm.instructions)
                    .font(.system(size: 15, weight: .regular))
                    .padding(.horizontal, 16)
                    .foregroundStyle(.primary)
            }
            
            Button {
                Task { await vm.applyRefine() }
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.purple,
                                    Color.blue,
                                    Color.cyan
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.3), Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                    
                    Group {
                        if vm.isRefining {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 16, weight: .medium))
                                .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)
                        }
                    }
                    .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
            .disabled(vm.isRefining || vm.instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .scaleEffect(vm.isRefining || vm.instructions.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.9 : 1.0)
            .shadow(
                color: Color.purple.opacity(0.4),
                radius: vm.isRefining ? 6 : 10,
                x: 0,
                y: vm.isRefining ? 3 : 5
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: vm.isRefining)
        }
    }

    private func setupInitialAnimation() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
            cardAnimationOffset = 0
            cardAnimationOpacity = 1
            headerScale = 1.0
        }
    }
    
    private func startAnimations() {
        withAnimation(.linear(duration: 0.5)) {
            pulseAnimation = true
        }
        withAnimation(.linear(duration: 0.1)) {
            sparkleRotation = 360
        }
    }
}
