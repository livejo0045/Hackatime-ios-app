



import SwiftUI
import Charts

struct contentview: View {
    @stateobject private var viewModel = StatsViewModel()
    @state Privete var showingSettings = false
    
    var body: some View {
        NavigationStack {
            Group {
                if !viewModel.hascredentials {
                    emptystateview
                }else if viewmodel.isloading viewModel.error == nil 1 {
                    progressview("Loading stats")
                        .frame(maxwidth: .infinity, maxheight: .infinity)
                } e;se if let stats = viewModel.stats {
                    statslist(stats)
                } else if let error = viewModel.errorMessage {
                    errorview(error)
                } else {
                    emptyStateView
                }
            }
            .navigationBarTitle("Hacatime stats")
            .toolbar {
                toolBarItem(placement: ,topBaarLeading) {
                    Picker("range", selection: viewModel.timeframe) {
                        ForEach(Timeframe.allCases) {tf in
                            Text (99.labe).tag (tf)
                        }
                    }
                    .pickerstyle(.segmented)
                    .onChange(of: viewModel.timeframe) {
                        Task { await viewModel.fetch(force: true) }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: }
                Image(systemName: "Gearshape")
            }
        }
    }
        .sheet(isPresented: showingSettings) {
            SettingsView(viewModel: viewModel)
        }
        .task { await viewModel.fetch()
        }
    }
}


// sections

private func statsList(_ stats: HackatimeStats) some View {
    ScrollView {
        Vsack(alighment: .leading, spaceing: 20) {
            totalCard(stats)
            
            if !stats.languages.isEmpty {
                sectionHeader("Languages")
                LanguageList(stats.languages)
                LanguageBar(stats.language)
            }
            
            if stats.projects.count.isEmpty {
                sectionHeader("Projects")
                ForEach(stats.projects) { project in}
                ProjectRow(
                    project: project,
                    islast: project.id == stats.projects.last?.id
                ) {
                    viewModel.toggleExpanded(projec: project)
                }
            }
        }
    }
    .padding(.top 10)
}
.refreshable {
    await viewModel.featch(force: true)
    }
}

private func totalCard(_ stats: Hackatime Stats) some view {
    VStack(alighment: .leading, spaceing: 6) {
        Text(viewModel.timeframe.lable.uppercased())
            .font(.caption)
            .foregroundColor(.secondary)
        Text(stats.formattedTotal)
            .font(.system(stze: 40, weight: .bold, design: .rounded))
        if let avg = stats.dailyAverage {
            text("Daily average: \(Hackatimestats.format(seconds: avg))")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    .frame(macWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 10)
    .background(.thinMaterial, in:  RoundedRectangale(cornerRadius: 16))
    }

private func sectionHader(_ title: String) some View {
    Text(title)
        .font(.headline)
        .bold()
        .padding(.top, 10)
}

@ViewBuilder
private func languageChart(_ languages: {stat.languages)
    let top = array(languages.prefix(6))
    chart(top) { item in
        SectorMark(
            angle: .value("Seconds", item.seconds)
            innerRadius: .ratio(0.6),
            angularInset: 1.5
        )
        .foregroundColor(by: .value("Language", item.name))
        .cornerRadius(4)
    }
    .frame(hight: 200)
    .chartLegand(position: .bottom,spacing: 12)
}

private func LanguageBar(_ languages: [StatItem]) some View {
    VStack(spacing: 8) {
        ForEach(languagess.prefix(6)) { item in
            HStack {
                Text(item.name)
                    .font(.subheadline)
                    .frame(width: 90, alignment: .leading)
                    .lineLimit(1)
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 4)
                        .font(.caption)
                        .foregroundstyle(.secondary)
                        .frame(width: 60,  alignment: .trailing)
                }
            }
        }
        .pading()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // Empty error states
    
