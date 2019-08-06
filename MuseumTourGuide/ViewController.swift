//
//  ViewController.swift
//  MuseumTourGuide
//
//  Created by Jeffrey Cheung on 13/11/2018.
//  Copyright © 2018 Jeffrey Cheung. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

var dis_1: Double = 0
var dis_2: Double = 0
var mintString: [String] = []
var coconutStirng: [String] = []
var emptyString: [String] = []
var isPlaying = false //check play button
var ismintPlaying = false //check mint beacon playing
var iscoconutPlaying = false //check coconut beacon playing
var ismintHidden = false //check mint beacon far
var iscoconutHidden = false //check coconut beacon far
let sound_mint = Bundle.main.path(forResource: "sound_mint", ofType: "mp3")
let sound_coconut = Bundle.main.path(forResource: "sound_coconut", ofType: "mp3")
let defaults = UserDefaults.standard
let hello = "hello"

class ViewController: UIViewController, CLLocationManagerDelegate,AVAudioPlayerDelegate {
    var player_mint: AVAudioPlayer = AVAudioPlayer()
    var player_coconut: AVAudioPlayer = AVAudioPlayer()
    var locationManager: CLLocationManager!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBAction func Stop(_ sender: Any) {
        player_mint.stop()
        player_coconut.stop()
        isPlaying = false
        print("stop")
    }
    @IBAction func Replay(_ sender: Any) {
        player_mint.currentTime = 0
        player_coconut.currentTime = 0
        if ismintHidden == false && iscoconutHidden == true{
            player_mint.play()
        } else if iscoconutHidden == false && ismintHidden == true {
            player_coconut.play()
        }
        isPlaying = true
        print("replay")
    }
    @IBAction func Resume(_ sender: Any) {
        //player.play()
        if ismintHidden == false && iscoconutHidden == true{
            player_mint.play()
        } else if iscoconutHidden == false && ismintHidden == true {
            player_coconut.play()
        }
        isPlaying = true
        print ("resume")
    }
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var replayButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        do {
            player_mint = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound_mint!))
            player_coconut = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: sound_coconut!))
            
        } catch {
            print(error)
        }
        resumeButton.isHidden = true
        stopButton.isHidden = true
        replayButton.isHidden = true
        defaults.removeObject(forKey: "mint")
        defaults.removeObject(forKey: "coconut")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        let uuid = UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!
        let mintRegion = CLBeaconRegion(proximityUUID: uuid, major: 9883, minor: 14383, identifier: "mintBeacon")
        let coconutRegion = CLBeaconRegion(proximityUUID: uuid, major: 45474, minor: 7996, identifier: "coconutBeacon")
        //for first beacon
        locationManager.startMonitoring(for: mintRegion)
        locationManager.startRangingBeacons(in: mintRegion)
        //for second beacon
        locationManager.startMonitoring(for: coconutRegion)
        locationManager.startRangingBeacons(in: coconutRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons:[CLBeacon], in region: CLBeaconRegion) {
        if region.identifier == "mintBeacon" {
            if beacons.count > 0 {
                let rssi_mint = beacons[0].rssi
                print ("rssi of mint")
                print (rssi_mint)
                print (beacons)
                if rssi_mint >= -71 {
                    locationLabel.text = "mint beacon connected"
                    let a = defaults.string(forKey: "mint") //check defalut value
                    if ismintPlaying == false && isPlaying == false && a == nil && iscoconutPlaying == false {
                        print ("a is null")
                        ismintHidden = false
                        iscoconutHidden = true
                        resumeButton.isHidden = false //show button
                        stopButton.isHidden = false //show button
                        replayButton.isHidden = false //show button
                        player_mint.play() //play mint audio
                        isPlaying = true //tell the button now is playing audio
                        ismintPlaying = true //mint beacon is playing aduio
                        defaults.set("mint", forKey: "mint") //set defalut value to store the record
                    } else if ismintPlaying == false && isPlaying == false && iscoconutPlaying == false{
                        print ("a is not null")
                        ismintHidden = false
                        iscoconutHidden = true
                        ismintPlaying = true //mint beacon is playing audio
                        isPlaying = true //tell the button now is playing audio
                        resumeButton.isHidden = false //show button
                        stopButton.isHidden = false //show button
                        replayButton.isHidden = false //show button
                        player_mint.play() //play mint audio
                        ismintPlaying = true //mitn beacon is playing audio
                    } else if ismintPlaying == false && isPlaying == false && ismintHidden == true {
                        //this action when beacon is far then come back near the beacon
                        iscoconutHidden = true
                        player_mint.play() //play mint audio
                        ismintPlaying = true //mint beacon is playing audio
                        isPlaying = true //tell the button now is playing audio
                        ismintHidden = false //mint beacon is in range
                        resumeButton.isHidden = false //show button
                        stopButton.isHidden = false //show button
                        replayButton.isHidden = false //show button
                    } else if iscoconutPlaying == true {
                        //if playing coconut beacon audio
                        player_coconut.stop() //coconut audio should stop playing
                        iscoconutPlaying = false
                        locationLabel.text = "Multiple beacon was detected!"
                    }
                } else {
                    if iscoconutPlaying == true {
                        
                    } else if ismintHidden == true && iscoconutHidden == true {
                        locationLabel.text = "Please move near to beacon"
                    } else {
                        //this action when smartphone not in specific range
                        print ("enter mint false")
                        player_mint.stop() //stop player
                        ismintPlaying = false //mint beacon is stop playing
                        isPlaying = false //tell the button now is not playing audio
                        ismintHidden = true //mint beacon is not in range
                        resumeButton.isHidden = true //hide button
                        stopButton.isHidden = true //hide button
                        replayButton.isHidden = true //hide button
                    }
                }
            }
        } else if region.identifier == "coconutBeacon" {
            if beacons.count > 0 {
                let rssi_coconut = beacons[0].rssi
                //print ("rssi of coconut")
                //print (rssi_coconut)
                if rssi_coconut >= -71 {
                    locationLabel.text = "coconut beacon connected"
                    let b = defaults.string(forKey: "coconut")
                    if iscoconutPlaying == false && isPlaying == false && b == nil && ismintPlaying == false{
                        print ("b is null")
                        iscoconutHidden = false
                        ismintHidden = true
                        resumeButton.isHidden = false
                        stopButton.isHidden = false
                        replayButton.isHidden = false
                        player_coconut.play()
                        iscoconutPlaying = true
                        defaults.set("coconut", forKey: "coconut")
                    } else if iscoconutPlaying == false && isPlaying == false && ismintPlaying == false {
                        print ("b is not null")
                        iscoconutHidden = false
                        ismintHidden = true
                        resumeButton.isHidden = false
                        stopButton.isHidden = false
                        replayButton.isHidden = false
                        player_coconut.play()
                        iscoconutPlaying = true
                        isPlaying = true
                    } else if iscoconutPlaying == false && isPlaying == false && iscoconutHidden == true {
                        //this action when beacon is far then come back near the beacon
                        ismintHidden = true
                        player_coconut.play() //play coconut audio
                        iscoconutPlaying = true //coconut beacon is playing audio
                        isPlaying = true //tell the button now is playing audio
                        iscoconutHidden = false //coconut beacon is in range
                        resumeButton.isHidden = false //show button
                        stopButton.isHidden = false //show button
                        replayButton.isHidden = false //show button
                    } else if ismintPlaying == true {
                        //if playing mint audio
                        player_mint.stop()
                        ismintPlaying = false
                        locationLabel.text = "Multiple beacon was detected!"
                    }
                } else {
                    if ismintPlaying == true {
                        
                    } else if ismintHidden == true && iscoconutHidden == true {
                        locationLabel.text = "Please move near to beacon"
                    } else {
                        print ("enter coconut false")
                        player_coconut.stop()
                        iscoconutPlaying = false
                        isPlaying = false
                        iscoconutHidden = true
                        resumeButton.isHidden = true
                        stopButton.isHidden = true
                        replayButton.isHidden = true
                    }
                }
            }
        }
    }
    
    func updateDistance(_ distance: CLProximity) {
        UIView.animate(withDuration: 0.8) {
            switch distance {
            case .unknown:
                print("unknow")
                
            case .far:
                print("far")
                
            case .near:
                print("near")
                
            case .immediate:
                print("immediate")
            }
        }
    }

}

