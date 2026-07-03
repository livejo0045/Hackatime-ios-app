




import swuftUI
import charts

struct contentview: View {
    @stateobject private var viewModel = statsViewModel()
    @state privete var showingSettings = false
    
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
