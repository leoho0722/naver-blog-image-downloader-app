import SwiftUI

/// 原生全螢幕圖片檢視器的 SwiftUI 主畫面。
///
/// 使用 `NavigationStack` 搭配 `TabView(.page)` 實現水平翻頁，
/// 並透過 toolbar 與 overlay 提供覆蓋列、膠囊列與檔案資訊 Sheet。
struct PhotoViewerView: View {

    // MARK: - Properties

    /// 檢視器的狀態管理 ViewModel。
    @Bindable var viewModel: PhotoViewerViewModel

    /// TabView 當前選中的頁面索引。
    @State private var selectedTab: Int

    // MARK: - Initialization

    /// 建立 ``PhotoViewerView``。
    ///
    /// - Parameter viewModel: 檢視器的 ViewModel。
    init(viewModel: PhotoViewerViewModel) {
        self.viewModel = viewModel
        self._selectedTab = State(initialValue: viewModel.currentIndex)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                TabView(selection: $selectedTab) {
                    ForEach(viewModel.filePaths.enumerated().map { $0 }, id: \.offset) { _, filePath in
                        ZoomableImageView(filePath: filePath)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: selectedTab) { _, newValue in
                    viewModel.onPageChanged(newValue)
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        viewModel.isImmersive.toggle()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back", systemImage: "chevron.left", action: viewModel.dismiss)
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                }
                ToolbarItem(placement: .principal) {
                    Text("\(viewModel.currentIndex + 1) / \(viewModel.totalCount)")
                        .foregroundStyle(.white)
                        .font(.subheadline.weight(.medium))
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar(viewModel.isImmersive ? .hidden : .visible, for: .navigationBar)
            .overlay(alignment: .bottom) {
                if !viewModel.isImmersive {
                    CapsuleBottomBar(viewModel: viewModel)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 16)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: viewModel.isImmersive)
        }
        .sheet(isPresented: $viewModel.showFileInfo) {
            FileInfoSheet(viewModel: viewModel)
                .presentationDetents([.medium])
        }
    }
}
