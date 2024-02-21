//
//  VideoPlayerView.swift
//  clearoutt
//
//  Created by Bolanle Adisa on 2/19/24.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    var videoURL: URL

    var body: some View {
        VideoPlayer(player: AVPlayer(url: videoURL))
            .edgesIgnoringSafeArea(.all)
    }
}
