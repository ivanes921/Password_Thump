import SwiftUI
import UIKit

struct LockScreenView: View {
    let passcodeLength: Int
    let backgroundImage: UIImage?

    @State private var input: String = ""
    @State private var attempts: Int = 0
    @State private var showError: Bool = false
    @State private var shakeToggle: Bool = false

    var body: some View {
        ZStack {
            if let backgroundImage {
                Image(uiImage: backgroundImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .overlay(Color.black.opacity(0.35))
            } else {
                LinearGradient(colors: [.blue.opacity(0.6), .indigo], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            }

            VStack(spacing: 32) {
                Text("Введите код-пароль")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)

                HStack(spacing: 14) {
                    ForEach(0..<passcodeLength, id: \.self) { index in
                        Circle()
                            .strokeBorder(Color.white.opacity(0.8), lineWidth: 1)
                            .background(Circle().fill(index < input.count ? Color.white : Color.clear))
                            .frame(width: 18, height: 18)
                    }
                }
                .modifier(Shake(animatableData: CGFloat(shakeToggle ? 1 : 0)))

                if showError {
                    Text("Неверный пароль")
                        .foregroundColor(.red)
                        .transition(.opacity)
                }

                Spacer()

                keypad
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 40)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var keypad: some View {
        VStack(spacing: 12) {
            ForEach([["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"]], id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { digit in
                        keypadButton(label: digit) {
                            handleInput(digit)
                        }
                    }
                }
            }

            HStack(spacing: 12) {
                keypadButton(label: "Удалить") {
                    if !input.isEmpty { input.removeLast() }
                }
                keypadButton(label: "0") { handleInput("0") }
                keypadButton(label: "Очистить") { input = "" }
            }
        }
        .padding(.bottom, 24)
    }

    private func keypadButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.title3.weight(.semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.white.opacity(0.12))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func handleInput(_ digit: String) {
        guard input.count < passcodeLength else { return }
        input.append(digit)

        if input.count == passcodeLength {
            processAttempt()
        }
    }

    private func processAttempt() {
        let currentAttempt = attempts + 1

        if currentAttempt < 3 {
            attempts += 1
            withAnimation(.easeInOut(duration: 0.2)) {
                showError = true
                shakeToggle.toggle()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation { showError = false }
                input.removeAll()
            }
        } else {
            let badgeValue = max((Int(input) ?? 0) - 2025, 0)
            AppBadgeManager.setBadge(to: badgeValue)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                exit(0)
            }
        }
    }
}

struct Shake: GeometryEffect {
    var amount: CGFloat = 8
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)), y: 0))
    }
}

struct LockScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LockScreenView(passcodeLength: 6, backgroundImage: UIImage(systemName: "photo"))
    }
}
