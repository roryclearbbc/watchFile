//
//  InterfaceController.swift
//  watchFile WatchKit Extension
//
//  Created by Rory Clear on 19/08/2021.
//

import WatchKit
import Foundation
import WatchConnectivity
import AVKit

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var label: WKInterfaceLabel!
    @IBOutlet weak var moviePlayer: WKInterfaceMovie!
    let session = WCSession.default
    
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        super.awake(withContext: context)
        
        // Configure interface objects here.
        session.delegate = self//**4
        session.activate()//**5
    }
    
    override func willActivate() {
        super.willActivate()
        // This method is called when watch view controller is about to be visible to user
        print("roryclear willActivate??")
    //    let movie = Bundle.main.url(forResource: "fred", withExtension: "mp4")!
    //    self.moviePlayer.setMovieURL(movie)
        
        
        //delete original file???
        //delete original file??
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
        
        
        //download mp4
        /*
        let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
        let destinationFileUrl = documentsUrl.appendingPathComponent("file.mp4")
        
        //Create URL to the source file you want to download
        let fileURL = URL(string: "https://filesamples.com/samples/video/mp4/sample_640x360.mp4") //beach

        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)

        let request = URLRequest(url:fileURL!)

        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                    self.moviePlayer.setMovieURL(destinationFileUrl)
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
        }
        task.resume()
        */
        
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        // This method is called when watch view controller is no longer visible
    }

}

extension InterfaceController: WCSessionDelegate {
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    
    print("received data: \(message)")
    if let value = message["iPhone"] as? String {//**7.1
        self.label.setText(value)
    }else{//not a stirng?
        let path = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)[0].appendingPathComponent("myFile.mp4")
        var videoData: Data
        videoData = message["iPhone"] as! Data
        
        try? videoData.write(to: path)
        print("roryclear done? (watch)")
        
    }
  }
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("roryclear....file receive started")
        self.moviePlayer.setMovieURL(file.fileURL)
        print("roryclear...FILE RECEIVED")
        
        do {
            let receivedData = try Data(contentsOf: file.fileURL)
            
            let path = FileManager.default.urls(for: .documentDirectory,
                                                    in: .userDomainMask)[0].appendingPathComponent("receivedFileFromiPhone.mp4")
            try? receivedData.write(to: path)
            print("roryclear data received count -> \(receivedData.count)")
            
            self.moviePlayer.setMovieURL(path)
                
            let textReceived = file.metadata!["iPhone"] as! String
            self.label.setText(textReceived)
                
        } catch {
            print("error reading file -> \(error)")
        }
    }
    
}
