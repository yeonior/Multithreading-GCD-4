//
//  ViewController.swift
//  Multithreading-GCD4
//
//  Created by ruslan on 02.11.2021.
//

import UIKit

final class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button: UIButton!
    
    private let imageURL: URL = URL(string: "https://images.unsplash.com/photo-1635813782590-0f5d34934b9d?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=1287&q=80")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.layer.cornerRadius = 15
    }
    
    private func setUpQueue() {
        var data: Data?
        let queue = DispatchQueue.global(qos: .utility)
        let workItem = DispatchWorkItem(qos: .userInteractive) {
            data = try? Data(contentsOf: self.imageURL)
        }
        
        queue.async(execute: workItem)
        
        workItem.notify(queue: DispatchQueue.main) {
            if let imageData = data {
                self.imageView.image = UIImage(data: imageData)
            }
        }
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        imageView.image = nil
        setUpQueue()
    }
}

