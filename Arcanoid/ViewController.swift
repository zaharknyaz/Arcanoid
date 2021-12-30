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
        addBall()
        start()
    }
    
    var viewRocket: UIView!
    func addRocket() {
        //создаем view(ракетку) программно
        viewRocket = UIView(frame: CGRect(x: 30, y: UIScreen.main.bounds.size.height - 100, width: 150, height: 30))
        viewRocket.backgroundColor = UIColor.orange
        //добавим ракетку на основную view
        view.addSubview(viewRocket)
        
        //добавляем жест касания к рокетке
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
    
    struct Vector {
        var a: CGPoint
        var b: CGPoint
        var dx: CGFloat {
            return b.x - a.x
        }
        var dy: CGFloat {
            return b.y - a.y
        }
    }
    
    struct Ball {
        var center: CGPoint
        var vector: Vector
        
        var viewBall: UIView
        var viewParent: UIView
        
        var viewRocket: UIView
        
        //создаем шарик в parentView
        init(in viewParent: UIView, viewRocket: UIView) {
            self.viewParent = viewParent
            self.viewRocket = viewRocket
            
            center = viewParent.center
            vector = Vector(a: CGPoint(x: 0, y: 0), b: CGPoint(x: 5, y: 5))
            viewBall = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            viewBall.backgroundColor = UIColor.red
            viewBall.center = center
            viewParent.addSubview(viewBall)
        }
        
        //функция определяет, где в следующий момент окажется шарик
        mutating func tic() {
            let newCenter = CGPoint(x: center.x + vector.dx, y: center.y + vector.dy)
           
            //столкновение шарика с ракеткой
            //левая боковая грань
            if center.x < viewRocket.frame.origin.x &&
            newCenter.x >= viewRocket.frame.origin.x &&
            newCenter.y >= viewRocket.frame.origin.y &&
            newCenter.y <= viewRocket.frame.origin.y + viewRocket.frame.size.height {
                vector.b.x = -vector.b.x
            }
            
            //правая боковая грань
            if center.x > viewRocket.frame.origin.x + viewRocket.frame.size.width &&
            newCenter.x <= viewRocket.frame.origin.x + viewRocket.frame.size.width &&
            newCenter.y >= viewRocket.frame.origin.y &&
            newCenter.y <= viewRocket.frame.origin.y + viewRocket.frame.size.height {
                vector.b.x = -vector.b.x
            }
            
            //верхняя грань
            if center.y < viewRocket.frame.origin.y &&
            newCenter.y >= viewRocket.frame.origin.y &&
            newCenter.x >= viewRocket.frame.origin.x &&
            newCenter.x <= viewRocket.frame.origin.x + viewRocket.frame.size.width {
                vector.b.y = -vector.b.y
            }
            
            //нижняя грань
            if center.y > viewRocket.frame.origin.y + viewRocket.frame.size.height &&
            newCenter.y <= viewRocket.frame.origin.y + viewRocket.frame.size.height &&
            newCenter.x >= viewRocket.frame.origin.x &&
            newCenter.x <= viewRocket.frame.origin.x + viewRocket.frame.size.width {
                vector.b.y = -vector.b.y
            }
            
            center = newCenter
            viewBall.center = newCenter
            
            //определяем когда шарик вышел за границы экрана(за левый край) - ограничиваем по ширине x
            if newCenter.x >= viewParent.frame.size.width || newCenter.x <= 0 {
                vector.b.x = -vector.b.x
            }
            
            //ограничиваем по высоте y
            if newCenter.y >= viewParent.frame.size.height || newCenter.y <= 0 {
                vector.b.y = -vector.b.y
            }
        }
    }
    
    var ball: Ball!
    func addBall() {
        ball = Ball(in: self.view, viewRocket: viewRocket)
    }
    
    func start() {
        //100 фпс
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (timer) in
            self.ball.tic()
        }
    }
    
}

