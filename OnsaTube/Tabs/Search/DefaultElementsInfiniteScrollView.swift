//
//  DefaultElementsInfiniteScrollView.swift
//  OnsaTube
//
//  Created by Adem Özsayın on 20.06.2024.
//

import SwiftUI
import YouTubeKit
#if !os(visionOS)
import SwipeActions
#endif

struct DefaultElementsInfiniteScrollView: View {
    @Binding var items: [YTElementWithData]
    @Binding var shouldReloadScrollView: Bool
    
    var fetchNewResultsAtKLast: Int = 5
    var shouldAddBottomSpacing: Bool = false // add the height of the navigationbar to the bottom
    @ObservedObject private var PSM = PreferencesStorageModel.shared
    @ObservedObject private var NRM = NetworkReachabilityModel.shared
    
    var refreshAction: ((@escaping () -> Void) -> Void)?
    var fetchMoreResultsAction: (() -> Void)?
    var body: some View {
        GeometryReader { geometry in
            // We could switch to List very easily but a performance check is needed as we already use a lazyvstack
            // List {
            ScrollView {
                LazyVStack {
                    let itemsCount = items.count
                    if itemsCount < fetchNewResultsAtKLast {
                        Color.clear.frame(width: 0, height: 0)
                            .onAppear {
                                fetchMoreResultsAction?()
                            }
                    }
                    ForEach(Array(items.enumerated()), id: \.offset) { itemOffset, item in
                        HStack(spacing: 0) {
                            if itemsCount >= fetchNewResultsAtKLast && itemsCount - itemOffset == fetchNewResultsAtKLast + 1 {
                                Color.clear.frame(width: 0, height: 0)
                                    .onAppear {
                                        fetchMoreResultsAction?()
                                    }
                            }
                            switch item.element {
                                case let item as YTChannel:
                                    item.getView()
                                        .frame(width: geometry.size.width, height: 180, alignment: .center)
                                case let item as YTPlaylist:
                                    #if !os(visionOS)
                                    SwipeView {
                                        item.getView()
                                            .padding(.horizontal, 5)
                                    } trailingActions: { context in
                                        if NRM.connected {
                                            if let channel = item.channel {
                                                SwipeAction(
                                                    action: {},
                                                    label: { _ in
                                                        Image(systemName: "person.crop.rectangle")
                                                            .foregroundStyle(.white)
                                                    },
                                                    background: { _ in
                                                        Rectangle()
                                                            .fill(.cyan)
                                                        //                                                            .routeTo(.channelDetails(channel: channel))
                                                            .onDisappear {
                                                                context.state.wrappedValue = .closed
                                                            }
                                                    }
                                                )
                                            }
                                        }
                                    }
                                    .swipeMinimumDistance(50)
                                    .frame(width: geometry.size.width, height: 180, alignment: .center)
                                    #endif
                                case let rawVideo as YTVideo:
                                    if let state = PSM.propetriesState[.videoViewMode] as? PreferencesStorageModel.Properties.VideoViewModes, state == .halfThumbnail {
                                        VideoFromSearchView(videoWithData: rawVideo.withData(item.data))
                                            .frame(width: geometry.size.width, height: 180, alignment: .center)
                                    } else {
                                        // Big thumbnail view by default
                                        VideoFromSearchView(videoWithData: rawVideo.withData(item.data))
                                            .frame(width: geometry.size.width, height: geometry.size.width * 9/16 + 90, alignment: .center)
                                        //                                            .padding(.bottom, resultIndex == 0 ? geometry.size.height * 0.2 : 0)
                                    }
                                default:
                                    Color.clear.frame(width: 0, height: 0)
                            }
                        }
                    }
                    
                    Color.clear.frame(height: shouldAddBottomSpacing ? 49 : 0)
                }
            }
            // .listStyle(.plain)
            .refreshable {
                refreshAction?{}
            }
        }
        .id(PSM.propetriesState[.videoViewMode] as? PreferencesStorageModel.Properties.VideoViewModes == .halfThumbnail)
    }
}
