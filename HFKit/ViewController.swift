//
//  ViewController.swift
//  HFKit
//
//  Created by helfy on 2021/12/20.
//
import UIKit

class ViewController: UIViewController {
   lazy var linkageViewController:LinkageViewController = {
       let viewController = LinkageViewController()
//       viewController.fullScreen = true
       return viewController
    }()
    
   override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
      
       view.addSubview(linkageViewController.view)
       addChild(linkageViewController)
       NSLayoutConstraint.activate([
            linkageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            linkageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            linkageViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            linkageViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor)
       ]);
    
       let arr = [
        LinkageModel(title: "测试2", viewController: TestCollectionViewController()),
        LinkageModel(title: "测试1", viewController: TestTableViewController()),
                ]
       linkageViewController.setupModels(models: arr, selected: 0)
       
       let headView = UIView(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
       headView.backgroundColor = .red
       linkageViewController.setupPageHeader(header: headView, heigth: 100)
                               
//       let url = "https://mvvideo5.meitudata.com/56ea0e90d6cb2653.mp4"
//       let session: URLSession = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
//       var request = URLRequest(url: URL(string: url)!)
//       request.cachePolicy = .reloadIgnoringLocalCacheData
//       request.setValue("bytes=\(1)-\(1000)", forHTTPHeaderField: "Range")
//       let task = session.dataTask(with: request) { data, response, error in
//          print("response")
//       }
//       task.resume()
    }
}
