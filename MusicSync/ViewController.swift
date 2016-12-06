//
//  ViewController.swift
//  MusicSync
//
//  Created by Ziad Ali on 11/30/16.
//  Copyright © 2016 ZiadCorp. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import Firebase
import AVFoundation
import Kronos

class ViewController: UIViewController {

    var player = AVPlayer()
    let formatter = DateFormatter()
    var timeDate:Date!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var differenceLabel: UILabel!
    var audioDurationSeconds:Float64!
    var audioIsPlaying = false
    var resetAudio = true
    var timeScale:CMTimeScale!
    let dateObject = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Clock.sync(from: "time.apple.com", samples: 8, first: nil, completion: { (date, interval) in
            print("Completed Sync")
        })
        
        let url = "https://firebasestorage.googleapis.com/v0/b/jordan-music.appspot.com/o/Change%20is%20Coming-2%201.mp3?alt=media&token=57bc3eae-06fc-445a-832c-d1c65552f60c"
        initializePlayer(url: url)
        
        let ref = FIRDatabase.database().reference().child("Time")
        ref.observe(.value, with: { (snapshot) in
            let time = snapshot.value as! String
            self.timeDate = self.formatter.date(from: time)
            self.resetAudio = true
            
            if let _ = Clock.now {
                let timeInterval = Clock.now?.timeIntervalSince(self.timeDate)
                let seekTime = CMTimeMakeWithSeconds(timeInterval!, self.timeScale!)
                self.player.seek(to: seekTime)
                self.player.play()
            }
            
            //let date = Date()
            //self.timeInterval = date.timeIntervalSince(timeDate!)
            //print("Value: \(self.timeInterval)")
        })
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        let _ = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { (timer) in
            if let clockDate = Clock.now {
                self.differenceLabel.text = "Clock: \(self.formatter.string(from: clockDate))"
            }
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func printTime(_ sender: Any) {
        let ref = FIRDatabase.database().reference().child("Time")
        let currentTime = Date(timeIntervalSinceReferenceDate: NSDate.timeIntervalSinceReferenceDate)
        let timeString = formatter.string(from: currentTime)
        print("Date: \(timeString)")
        ref.setValue(formatter.string(from: Clock.now!))
    }
    
    func initializePlayer(url: String)
    {
        //Set player to play song specified by url
        let playerItem = AVPlayerItem(url: URL(string: url)!)
        player = AVPlayer(playerItem:playerItem)
        
        //Get length of song
        let asset = AVURLAsset(url: URL(string: url)!)
        let audioDuration = asset.duration
        audioDurationSeconds = CMTimeGetSeconds(audioDuration)
        print("Song length in seconds: \(audioDurationSeconds)")
        player.rate = 1.0;
        
        timeScale = self.player.currentItem?.asset.duration.timescale
    }

}

