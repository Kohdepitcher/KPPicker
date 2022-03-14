//  The MIT License (MIT)
//
//  Copyright (c) 2022 Kohde Pitcher
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

//
//  PickerCollectionViewCell.swift
//  KPPickerView
//
//  Created by Kohde Pitcher on 22/2/2022.
//

/*
 *  The purpose of this class is to define the collection view cells that are used within the picker
 *  For now the built in cell only supports text
 */

import Foundation
import UIKit

public class PickerCollectionViewCell: UICollectionViewCell {
    
    //Label displayed in the cell
    var label: UILabel!
    
    //Colors for the text and selection color
    var selectedTint: UIColor!
    var textColor: UIColor!
    
    //Perform logic when the cell "isSelected"
    public override var isSelected: Bool {
        didSet {
            
            if (isSelected) {
        
//                UIView.transition(with: self.label, duration: 0.1, options: .transitionCrossDissolve) {
                    self.label.textColor = self.selectedTint
//                }
                
            } else {
//                UIView.transition(with: self.label, duration: 0.1, options: .transitionCrossDissolve) {
                    self.label.textColor = self.textColor
//                }
            }
            
        }
    }
    
    //Shared initialiser for setting up the cell
    func sharedInitialise() {
        
        //setup layer
        self.layer.isDoubleSided = false
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        //setup label
        self.label = UILabel(frame: self.contentView.bounds)
        self.label.backgroundColor = UIColor.clear
        self.label.textAlignment = .center
        self.label.numberOfLines = 1
        self.label.lineBreakMode = .byTruncatingTail
        
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(self.label)
        
        //setup constraints
        NSLayoutConstraint.activate([
            self.contentView.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.contentView.rightAnchor.constraint(equalTo: self.rightAnchor),
            self.contentView.topAnchor.constraint(equalTo: self.topAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.label.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
            self.label.rightAnchor.constraint(equalTo: self.contentView.rightAnchor),
            self.label.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.label.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

        ])
        
    }
    
    init() {
        super.init(frame: CGRect.zero)
        self.sharedInitialise()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInitialise()
    }
    
    required init!(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedInitialise()
    }
    
//    public func configure(with text: String, selectedColor: UIColor, normalTextColor: UIColor, font: UIFont) {
//
//        self.selectedTint = selectedColor
//        self.textColor = normalTextColor
//
////        let stringSize: CGSize = (text as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
////        self.label.bounds = CGRect(origin: .zero, size: stringSize)
//
//        self.label.text = text
//        self.label.font = font
//        self.label.textColor = self.textColor
//        self.label.highlightedTextColor = self.textColor
//
//
//    }


}
