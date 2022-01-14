//
//  VideoPlayerViewController.swift
//  HFKit
//
//  Created by helfy on 2022/1/13.
//

import UIKit
import AVKit
class VideoPlayerViewController: UIViewController {

    @IBOutlet weak var videoView: UIView!
    
    var player:AVPlayer?
    let resourceLoader = HFResourceLoader()
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
//        let videos = ["https://mvvideo5.meitudata.com/56ea0e90d6cb2653.mp4","https://www.apple.com/105/media/cn/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/bruce/mac-bruce-tpl-cn-2018_1280x720h.mp4"]
    
        let item = resourceLoader.playerItem(url: URL(string: "https://mvvideo5.meitudata.com/56ea0e90d6cb2653.mp4")!)
        let player = AVPlayer(playerItem: item)
        let playlayer = AVPlayerLayer(player: player)
        playlayer.frame = videoView.bounds
        videoView.layer.addSublayer(playlayer)
        
        player.play()
        self.player = player
       
        // Do any additional setup after loading the view.
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
