//
//  ViewController.swift
//  Multithreading-GCD4
//
//  Created by ruslan on 02.11.2021.
//

import UIKit

final class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    private let queue = DispatchQueue.global(qos: .utility)
    private var currentWorkItem: DispatchWorkItem?
    private let imageURLs: [URL] = [
        URL(string: "https://images.unsplash.com/photo-1635813782590-0f5d34934b9d?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1287&q=80")!,
        URL(string: "https://images.unsplash.com/photo-1635372886281-4487e1e00904?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=2274&q=80")!
    ]
    private var timer = Timer()
    private var timerCount = 3 {
        didSet {
            label.text = "You can cancel the downloading\n next image within \(timerCount) seconds"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.isHidden = true
        label.numberOfLines = 0
        label.text = "You can cancel the downloading\n next image within \(timerCount) seconds"
        downloadButton.layer.cornerRadius = 15
        cancelButton.layer.cornerRadius = 15
        cancelButton.isEnabled = false
    }
    
    // generating a work item with URL which downloading an image
    private func generateWorkItem(with URL: URL, completionHandler: (() -> Void)? = nil) -> DispatchWorkItem {
        var data: Data?
        let workItem = DispatchWorkItem(qos: .userInteractive) {
            data = try? Data(contentsOf: URL)
        }
        
        workItem.notify(queue: DispatchQueue.main) { [unowned self] in
            if let imageData = data {
                self.imageView.image = UIImage(data: imageData)
            }
            if let handler = completionHandler {
                handler()
            }
        }

        return workItem
    }
    
    // setting up a queue with a work item
    private func setUpQueue(after: Double = 0, workItem: DispatchWorkItem) {
        currentWorkItem = workItem
        queue.asyncAfter(deadline: .now() + after, execute: currentWorkItem!)
    }
    
    // setting up the timer
    private func setUpTimer() {
        label.isHidden = false
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [unowned self] timer in
            print(timerCount)
            timerCount -= 1
            guard timerCount == 0 else { return }
            resetTimer()
        })
    }
    
    // reseting the timer
    private func resetTimer() {
        timer.invalidate()
        timerCount = 3
        label.isHidden = true
        cancelButton.isEnabled = false
    }
    
    // downloading the images in a row with a delay
    @IBAction func downloadButtonAction(_ sender: UIButton) {
        imageView.image = nil
        downloadButton.isEnabled = false
                
        setUpQueue(workItem: generateWorkItem(with: imageURLs[0], completionHandler: { [unowned self] in
            self.cancelButton.isEnabled = true
            self.setUpTimer()
            self.setUpQueue(after: Double(timerCount), workItem: self.generateWorkItem(with: self.imageURLs[1], completionHandler: { [unowned self] in
                self.downloadButton.isEnabled = true
            }))
        }))
    }
    
    // cancelling a work item
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        guard let workItem = currentWorkItem else { return }
        workItem.cancel()
        resetTimer()
    }
}

