//
//  ViewController.swift
//  Arcanoid
//
//  Created by Захар Князев on 29.12.2021.
//

//добавить завершение игры когда выбили все блоки с помощью alert или notification
//добавить проигрыш когда коснулись нижней грани

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
        
        //закругляем края ракетки и красим ее в оранжевый цвет
        viewRocket.layer.cornerRadius = 5
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
    
    struct Game {
        var center: CGPoint
        var vector: Vector
        
        var viewBall: UIView
        var viewParent: UIView
        
        var viewRocket: UIView
        
        //массив блоков
        var viewBlocks: [UIView] = []
        
        
        //создаем шарик в parentView
        init(in viewParent: UIView, viewRocket: UIView) {
            self.viewParent = viewParent
            self.viewRocket = viewRocket
            
            center = viewParent.center
            vector = Vector(a: CGPoint(x: 0, y: 0), b: CGPoint(x: 5, y: 5))
            viewBall = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            
            //закругляем края шарика и красим его в красный цвет
            viewBall.layer.cornerRadius = 5
            viewBall.backgroundColor = UIColor.red
            viewBall.center = center
            viewParent.addSubview(viewBall)
            
            //генерируем блоки
            for _ in 0...20 {
                //0...viewParent.frame.size.width распределяем блоки по всей ширине экрана
                let block = UIView(frame: CGRect(x: CGFloat.random(in: 0...viewParent.frame.size.width), y: CGFloat.random(in: 0...400), width: 100, height: 33))
                
                //закругляем края блока и красим его в зеленый цвет, добавляем цвет обводки
                block.layer.cornerRadius = 7
                block.layer.borderColor = UIColor.gray.cgColor
                block.layer.borderWidth = 1
                block.backgroundColor = UIColor.green
                viewParent.addSubview(block)
                viewBlocks.append(block)
            }
            
            
        }
        
        //функция определяет, где в следующий момент окажется шарик
        mutating func tic() {
            let newCenter = CGPoint(x: center.x + vector.dx, y: center.y + vector.dy)
           
            if isHit(oldPosition: center, newPosition: newCenter, rect: viewRocket.frame) == .x {
                vector.b.x = -vector.b.x
                vector.b.y = vector.b.y + CGFloat.random(in: -3...3)
            }
            
            if isHit(oldPosition: center, newPosition: newCenter, rect: viewRocket.frame) == .y {
                vector.b.y = -vector.b.y
                vector.b.x = vector.b.x + CGFloat.random(in: -3...3)
            }
            
            //определяем встретился ли шарик с блоком и выбиваем блок
            var indexBlock: Int?
            for (index, block) in viewBlocks.enumerated() {
                if isHit(oldPosition: center, newPosition: newCenter, rect: block.frame) == .x {
                    vector.b.x = -vector.b.x
                    vector.b.y = vector.b.y + CGFloat.random(in: -3...3)
                    indexBlock = index
                }
                
                if isHit(oldPosition: center, newPosition: newCenter, rect: block.frame) == .y {
                    vector.b.y = -vector.b.y
                    vector.b.x = vector.b.x + CGFloat.random(in: -3...3)
                    indexBlock = index
                }
            }
            
            //выбиваем блоки
            if let indexBlock = indexBlock {
                let block = viewBlocks[indexBlock]
                UIView.animate(withDuration: 0.2, animations: {
                    block.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                }) { (bool) in
                    block.removeFromSuperview()
                }

                viewBlocks.remove(at: indexBlock)
            }
            //когда все блоки выбиты нужно завершать игру!!! например alertView
                        
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
        
        enum HitTarget {
            case x
            case y
        }
        
        //определяет было ли касание ракетки и шарика и с какой стороны(верхней или боковой), HitTarget? опционально, если касания не было
        func isHit(oldPosition: CGPoint, newPosition: CGPoint, rect: CGRect) -> HitTarget? {
            
            //столкновение шарика с ракеткой
            //левая боковая грань
            if oldPosition.x < rect.origin.x &&
            newPosition.x >= rect.origin.x &&
            newPosition.y >= rect.origin.y &&
            newPosition.y <= rect.origin.y + rect.size.height {
                return .x
            }
            
            //правая боковая грань
            if oldPosition.x > rect.origin.x + rect.size.width &&
            newPosition.x <= rect.origin.x + rect.size.width &&
            newPosition.y >= rect.origin.y &&
            newPosition.y <= rect.origin.y + rect.size.height {
                return .x
            }
            
            //верхняя грань
            if oldPosition.y < rect.origin.y &&
            newPosition.y >= rect.origin.y &&
            newPosition.x >= rect.origin.x &&
            newPosition.x <= rect.origin.x + rect.size.width {
                return .y
            }
            
            //нижняя грань
            if oldPosition.y > rect.origin.y + rect.size.height &&
            newPosition.y <= rect.origin.y + rect.size.height &&
            newPosition.x >= rect.origin.x &&
            newPosition.x <= rect.origin.x + rect.size.width {
                return .y
            }
            
            //HitTarget? опционально, если касания не было
            return nil
            
        }
        
    }
    
    var game: Game!
    func addBall() {
        game = Game(in: self.view, viewRocket: viewRocket)
    }
    
    func start() {
        //100 фпс
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (timer) in
            self.game.tic()
        }
    }
    
}

