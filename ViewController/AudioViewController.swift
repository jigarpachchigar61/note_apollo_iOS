//
//  AudioViewController.swift
//  note_apollo_iOS
//
//  Created by Nency on 31/01/21.
//

import UIKit
import AVFoundation

class AudioViewController: UIViewController {
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var timer = Timer()
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playbackButton: UIButton!
    @IBOutlet weak var txtTimer: UITextField!
    @IBOutlet weak var seekBar: UISlider!
    
    var fileName: String!
    var newRecord: Bool = true
    var noteVC: apolloNoteVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initRecord()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareBackgroundView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            let frame = self?.view.frame
            let yComponent = UIScreen.main.bounds.height - 250
            self?.view.frame = CGRect(x: 0, y: yComponent, width: frame!.width, height: frame!.height)
        }
    }
    
    func prepareBackgroundView(){
        let blurEffect = UIBlurEffect.init(style: .light)
        let visualEffect = UIVisualEffectView.init(effect: blurEffect)
        let bluredView = UIVisualEffectView.init(effect: blurEffect)
        bluredView.contentView.addSubview(visualEffect)
        
        visualEffect.frame = UIScreen.main.bounds
        bluredView.frame = UIScreen.main.bounds
        
        view.insertSubview(bluredView, at: 0)
    }
    
    @IBAction func btnRecordClicked(_ sender: Any) {
        recordTapped()
    }
    
    @IBAction func btnPlaybackClicked(_ sender: Any) {
        playBackTapped()
    }
    
    func audioRecorded(){
        noteVC.noteAudioFileName = fileName
    }
    
    @IBAction func closeClicked(_ sender: Any) {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    override func viewWillDisappear(_ animated: Bool) {
        noteVC?.bottomSheetClose()
    }
}

extension AudioViewController: AVAudioRecorderDelegate{
    
    func initRecord(){
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try self.recordingSession.setCategory(.playAndRecord, mode: .default)
            try self.recordingSession.setActive(true)
            self.recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        recordProblem()
                    }
                }
            }
        } catch {
            recordProblem()
        }
    }
    
    func loadRecordingUI(){
        seekBar.isHidden = false
        playbackButton.isHidden = true
        seekBar.isHidden = true
        if !newRecord {
            recordButton.setTitle("Tap to Record", for: .normal)
            initPlayback()
        }
    }
    
    func recordProblem(){
        playbackButton.isHidden = true
        seekBar.isHidden = true
        let alert = UIAlertController(title: "Error", message: "Something went wrong with recording controller. Please try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { _ in }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func recordTapped() {
        if audioRecorder == nil {
            startRecording()
            playbackButton.isHidden = true
            seekBar.isHidden = true
        } else {
            finishRecording(success: true)
        }
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(fileName + ".m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            audioRecorded()
            recordButton.setTitle("Tap to Re-record", for: .normal)
            initPlayback()
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            recordProblem()
        }
    }
    
    func initPlayback(){
        let audioFilename = getDocumentsDirectory().appendingPathComponent(fileName + ".m4a")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            playbackButton.setTitle("Play Record", for:.normal)
            playbackButton.isHidden = false
            seekBar.isHidden = false
            seekBar.maximumValue = Float(audioPlayer.duration)
        } catch {
            playbackProblem()
        }
    }
    
    func playBackTapped() {
        if !audioPlayer.isPlaying{
            playbackButton.setTitle("Pause", for:.normal)
            audioPlayer.play()
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateScrubber), userInfo: nil, repeats:true)
            recordButton.isHidden = true
        } else {
            playbackButton.setTitle("Play Record", for:.normal)
            audioPlayer.pause()
            timer.invalidate()
            recordButton.isHidden = false
        }
    }
    
    // update scrubber based on player current time
    @objc func updateScrubber() {
        seekBar.value = Float(audioPlayer.currentTime)
        if seekBar.value == seekBar.minimumValue {
            playbackButton.setTitle("Play Record", for:.normal)
            recordButton.isHidden = false
        }
    }
    
    @IBAction func scrubberMoved(_ sender: UISlider) {
        audioPlayer.currentTime = TimeInterval(seekBar.value)
    }
    
    func playbackProblem(){
        let alert = UIAlertController(title: "Error", message: "Something went wrong with playback controller. Please try record again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { _ in }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
}
