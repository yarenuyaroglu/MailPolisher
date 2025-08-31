import SwiftUI
import UIKit

struct ComposeView: View {
    @StateObject var vm: ComposeViewModel
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var router: Router

    // Tone guide popover
    @State private var showToneHelp = false
    // Reply area expansion
    @State private var isReplyExpanded = false
    // Reply editor focus
    @FocusState private var replyFocused: Bool
    
    // Animation states
    @State private var cardAnimationOffset: CGFloat = 50
    @State private var cardAnimationOpacity: Double = 0
    @State private var headerScale: CGFloat = 0.8
    @State private var pulseAnimation = false
    
    // Auto-sizing for main input editor
    @State private var inputTextHeight: CGFloat = 80


    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                navStackBody
            } else {
                navViewBody
            }
        }
        .onAppear {
            setupInitialAnimation()
            isReplyExpanded = !(vm.draft.incomingMail?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
            startPulseAnimation()
        }
        .onChange(of: vm.draft.incomingMail) { newValue in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                let hasContent = !(newValue?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
                isReplyExpanded = hasContent
                replyFocused = hasContent
            }
        }
    }

    // iOS 16+ NavigationStack body
    @available(iOS 16.0, *)
    @ViewBuilder
    private var navStackBody: some View {
        NavigationStack(path: $router.path) {
            ZStack {
                // Vibrant animated background
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 24) {
                        modernHeader
                        mainList
                    }
                    .padding(.vertical, 32)
                    .padding(.horizontal, 20)
                }
                .scrollIndicators(.hidden)
            }
            .alert("Error", isPresented: .constant(vm.error != nil)) {
                Button("OK") { vm.error = nil }
            } message: { Text(vm.error ?? "") }
            .navigationBarHidden(true)
            .navigationDestination(for: Route.self) { route in
                destination(for: route)
            }
        }
    }
  
    // iOS 15 fallback using NavigationView
    @ViewBuilder
    private var navViewBody: some View {
        NavigationView {
            ZStack {
                // Vibrant animated background
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 24) {
                        modernHeader
                        mainList
                    }
                    .padding(.vertical, 32)
                    .padding(.horizontal, 20)
                }
            }
            .alert("Error", isPresented: .constant(vm.error != nil)) {
                Button("OK") { vm.error = nil }
            } message: { Text(vm.error ?? "") }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Main List
    private var mainList: some View {
        LazyVStack(spacing: 20) {
            inputCard
                .scaleEffect(cardAnimationOffset == 0 ? 1 : 0.95)
                .opacity(cardAnimationOpacity)
                .offset(y: cardAnimationOffset)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: cardAnimationOffset)

            replyCard
                .scaleEffect(cardAnimationOffset == 0 ? 1 : 0.95)
                .opacity(cardAnimationOpacity)
                .offset(y: cardAnimationOffset)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: cardAnimationOffset)

            modernControlsCard
                .scaleEffect(cardAnimationOffset == 0 ? 1 : 0.95)
                .opacity(cardAnimationOpacity)
                .offset(y: cardAnimationOffset)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: cardAnimationOffset)

            modernPrimaryButton
                .scaleEffect(cardAnimationOffset == 0 ? 1 : 0.95)
                .opacity(cardAnimationOpacity)
                .offset(y: cardAnimationOffset)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: cardAnimationOffset)
        }
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .compose:
            ComposeView(vm: vm).environmentObject(router)
        case .results(_, let items, _):
            ResultsView(
                vm: ResultsViewModel(items: items, repo: vm.repo, draft: vm.draft)
            )
            .environmentObject(router)
        }
    }

    // MARK: - Vibrant Animated Background
    private var backgroundGradient: some View {
        ZStack {
            // Dynamic multi-layer gradient
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
                            colors: [Color.purple.opacity(0.1), Color.clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .offset(x: pulseAnimation ? 30 : -30, y: pulseAnimation ? -20 : 20)
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: pulseAnimation)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.blue.opacity(0.08), Color.clear],
                            center: .center,
                            startRadius: 15,
                            endRadius: 120
                        )
                    )
                    .frame(width: 150, height: 150)
                    .offset(x: pulseAnimation ? -40 : 40, y: pulseAnimation ? 40 : -40)
                    .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: pulseAnimation)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.cyan.opacity(0.06), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 80
                        )
                    )
                    .frame(width: 180, height: 180)
                    .offset(x: pulseAnimation ? 20 : -20, y: pulseAnimation ? -30 : 30)
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

    // MARK: - Modern Header
    private var modernHeader: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                // Glassmorphic icon background
                RoundedRectangle(cornerRadius: 16, style: .continuous)
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
                    .frame(width: 56, height: 56)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.3), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                
                Image(systemName: "envelope.badge.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.purple, Color.blue, Color.cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulseAnimation)
            }
            .scaleEffect(headerScale)
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: headerScale)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("MailPolish")
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.primary, Color.purple.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("Professional email enhancement")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.bottom, 8)
    }

    // MARK: - Input Card
    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Your Email", systemImage: "envelope.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.primary, Color.purple.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Spacer()
                HStack(spacing: 6) {
                    Text("\(vm.draft.text.count)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.primary)
                    Text("chars")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.08)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: Capsule()
                )
                .overlay(
                    Capsule()
                        .strokeBorder(Color.purple.opacity(0.2), lineWidth: 1)
                )
            }

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.2), Color.cyan.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                
                
                GrowingTextEditor(text: $vm.draft.text, height: $inputTextHeight)
                    .frame(minHeight: inputTextHeight, maxHeight: inputTextHeight)
                    .padding(16)
                    .font(.system(size: 16, weight: .regular))

                if vm.draft.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Write your email here...")
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.secondary.opacity(0.7), Color.purple.opacity(0.4)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .font(.system(size: 16, weight: .regular))
                        .padding(.horizontal, 22)
                        .padding(.vertical, 22)
                        .allowsHitTesting(false)
                }
            }
        }
        .padding(20)
        .funGlassCard()
    }

    // MARK: - Reply Card
    private var replyCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isReplyExpanded.toggle()
                    if isReplyExpanded { replyFocused = true }
                }
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange.opacity(0.15), Color.pink.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)
                        Image(systemName: "arrowshape.turn.up.left.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.orange, Color.pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Reply to email")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                        Text("Add context to improve polish quality")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary.opacity(0.8))
                    }
                    Spacer()
                    Image(systemName: isReplyExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.orange, Color.pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .rotationEffect(.degrees(isReplyExpanded ? 0 : 180))
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isReplyExpanded)
                }
            }
            .buttonStyle(.plain)

            HStack(spacing: 12) {
                Button {
                    if let s = UIPasteboard.general.string,
                       !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        vm.draft.incomingMail = s
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isReplyExpanded = true
                        }
                        replyFocused = true
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.on.clipboard.fill")
                            .font(.system(size: 14, weight: .medium))
                        Text("Paste")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [Color.green.opacity(0.1), Color.mint.opacity(0.08)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: Capsule()
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.green.opacity(0.3), Color.mint.opacity(0.2)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                }
                .buttonStyle(.plain)

                if !(vm.draft.incomingMail?.isEmpty ?? true) {
                    Button(role: .destructive) {
                        vm.draft.incomingMail = nil
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isReplyExpanded = false
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14, weight: .medium))
                            Text("Clear")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [Color.red.opacity(0.1), Color.pink.opacity(0.08)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: Capsule()
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [Color.red.opacity(0.3), Color.pink.opacity(0.2)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }

            if !isReplyExpanded {
                let preview = (vm.draft.incomingMail ?? "").prefix(120)
                Text(preview.isEmpty ? "Tap to add the original email for better context" : String(preview) + (vm.draft.incomingMail!.count > 120 ? "..." : ""))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.secondary.opacity(0.8))
                    .lineLimit(2)
                    .padding(.top, 4)
            }

            if isReplyExpanded {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [Color.orange.opacity(0.3), Color.pink.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                    
                    TextEditor(text: Binding(
                        get: { vm.draft.incomingMail ?? "" },
                        set: { vm.draft.incomingMail = $0 }
                    ))
                    .focused($replyFocused)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 120, maxHeight: 220)
                    .padding(14)
                    .font(.system(size: 15, weight: .regular))
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") { replyFocused = false }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.purple, Color.blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                    }

                    if (vm.draft.incomingMail ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("Paste the original email here for better context")
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.secondary.opacity(0.7), Color.orange.opacity(0.5)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .font(.system(size: 15, weight: .regular))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 20)
                            .allowsHitTesting(false)
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
        .padding(20)
        .funCard()
    }

    // MARK: - Modern Controls
    private var modernControlsCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Email Settings")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.primary, Color.indigo.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    Text("Configure tone and style preferences")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            
            // Tone
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.teal.opacity(0.15), Color.mint.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "textformat.alt")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.teal)
                    }
                    
                    Text("Tone")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    Button { showToneHelp.toggle() } label: {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 24, height: 24)
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.blue)
                        }
                    }
                    .sheet(isPresented: $showToneHelp) {
                        ToneGuideView(selectedTone: vm.draft.tone)
                            .ignoresSafeArea()
                            .applyPresentationTweaksIfAvailable()
                    }
                }

                Picker("", selection: $vm.draft.tone) {
                    ForEach(Tone.allCases) { tone in
                        Text(tone.rawValue).tag(tone)
                    }
                }
                .pickerStyle(.segmented)
                .colorMultiply(Color.purple.opacity(0.4))

                Text(vm.draft.tone.helpText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
                    .transition(.opacity .combined(with: .move(edge: .top)))
            }

            // Domain
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.indigo.opacity(0.15), Color.purple.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.indigo)
                    }
                    Text("Domain")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                
                Picker("", selection: $vm.draft.sector) {
                    ForEach(Sector.allCases) { sector in
                        Text(sector.rawValue).tag(sector)
                    }
                }
                .pickerStyle(.segmented)
                .colorMultiply(Color.indigo.opacity(0.4))
            }

            // Empathy
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.pink.opacity(0.15), Color.red.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.pink)
                    }
                    Text("Communication Style")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                    Text(empathyLevelName(for: vm.draft.empathy))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                colors: empathyGradientColors(for: vm.draft.empathy),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: Capsule()
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: vm.draft.empathy)
                }

                modernEmpathySelector

                Text(empathyDescription(for: vm.draft.empathy))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
                    .transition(.opacity .combined(with: .move(edge: .top)))
            }
        }
        .padding(20)
        .funGlassCard()
    }

    // MARK: - Modern Primary Button
    private var modernPrimaryButton: some View {
        Button { Task { await vm.polish() } } label: {
            HStack(spacing: 12) {
                if vm.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                Text(vm.isLoading ? "Processing..." : "Polish Email")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                if !vm.isLoading {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                ZStack {
                    // Main gradient
                    LinearGradient(
                        colors: [
                            Color.purple,
                            Color.blue,
                            Color.cyan
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Animated shimmer effect
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.white.opacity(0.2),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: pulseAnimation ? 200 : -200)
                        .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: pulseAnimation)
                        .mask(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(vm.isLoading || !vm.draft.isValid)
        .scaleEffect(vm.isLoading || !vm.draft.isValid ? 0.98 : 1.0)
        .shadow(
            color: Color.purple.opacity(0.4),
            radius: vm.isLoading ? 6 : 12,
            x: 0,
            y: vm.isLoading ? 3 : 6
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: vm.isLoading)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: vm.draft.isValid)
    }

    // MARK: - Animation
    private func setupInitialAnimation() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
            cardAnimationOffset = 0
            cardAnimationOpacity = 1
            headerScale = 1.0
        }
    }
    
    private func startPulseAnimation() {
        withAnimation(.linear(duration: 0.5)) {
            pulseAnimation = true
        }
    }

    // MARK: - Modern Empathy Selector
    private var modernEmpathySelector: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { level in
                modernEmpathyButton(for: level)
            }
        }
    }
    
    private func modernEmpathyButton(for level: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                vm.draft.empathy = level
            }
        } label: {
            VStack(spacing: 8) {
                Image(systemName: empathyIcon(for: level))
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(
                        vm.draft.empathy == level
                        ? LinearGradient(colors: [.white, .white], startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(
                            colors: empathyGradientColors(for: level),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(vm.draft.empathy == level ? 1.1 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.8), value: vm.draft.empathy)
                
                Text(empathyLevelName(for: level))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(vm.draft.empathy == level ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                vm.draft.empathy == level
                ? LinearGradient(
                    colors: empathyGradientColors(for: level),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                : LinearGradient(
                    colors: [Color(.systemGray6), Color(.systemGray5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        vm.draft.empathy == level
                        ? LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [Color(.systemGray4), Color(.systemGray3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: vm.draft.empathy == level ? 1.5 : 1
                    )
            )
            .shadow(
                color: vm.draft.empathy == level
                ? empathyGradientColors(for: level)[0].opacity(0.3)
                : Color.clear,
                radius: vm.draft.empathy == level ? 8 : 0,
                x: 0,
                y: vm.draft.empathy == level ? 4 : 0
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empathy Helpers
    private func empathyLevelName(for level: Int) -> String {
        switch level {
        case 0: return "Direct"
        case 1: return "Balanced"
        case 2: return "Warm"
        default: return "Balanced"
        }
    }
    
    private func empathyIcon(for level: Int) -> String {
        switch level {
        case 0: return "square.grid.3x1.below.line.grid.1x2"
        case 1: return "equal.circle"
        case 2: return "person.2"
        default: return "equal.circle"
        }
    }
    
    private func empathyDescription(for level: Int) -> String {
        switch level {
        case 0: return "Professional and concise communication with clear objectives"
        case 1: return "Balanced approach with appropriate professional courtesy"
        case 2: return "Considerate tone with empathetic and collaborative language"
        default: return "Balanced approach with appropriate professional courtesy"
        }
    }
    
    private func empathyGradientColors(for level: Int) -> [Color] {
        switch level {
        case 0: return [Color.red, Color.orange]
        case 1: return [Color.blue, Color.teal]
        case 2: return [Color.pink, Color.purple]
        default: return [Color.blue, Color.teal]
        }
    }
}

// MARK: - Fun Glass Card Modifiers
private struct FunGlassCard: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Glassmorphic background
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            Color(.systemBackground)
                                .opacity(scheme == .dark ? 0.8 : 0.95)
                        )
                    
                    // Subtle gradient overlay
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
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
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
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
                    )
            )
            .shadow(
                color: Color.purple.opacity(scheme == .dark ? 0.2 : 0.1),
                radius: 12,
                x: 0,
                y: 6
            )
    }
}

private struct FunCard: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                    
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.orange.opacity(0.04),
                                    Color.pink.opacity(0.03),
                                    Color.red.opacity(0.02)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.orange.opacity(0.2),
                                Color.pink.opacity(0.15),
                                Color.red.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(
                color: Color.orange.opacity(scheme == .dark ? 0.15 : 0.08),
                radius: 8,
                x: 0,
                y: 4
            )
    }
}

private extension View {
    func funGlassCard() -> some View { self.modifier(FunGlassCard()) }
    func funCard() -> some View { self.modifier(FunCard()) }

    @ViewBuilder
    func applyPresentationTweaksIfAvailable() -> some View {
        if #available(iOS 16.4, *) {
            self
                .presentationBackground(.clear)
                .presentationCornerRadius(0)
                .presentationDragIndicator(.hidden)
        } else {
            self
        }
    }
}
// MARK: - Auto-growing TextEditor (iOS 15+)
struct GrowingTextEditor: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    
    private let minHeight: CGFloat = 40
    private let maxHeight: CGFloat = 280
    
    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        tv.text = text
        tv.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        tv.delegate = context.coordinator
        tv.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return tv
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        recalcHeight(view: uiView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func recalcHeight(view: UITextView) {
        let size = CGSize(width: view.bounds.width, height: .infinity)
        let fitting = view.sizeThatFits(size).height
        let clamped = max(minHeight, min(fitting, maxHeight))
        if abs(height - clamped) > 0.5 {
            DispatchQueue.main.async {
                self.height = clamped
                view.isScrollEnabled = fitting > maxHeight
            }
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: GrowingTextEditor
        init(_ parent: GrowingTextEditor) { self.parent = parent }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.recalcHeight(view: textView)
        }
    }
}

