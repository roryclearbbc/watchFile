//
//  ViewController.swift
//  watchFile
//
//  Created by Rory Clear on 19/08/2021.
//

import UIKit
import WatchConnectivity
import mobileffmpeg

class ViewController: UIViewController {
    
    @IBOutlet weak var percentLabel: UILabel!
    var session: WCSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.configureWatchKitSesstion()
    }

    func configureWatchKitSesstion() {
      print("roryclear configureWatchKitSesstion ??")
      if WCSession.isSupported() {//4.1
        session = WCSession.default//4.2
        session?.delegate = self//4.3
        session?.activate()//4.4
      }
    }
    
    func deleteAllMp4s(){
        let documentsUrl0 =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl0,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                if fileURL.pathExtension == "mp4" {
                    try FileManager.default.removeItem(at: fileURL)
                }
            }
        } catch  { print(error) }
        
    }
    
    func ffmpegDownload(){
        let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
        let destinationFileUrl = documentsUrl.appendingPathComponent("ffmpegFile.mp4")
        let stringPath = "\(destinationFileUrl)"
        
        var command = "-i https://vod-hls-uk.live.cf.md.bbci.co.uk/usp/auth/vod/piff_abr_full_hd/99f2f2-p09tv3z0/vf_p09tv3z0_8e28d952-3729-4f5b-b383-f42e1bd65b3f.ism/vf_p09tv3z0_8e28d952-3729-4f5b-b383-f42e1bd65b3f-audio_eng=96000-video=827000.m3u8 -bsf:a aac_adtstoasc -vcodec copy -c copy -y -crf 50 "
        
        command = command + stringPath
        
        // Do any additional setup after loading the view.
        //let a = MobileFFmpeg.execute("-i https://b1-mcsqb-bbc.live.bidi.net.uk/vod-hls-uk/usp/auth/vod/piff_abr_full_hd/3bfc98-m000ywfg/vf_m000ywfg_f6ade506-8219-470f-97d5-adcbabf8bc9f.ism/vf_m000ywfg_f6ade506-8219-470f-97d5-adcbabf8bc9f-audio_eng=48000-video=281000.m3u8 -bsf:a aac_adtstoasc -vcodec copy -c copy -crf 50 output.mp4")
        
        let a = MobileFFmpeg.execute(command)
        
        //check file size???
        
        var fileSize : UInt64

        do {
            //return [FileAttributeKey : Any]
            let attr = try FileManager.default.attributesOfItem(atPath: stringPath)
            fileSize = attr[FileAttributeKey.size] as! UInt64

            //if you convert to NSDictionary, you can get file size old way as well.
            let dict = attr as NSDictionary
            fileSize = dict.fileSize()
            print("roryclear file size = ",fileSize)
        } catch {
            print("Error: \(error)")
        }
    }
    
    
    @IBAction func tapSendDataToWatch(_ sender: Any) {
        print("roryclear send2watch?")
    
        
        //delete original file??
        deleteAllMp4s()
        
        //download mp4
        let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
        let destinationFileUrl = documentsUrl.appendingPathComponent("iPhoneFile.mp4")
        
        //Create URL to the source file you want to download
        let fileURL = URL(string: "https://file-examples-com.github.io/uploads/2017/04/file_example_MP4_480_1_5MG.mp4")

        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)

        let request = URLRequest(url:fileURL!)

        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                  // poster?
                }

                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                } catch (let writeError) {
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                }

            } else {
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription);
            }
            
            if let validSession = self.session, validSession.isReachable {//5.1
                print("roryclear validSession?")
             // let data: [String: Any] = ["iPhone": "Data from iPhone" as Any] // Create your Dictionay as per uses
             //   NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"filename.mp4"];
                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                let documentsDirectory = paths[0]
                let path: String = "\(documentsDirectory)iPhoneFile.mp4"
                let pathURL = URL(string: path)
                
                do {
             //       let data: [String: Any] = ["iPhone": try Data.init(contentsOf: URL(string: path)!)] //video data...too large (> 65KB)
                    
             //       let data: [String: Any] = ["iPhone": "hello rory \(Int.random(in: 1..<10000))"]
             //       print("roryclear data size = \(data.count)")
             //       validSession.sendMessage(data, replyHandler: nil, errorHandler: nil)
                    
                    
                    //transfer file not data???
                    print("roryclear file transfer started")
                    validSession.transferFile(pathURL!, metadata: ["iPhone":"hello rory \(Int.random(in: 1..<10000))"])
                    var progress: Int64 = -1
                    if(self.session?.outstandingFileTransfers != nil)
                    {
                        while (self.session?.outstandingFileTransfers.count)! > 0 && (self.session?.outstandingFileTransfers[0].progress.completedUnitCount)! < 100 {
                            if(self.session?.outstandingFileTransfers[0].progress.completedUnitCount != progress)
                            {
                                print("roryclear trasfer prog? -> \(self.session!.outstandingFileTransfers[0].progress.completedUnitCount)%")
                                DispatchQueue.main.async {
                                self.percentLabel.text = "\(self.session!.outstandingFileTransfers[0].progress.completedUnitCount)%"
                                }
                                progress = (self.session?.outstandingFileTransfers[0].progress.completedUnitCount)!
                            }
                        
                    }
                    }
                    
                    DispatchQueue.main.async {
                    self.percentLabel.text = "100%"
                    }
                    
                    print("roryclear file transfered?")
                    
                } catch {
                    print(error)
                }
            }else{
                print("roryclear NO VALID SESSION")
            }
            
        }
        task.resume()
    }
    
}

extension ViewController: WCSessionDelegate {
  
  func sessionDidBecomeInactive(_ session: WCSession) {
  }
  
  func sessionDidDeactivate(_ session: WCSession) {
  }
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    print("roryclear received message: \(message)")
    DispatchQueue.main.async { //6
      if let value = message["watch"] as? String {
//        self.label.text = value
      }
    }
  }
}

