//
//  SubscribeButtonOverlayView.swift
//  Atwy
//
//  Created by Antoine Bollengier on 18.04.2024.
//  Copyright © 2024 Antoine Bollengier (github.com/b5i). All rights reserved.
//  

import Foundation
import SwiftUI

struct SubscribeButtonOverlayView: View {
    @ObservedObject var currentItem: YTAVPlayerItem
    @State private var isFetching: Bool = false
    @ObservedObject private var APIM = APIKeyModel.shared
    var body: some View {
        if let subscriptionStatus = currentItem.moreVideoInfos?.authenticatedInfos?.subscriptionStatus, let channel = currentItem.moreVideoInfos?.channel {
            if APIM.userAccount != nil && APIM.googleCookies != "" {
                if isFetching {
                    ZStack {
                        Circle()
                            .foregroundStyle(.gray)
                        ProgressView()
                            .foregroundStyle(.white)
                            .controlSize(.mini)
                            .padding()
                    }
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                    .offset(x: 10, y: 7)
                    .shadow(radius: 3)
                } else {
                    if subscriptionStatus {
                        Button {
                            DispatchQueue.main.async {
                                self.isFetching = true
                            }
                            channel.unsubscribe(youtubeModel: YTM, result: { error in
                                if let error = error {
                                    print("Error while unsubscribing to channel: \(error)")
                                } else {
                                    currentItem.setNewSubscriptionStatus(false)
                                }
                                DispatchQueue.main.async {
                                    self.isFetching = false
                                }
                            })
                        } label: {
                            ZStack(alignment: .center) {
                                Rectangle()
                                    .foregroundStyle(.white)
                                    .frame(width: 23, height: 23)
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.green)
                                    .frame(width: 25, height: 25)
                            }
                        }
                        .background(.white)
                        .buttonStyle(.borderedProminent)
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                        .offset(x: 10, y: 7)
                        .shadow(radius: 3)
                    } else {
                        Button {
                            DispatchQueue.main.async {
                                self.isFetching = true
                            }
                            channel.subscribe(youtubeModel: YTM, result: { error in
                                if let error = error {
                                    print("Error while subscribing to channel: \(error)")
                                } else {
                                    currentItem.setNewSubscriptionStatus(true)
                                }
                                DispatchQueue.main.async {
                                    self.isFetching = false
                                }
                            })
                        } label: {
                            ZStack(alignment: .center) {
                                Rectangle()
                                    .foregroundStyle(.white)
                                    .frame(width: 23, height: 23)
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.red)
                                    .frame(width: 25, height: 25)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                        .offset(x: 10, y: 7)
                        .shadow(radius: 3)
                    }
                }
            }
        }
    }
}
