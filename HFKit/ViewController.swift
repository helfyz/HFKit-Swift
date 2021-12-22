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
      
                               
       
    }
}
