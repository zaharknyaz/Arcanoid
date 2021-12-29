//
//  ViewController.swift
//  Arcanoid
//
//  Created by Захар Князев on 29.12.2021.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        addRocket()
    }
    
    var viewRocket: UIView!
    func addRocket() {
        //создаем view(ракетку) программно
        viewRocket = UIView(frame: CGRect(x: 30, y: UIScreen.main.bounds.size.height - 100, width: 150, height: 30))
        viewRocket.backgroundColor = UIColor.orange
        //добавим ракетку на основную view
        view.addSubview(viewRocket)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.pan))
        viewRocket.gestureRecognizers = [pan]
    }

    var centerRocket: CGPoint!
    @objc
    func pan(pgr: UIPanGestureRecognizer) {
        if pgr.state == .began {
            centerRocket = viewRocket.center
        }
        let x = pgr.translation(in: view).x
        let newCenter = CGPoint(x: centerRocket.x + x, y: centerRocket.y)
        viewRocket.center = newCenter
    }
}

