//
//  ChannelAvatarView.swift
//  Atwy
//
//  Created by Antoine Bollengier on 18.04.2024.
//  Copyright © 2024 Antoine Bollengier (github.com/b5i). All rights reserved.
//  

import Foundation
import SwiftUI

struct ChannelAvatarView: View {
    let makeGradient: (UIImage) -> Void
    @ObservedObject var currentItem: YTAVPlayerItem
    var body: some View {
        ZStack {
            if let channelAvatar = (currentItem.streamingInfos.channel?.thumbnails.maxFor(2) ?? currentItem.moreVideoInfos?.channel?.thumbnails.maxFor(2)) ?? currentItem.video.channel?.thumbnails.maxFor(2) {
                CachedAsyncImage(url: channelAvatar.url) { _, imageData in
                    if !imageData.isEmpty, let uiImage = UIImage(data: imageData) {
                        AvatarCircleView(image: uiImage, makeGradient: makeGradient)
                    } else if let imageData = currentItem.channelAvatarImageData, let image = UIImage(data: imageData) {
                        AvatarCircleView(image: image, makeGradient: makeGradient)
                    } else {
                        NoAvatarCircleView(makeGradient: makeGradient)
                    }
                }
            } else if let imageData = currentItem.channelAvatarImageData, let image = UIImage(data: imageData) {
                AvatarCircleView(image: image, makeGradient: makeGradient)
            } else {
                NoAvatarCircleView(makeGradient: makeGradient)
            }
        }
    }
}
