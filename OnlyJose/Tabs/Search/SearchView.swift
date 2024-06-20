//
//  SearchView.swift
//  OnlyJose
//
//  Created by Adem Özsayın on 10.06.2024.
//

//
//  SearchView.swift
//  Atwy
//
//  Created by Antoine Bollengier on 24.11.22.
//
import Env
import SwiftUI
import InfiniteScrollViews
import YouTubeKit
import SwipeActions
import DesignSystem

let YTM = YouTubeModel()

struct SearchView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismissSearch) private var dismissSearch
    @Environment(UserPreferences.self) private var preferences
    
    @State private var autoCompletion: [String] = []
    @State private var search: String = "jose mourinho" {
        didSet {
            refreshAutoCompletionEntries()
        }
    }
    
    @State private var searchDemoData: String = "Erkin Arslan - The Special One (Official Audio)"
    
    @State private var autoCompletionHeaders: HeadersList?
    @State private var needToReload = true
    @State private var isShowingSettingsSheet: Bool = false
    
    @State private var firstDisplayedResult: Int = 0
    @State private var shouldReloadScrollView: Bool = false
    @State private var hasToReloadPadding: Bool = true
    @State private var isShowingPaddedFirstVideo: Bool = false
    
    @ObservedObject private var model = Model.shared
    @ObservedObject private var IUTM = IsUserTypingModel.shared
    @ObservedObject private var VPM = VideoPlayerModel.shared
    //    @ObservedObject private var NPM = NavigationPathModel.shared
    @Environment(RouterPath.self) private var routerPath
    
    @ObservedObject private var APIM = APIKeyModel.shared
    @ObservedObject private var NRM = NetworkReachabilityModel.shared
    //    @ObservedObject private var PSM = PreferencesStorageModel.shared
    @Environment(Theme.self) private var theme
    @State private var isFetching: Bool = false
    @State private var libraryContent: AccountLibraryResponse?
    
    @State private var playlists: [YTPlaylist] = []
    
    @Binding var scrollToTopSignal: Int
    
    public init(scrollToTopSignal: Binding<Int>) {
        _scrollToTopSignal = scrollToTopSignal
    }
    
    
    var body: some View {
        
        ZStack{
            GeometryReader { geometry in
                Image("bg")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .aspectRatio(contentMode: .fill)
                    .opacity(preferences.showBackgroundImage ? 1 : 0)
                
                VStack {
                    if model.isFetching {
                        LoadingView()
                    } else if let error = model.error {
                        VStack (alignment: .center) {
                            Spacer()
                            Image(systemName: "multiply.circle")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.red)
                            Text(error)
                                .foregroundColor(.red)
                            Button {
                                search = ""
                                dismissSearch()
                                model.getVideos(demo: false)
                            } label: {
                                Text("Go home")
                            }
                            .buttonStyle(.bordered)
                            Spacer()
                        }
                    } else if model.items.isEmpty && model.error == nil {
                        GeometryReader { geometry in
                            ScrollView {
                                VStack {
                                    Text("No videos found...")
                                        .foregroundColor(theme.labelColor)
                                    Text("Search videos or pull up to refresh for the algorithm to fill this menu.")
                                        .foregroundStyle(.gray)
                                        .font(.caption)
                                }
                                .frame(width: geometry.size.width, height: geometry.size.height)
                            }
                            .scrollIndicators(.hidden)
                            .refreshable(action: {
                                if search.isEmpty {
                                    model.getVideos(demo: false)
                                } else {
                                    model.getVideos(search, demo: false)
                                }
                            })
                        }
                    } else {
                        let itemsBinding = Binding(get: {
                            return model.items.map({YTElementWithData(element: $0, data: .init())})
                        }, set: { newValue in
                            model.items = newValue.map({$0.element})
                        })
                        ElementsInfiniteScrollView(
                            items: itemsBinding,
                            shouldReloadScrollView: $shouldReloadScrollView,
                            refreshAction: { endAction in
                                withAnimation(.easeOut(duration: 0.3)) {
                                    endAction()
                                    if search.isEmpty {
                                        model.getVideos(demo: false)
                                    } else {
                                        model.getVideos(search, demo: false)
                                    }
                                }
                            },
                            fetchMoreResultsAction: {
                                if !model.isFetchingContination {
                                    model.getVideosContinuation({
                                        self.shouldReloadScrollView = true
                                    })
                                }
                            }
                        )
                    }
                }
                
                .task {
                    
                    if needToReload {
                        if search.isEmpty {
                            model.getVideos(demo: false)
                        } else {
                            model.getVideos(search,demo: false)
                            let ytVideo = YTVideo(
                                videoId: "gO70C5Q_f6Y",
                                title: "The special One",
                                thumbnails: [YTThumbnail(url: URL(string: "https://i.ytimg.com/vi/VLFy-a-_wFI/hq720.jpg?sqp=-oaymwEjCOgCEMoBSFryq4qpAxUIARUAAAAAGAElAADIQj0AgKJDeAE=&rs=AOn4CLDhGZLAAHzUFdfBbe2Yx-wS6h3_Dg")!)]
                            )
                            
                            if preferences.enableAutoPlayAtStart {
                                VideoPlayerModel.shared.loadVideo(video: ytVideo, thumbnailData: nil, channelAvatarImageData: nil)
                            }
                            
                            model.getVideos(searchDemoData, demo: true)
                            //
                        }
                        needToReload = false
                        
                        
                    }
                }
                .onAppear {
                    
                }
            }
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.automatic)
        .environment(routerPath)
    }
    
    func refreshAutoCompletionEntries() {
        Task {
            let result = try? await AutoCompletionResponse.sendThrowingRequest(youtubeModel: YTM, data: [.query: self.search])
            DispatchQueue.main.async {
                self.autoCompletion = result?.autoCompletionEntries ?? []
            }
        }
    }
}


protocol ViewRepresentable {
    associatedtype Content: View
    @ViewBuilder func getView() -> Content
}








