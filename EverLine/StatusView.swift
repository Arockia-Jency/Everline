import SwiftUI

public struct StatusView: View {
    public enum StatusStyle: Equatable {
        case success
        case warning
        case error
        case info
        case custom(color: Color, symbol: String)

        var color: Color {
            switch self {
            case .success: return .green
            case .warning: return .yellow
            case .error: return .red
            case .info: return .blue
            case .custom(let color, _): return color
            }
        }

        var symbol: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.octagon.fill"
            case .info: return "info.circle.fill"
            case .custom(_, let symbol): return symbol
            }
        }
    }

    private let title: String
    private let message: String?
    private let style: StatusStyle
    private let actionTitle: String?
    private let action: (() -> Void)?
    private let showsProgress: Bool

    public init(
        title: String,
        message: String? = nil,
        style: StatusStyle = .info,
        actionTitle: String? = nil,
        showsProgress: Bool = false,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.style = style
        self.actionTitle = actionTitle
        self.showsProgress = showsProgress
        self.action = action
    }

    public var body: some View {
        VStack(spacing: 12) {
            iconView
                .font(.system(size: 44))
                .foregroundStyle(style.color)
                .symbolRenderingMode(.multicolor)
                .accessibilityHidden(true)

            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                if let message {
                    Text(message)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
            }

            if showsProgress {
                ProgressView()
                    .tint(style.color)
            }

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
                    .tint(style.color)
                    .accessibilityLabel(actionTitle)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.thinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(style.color.opacity(0.2), lineWidth: 1)
        )
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        var parts: [String] = []
        switch style {
        case .success: parts.append("Success")
        case .warning: parts.append("Warning")
        case .error: parts.append("Error")
        case .info: parts.append("Info")
        case .custom: break
        }
        parts.append(title)
        if let message { parts.append(message) }
        return parts.joined(separator: ", ")
    }

    @ViewBuilder
    private var iconView: some View {
        if showsProgress {
            ZStack {
                Image(systemName: style.symbol)
                    .opacity(0.25)
                ProgressView()
                    .progressViewStyle(.circular)
            }
        } else {
            Image(systemName: style.symbol)
        }
    }
}

#Preview("Samples") {
    ScrollView {
        VStack(spacing: 24) {
            StatusView(
                title: "All good",
                message: "Everything completed successfully.",
                style: .success
            )
            StatusView(
                title: "Be careful",
                message: "Check your network connection.",
                style: .warning,
                actionTitle: "Retry",
                action: {}
            )
            StatusView(
                title: "Something went wrong",
                message: "Please try again later.",
                style: .error,
                showsProgress: false
            )
            StatusView(
                title: "Loading data",
                message: "Fetching the latest updates...",
                style: .info,
                showsProgress: true
            )
            StatusView(
                title: "Custom",
                message: "Branded status with custom color and symbol.",
                style: .custom(color: .purple, symbol: "sparkles")
            )
        }
        .padding()
    }
}
