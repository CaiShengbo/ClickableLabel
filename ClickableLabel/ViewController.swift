//
//  ViewController.swift
//  ClickableLabel
//
//  Created by caishengbo on 2023/12/19.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let v = TRClickableLabel()
        v.numberOfLines = 0
        v.backgroundColor = .red
        view.addSubview(v)
        v.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        v.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        v.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        v.heightAnchor.constraint(equalToConstant: 400).isActive = true
        
        let style = NSMutableParagraphStyle()
        style.alignment = .right
        
        let attr = NSMutableAttributedString(
            string: "计算的咖啡机啊时间的六块腹肌阿克索德积分卡上的积分卡家；收到了饭撒的积分卡拉屎的",
            attributes: [
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor.gray,
                .paragraphStyle: style
            ]
        )
        
        let action: TRClickableLabelActionCallback = {[weak self] (l) in
            guard let self = self else { return }
            self.action1()
        }
        
        attr.append(
            NSAttributedString(
                string: "sd",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 13),
                    .foregroundColor: UIColor.green,
                    .action: action,
                    .paragraphStyle: style
                ]
            )
        )
        
        attr.append(
            NSAttributedString(
                string: "sdfasdfasdfasdf",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 13),
                    .foregroundColor: UIColor.gray,
                    .paragraphStyle: style
                ]
            )
        )
        
        
        let action2: TRClickableLabelActionCallback = {[weak self] (l) in
            guard let self = self else { return }
            self.action2()
        }
        
        attr.append(
            NSAttributedString(
                string: "AB",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 13),
                    .foregroundColor: UIColor.green,
                    .action: action2,
                    .paragraphStyle: style
                ]
            )
        )
        
        v.attributedText = attr
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        v.addGestureRecognizer(tap)
    }
    
    private func action1() {
        print("action 1")
    }
    
    private func action2() {
        print("action 2")
    }
    
    @objc private func tap() {
        print("tap label")
    }
}

