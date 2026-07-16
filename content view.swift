import SwiftUI
import Charts

struct ContentView: View {
    @StateObject private var viewModel = StatsViewModel()
    @State private var showingSettings = false
    @State private var showingWebLogin = false
    @State private var loginError: String?

    var body: some View {
        NavigationStack {
            Group {
                if !viewModel.hasCredentials {
                    emptyStateView
                } else if viewModel.isLoading && viewModel.errorMessage == nil {
                    ProgressView("Loading stats")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let stats = viewModel.stats {
                    statsList(stats)
                } else if let error = viewModel.errorMessage {
                    errorView(error)
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("Hackatime")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Picker("Range", selection: $viewModel.timeframe) {
                        ForEach(Timeframe.allCases, id: \.self) { tf in
                            Text(tf.label).tag(tf)
                        }
                    }
                    .onChange(of: viewModel.timeframe) { _ in
                        Task { await viewModel.fetch(force: true) }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(viewModel: viewModel)
        }
        .task {
            await viewModel.fetch()
        }
    }
}

// MARK: - Sections

private func statsList(_ stats: HackatimeStats) -> some View {
    ScrollView {
        VStack(alignment: .leading, spacing: 20) {
            totalCard(stats)

            if !stats.languages.isEmpty {
                sectionHeader("Languages")
                // Replace LanguageList with your actual view if it exists
                // LanguageList(stats.languages)
                languageChart(stats.languages)
                LanguageBar(stats.languages)
            }

            if !stats.projects.isEmpty {
                sectionHeader("Projects")
                ForEach(stats.projects) { project in
                    ProjectRow(
                        project: project,
                        isExpanded: viewModel.isExpanded(project),
                        onTap: { viewModel.toggleExpanded(project: project) }
                    )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }
    .refreshable {
        await viewModel.fetch(force: true)
    }
}

private func totalCard(_ stats: HackatimeStats) -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(viewModel.timeframe.label.uppercased())
            .font(.caption)
            .foregroundStyle(.secondary)
        Text(stats.formattedTotal)
            .font(.system(size: 40, weight: .bold, design: .rounded))
        if let avg = stats.dailyAverage {
            Text("Daily average: \(HackatimeStats.format(seconds: avg))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 10)
    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
}

private func sectionHeader(_ title: String) -> some View {
    Text(title)
        .font(.headline)
        .bold()
        .padding(.top, 10)
}

@ViewBuilder
private func languageChart(_ languages: [StatItem]) -> some View {
    let top = Array(languages.prefix(6))
    Chart(top) { item in
        SectorMark(
            angle: .value("Seconds", item.seconds),
            innerRadius: .ratio(0.6),
            angularInset: 1.5
        )
        .foregroundStyle(by: .value("Language", item.name))
        .cornerRadius(4)
    }
    .frame(height: 200)
    .chartLegend(position: .bottom, spacing: 12)
}

private func LanguageBar(_ languages: [StatItem]) -> some View {
    VStack(spacing: 8) {
        ForEach(languages.prefix(6)) { item in
            HStack {
                Text(item.name)
                    .font(.subheadline)
                    .frame(width: 90, alignment: .leading)
                    .lineLimit(1)
                GeometryReader { geo in
                    let width = max(4, geo.size.width * CGFloat((item.percent ?? 0) / 100))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.tint.opacity(0.7))
                        .frame(width: width, alignment: .trailing)
                }
            }
            .frame(height: 10)
        }
    }
    .padding()
    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
}

// MARK: - Empty & Error states

private var emptyStateView: some View {
    VStack(spacing: 16) {
        Image(systemName: "chart.bar.xaxis")
            .font(.system(size: 48))
            .foregroundStyle(.secondary)
        Text("See your stats")
            .font(.title2.bold())
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
        Button("Login with your Hackatime account") {
            showingWebLogin = true
        }
        .buttonStyle(.borderedProminent)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}

private func errorView(_ message: String) -> some View {
    VStack(spacing: 12) {
        Image(systemName: "exclamationmark.triangle")
            .font(.system(size: 40))
            .foregroundStyle(.orange)
        Text(message)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
        Button("Try again") {
            Task { await viewModel.fetch(force: true) }
        }
        .buttonStyle(.bordered)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}

// MARK: - Expandable Project row

private struct ProjectRow: View {
    let project: StatItem
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: onTap) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(project.name)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                        Text(project.formattedTime)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if let percent = project.percent {
                        Text(String(format: "%.1f%%", percent))
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.tint.opacity(0.7))
                        .frame(
                            width: geo.size.width * CGFloat((project.percent ?? 0) / 100),
                            height: 6
                        )
                }
                .frame(height: 6)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
        .contentShape(Rectangle())
    }
}

#Preview {
    ContentView()
}
