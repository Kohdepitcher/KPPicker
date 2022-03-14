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
//  PickerCollectionViewLayout.swift
//  KPPickerView
//
//  Created by Kohde Pitcher on 22/2/2022.
//

/*
 *  The purpose of this class is to define the custom layout used for the picker
 */

import Foundation
import UIKit

public class PickerCollectionViewLayout: UICollectionViewFlowLayout {
    
    //shared initialiser
    func sharedInitialise() {
        self.scrollDirection = .horizontal
    }
    
    override init() {
        super.init()
        self.sharedInitialise()
    }
    
    required init!(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedInitialise()
    }
    
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        if let attributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes {
            return attributes
        }
        
        return nil
        
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return super.layoutAttributesForElements(in: rect)
    }
    
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
            var offsetAdjustment: CGFloat = CGFloat.greatestFiniteMagnitude
            let horizontalCenter: CGFloat = proposedContentOffset.x + (self.collectionView!.bounds.width / 2.0)
            let targetRect = CGRect(x: proposedContentOffset.x, y: 0.0, width: self.collectionView!.bounds.size.width, height: self.collectionView!.bounds.size.height)
            let array:[UICollectionViewLayoutAttributes] = self.layoutAttributesForElements(in: targetRect)!
            for layoutAttributes: UICollectionViewLayoutAttributes in array {
                let itemHorizontalCenter: CGFloat = layoutAttributes.center.x
                if abs(itemHorizontalCenter - horizontalCenter) < abs(offsetAdjustment) {
                    offsetAdjustment = itemHorizontalCenter - horizontalCenter
                }
            }
            return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
        }

    
}
