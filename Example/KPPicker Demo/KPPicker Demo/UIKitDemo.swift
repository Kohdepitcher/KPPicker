//
//  UIKitDemo.swift
//  KPPicker Demo
//
//  Created by Kohde Pitcher on 19/3/2022.
//

import Foundation
import SwiftUI
import UIKit
import KPPicker

class UIKitDemoViewController: UIViewController, KPPickerViewDataSource, KPPickerViewDelegate {
    
    let options = ["Skin", "Hairstyle", "Brows", "Eyes" , "Head", "Nose", "Mouth", "Ears", "Facial Hair", "Eyewear", "Headgear", "Clothing" ]
    var picker: KPPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.picker = KPPickerView()
        
        //set the delegate for the picker
        self.picker.delegate = self
        self.picker.dataSource = self

        //configure the picker
        self.picker.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        self.picker.textColor = .secondaryLabel
        self.picker.selectedTextColor = .systemBlue
        self.picker.maskEnabled = true
        self.picker.itemSpacing = 40
        self.picker.shouldDeselectWhenOutsideTreshold = false

        self.picker.reloadData()
        
        self.picker.translatesAutoresizingMaskIntoConstraints = false
        
        //add picker to the view hierachy
        self.view.addSubview(self.picker)
        
        //setup constraints
        NSLayoutConstraint.activate([
            
            self.picker.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.picker.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.picker.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.picker.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

        ])
    }
    
    //Picker Data Source
    func numberOfItems(_ pickerView: KPPickerView) -> Int {
        return options.count
    }
    
    func pickerView(_ pickerView: KPPickerView, textForItem item: Int) -> String {
        return options[item]
    }
    
}

struct UIKitDemoViewControllerRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return UIKitDemoViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
}

struct UIKitDemoView: View {
    
    var body: some View {
        UIKitDemoViewControllerRepresentable()
    }
    
}
