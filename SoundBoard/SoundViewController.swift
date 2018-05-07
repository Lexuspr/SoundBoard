//
//  SoundViewController.swift
//  SoundBoard
//
//  Created by MAC10 on 7/05/18.
//  Copyright © 2018 tecsup. All rights reserved.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    @IBOutlet weak var lblDuracion: UILabel!
    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var addButton: UIButton!
    
    var audioRecorder:AVAudioRecorder?
    var audioPlayer:AVAudioPlayer?
    var audioURL:URL?
    
    var timer = Timer()
    var segundos = 0
    var isTimerRunning = false
    var tempo = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecorder()
        playButton.isEnabled = false
        addButton.isEnabled = false
        // Do any additional setup after loading the view.
    }
    
    func setupRecorder(){
        do{
            //creando sesion de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            //creando direccion para el archivo de audio
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            print("**********************")
            print(audioURL!)
            print("**********************")
            
            //crear opciones para el grabador de audio
            var settings:[String:AnyObject] = [ : ]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            //crear el objeto de grabacion de audio
            audioRecorder = try AVAudioRecorder(url: audioURL!, settings: settings)
            audioRecorder!.prepareToRecord()
        } catch let error as NSError {
            print(error)
        }
    }
    
    func runTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(SoundViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    func updateTimer() {
        segundos += 1
        lblDuracion.text = timeString(time: TimeInterval(segundos))
    }
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }

    @IBAction func recordTapped(_ sender: UIButton) {
        if audioRecorder!.isRecording{
            //detener la grabacion
            audioRecorder?.stop()
            //cambiar texto del boton grabar
            recordButton.setTitle("Grabar", for: .normal)
            playButton.isEnabled = true
            addButton.isEnabled = true
            timer.invalidate()
            tempo = String(segundos)
        } else {
            //empezar a grabar
            segundos = 0
            lblDuracion.text = timeString(time: TimeInterval(segundos))
            audioRecorder?.record()
            //cambiar texto del boton grabar a detener
            recordButton.setTitle("Detener", for: .normal)
            playButton.isEnabled = false
            runTimer()
        }
    }
    @IBAction func playTapped(_ sender: UIButton) {
        do {
                try audioPlayer = AVAudioPlayer(contentsOf: audioURL!)
                audioPlayer!.play()
        } catch {}
    }
    @IBAction func addTapped(_ sender: UIButton) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let sound = Sound(context: context)
        sound.name = nameTextField.text
        sound.audio = NSData(contentsOf: audioURL!)
        sound.tempo = tempo
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
