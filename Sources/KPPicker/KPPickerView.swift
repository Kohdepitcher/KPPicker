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
//  KPPickerView.swift
//  KPPickerView
//
//  Created by Kohde Pitcher on 22/2/2022.
//

/*
 *  The purpose of this class is to define the picker view itself and handle all the logic involved
 */

import Foundation
import UIKit

//MARK: - Protocols
//Specified interactions between the picker and the object that is using it
@objc public protocol KPPickerViewDelegate {
    
    /**
        **Optional**
        Called when a label is selected
     */
    @objc optional func pickerView(_ pickerView: KPPickerView, didSelectItem item: Int)
    
    /**
        **Optional**
        Tell the picker an extra margin to add to the margin at a specific index
     */
    @objc optional func pickerView(_ pickerView: KPPickerView, marginSpacingForItem item: Int) -> CGSize
    
    /**
        **Optional**
        Allows the label at a specific index to be customised

        Avoid setting any text color or font as this is already done by the picker itself and will cause issues
     */
    @objc optional func pickerView(_ pickerView: KPPickerView, configureLabel label: UILabel, forItem item: Int)
}

@objc public protocol KPPickerViewDataSource {
    
    
    /**
        Tells the picker how many cells it will have in the data source
     */
    func numberOfItems(_ pickerView: KPPickerView) -> Int
    
    /**
        Tells the picker what text to use for item at the index
     */
    @objc func pickerView(_ pickerView: KPPickerView, textForItem item: Int) -> String
}

//MARK: - Implementation of the picker view
public class KPPickerView: UIView {
    
    //MARK: Public Properties - Accessible to customise picker
    public weak var dataSource: KPPickerViewDataSource? = nil
    public weak var delegate: KPPickerViewDelegate? = nil
    
    //Font used to the text in the cell
    public var font = UIFont.systemFont(ofSize: 20)
    
    //Spacing between each label
    public var itemSpacing: CGFloat = .zero
    
    //Color used for the unselected state of the cell
    public var textColor: UIColor = .darkText
    
    //Color used for the selected state of the cell
    public var selectedTextColor: UIColor = .systemBlue
    
    //Defines how far away from the center a cell is considered in the middle to be seleted
    public var selectionThreshold: Int = 10
    
    //Makes the collection view deselect the cell when outside the threshold set above
    public var shouldDeselectWhenOutsideTreshold: Bool = true
    
    //Should the mask been applied to the picker
    public var maskEnabled = true {
        didSet {
            
            //If the mask is enabled, add a layer over the collection view
            //Otherwise, don't apply a mask
            self.collectionView.layer.mask = self.maskEnabled == true ? {
                let maskLayer = CAGradientLayer()
                    maskLayer.frame = self.collectionView.bounds
                    maskLayer.colors = [
                        UIColor.clear.cgColor,
                        UIColor.black.cgColor,
                        UIColor.black.cgColor,
                        UIColor.clear.cgColor]
                    maskLayer.locations = [0.05, 0.20, 0.80, 0.95]
                    maskLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
                    maskLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
                return maskLayer
            }() : nil
        }
    }
    
    //MARK: Read Only Properties
    //Get the index of the selected cell from the data source array
    public private(set) var selectedPosition: Int = 0
    
    
    //MARK: Private Properties
    //CollectionView used for the picker
    private var collectionView: UICollectionView!
    
    //Layout used in the collection view
    private var collectionViewLayout = PickerCollectionViewLayout()
    
    //Haptic generator used for the haptic feeling when a cell is selected
    private let selectionFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    //Tracks the index path of the cell that is in the center of the picker while scrolling
    //If the value is different then the previous index path, then a selection is triggered
    private var cellInMiddleIndexPath: IndexPath = IndexPath(item: 0, section: 0) {
        didSet {
            if (cellInMiddleIndexPath != oldValue) {
                
                //trigger selection impact generator
                selectionFeedbackGenerator.prepare()
                selectionFeedbackGenerator.impactOccurred()
            }
        }
    }
    
    //MARK: - View Functions
    //MARK: Init Functions
    //Shared initialiser
    private func sharedInit() {
        
        self.collectionView?.removeFromSuperview()
        
        //setup the collectionView
        self.collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: self.collectionViewLayout)
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        self.collectionView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        
        //register the cell used for the collectionView
        self.collectionView.register(
            PickerCollectionViewCell.self,
            forCellWithReuseIdentifier: NSStringFromClass(PickerCollectionViewCell.self))
        
        //setup the collectionView's delegate and dataSource
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        //add the views to the picker view
        self.addSubview(self.collectionView)

        
        //default property values
        //need to set this last as the didSet relies upon the collection view to add the mask to it
        //setting early will cause a crash
        self.maskEnabled = true
    }
    
    public init() {
        super.init(frame: CGRect.zero)
        self.sharedInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.sharedInit()
    }
    
    deinit {
        self.collectionView.delegate = nil
    }
    
    //MARK: Layout
    //Called when iOS lays out views particually when the device rotates
    //When the device is rotated, the picker will move to the selected index as the picker's width would've changed
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        //Continue if the datasource is not nill AND there's more than 0 items in the datasource
        if self.dataSource != nil && self.dataSource!.numberOfItems(self) > 0 {
            
            //Set the layout to the cutstom layout for the picker
            self.collectionView.collectionViewLayout = self.collectionViewLayout
            
            //Scroll the picker to the selected position
            self.scrollToItem(self.selectedPosition, animated: false)

        }
        
        //Update the mask for the picker to match the bounds of the underlying collection view
        self.collectionView.layer.mask?.frame = self.collectionView.bounds
    }
    
    //Return the font's line height as the intrinsic height for this custom view
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: self.font.lineHeight)
    }
    
    
    /**
        When called, returns the CGSize for a string using the specified font applied on the picker
     
        - Parameter string: The string to get the size for
     
        - Returns: A CGSize of the string using the picker's font
     */
    private func sizeForString(_ string: NSString) -> CGSize {
        return string.size(withAttributes: [NSAttributedString.Key.font: self.font])
    }
    
    /**
        Reloads the picker to use a new dataSource or update appearance
     */
    public func reloadData() {
        self.invalidateIntrinsicContentSize()
        self.collectionView.collectionViewLayout.invalidateLayout()
        
        //Reload the collection view that is used under the hood
        self.collectionView.reloadData()
        
        //Continue if the datasource is not nill AND there's more than 0 items in the datasource
        if self.dataSource != nil && self.dataSource!.numberOfItems(self) > 0 {
            
            //Select a cell at the selected position and don't notify selection
            self.selectItem(self.selectedPosition, animated: false, notifySelection: false)
        }
    }
    
    /**
        Scroll the picker to an item
     
        - Parameters:
            - item: The position of the item
            - animated: Should the picker animate the scrolling?
     */
    private func scrollToItem(_ item: Int, animated: Bool = false) {
        self.collectionView.scrollToItem(at: IndexPath(item: item, section: 0), at: .centeredHorizontally, animated: animated)
    }
    
    /**
        Select a specific item
     
        - Parameters:
            - item: The position of the item
            - animated: Should the picker animate the selection?
     */
    public func selectItem(_ item: Int, animated: Bool = true) {
        
        //Call the internal selectItem function but force selection so that the selected index is updated and the delegate is informed
        self.selectItem(item, animated: animated, notifySelection: true)
    }
    
    /**
        Select a specific item
        This is used internally by the picker view and is available publicly as the selectItem
        
        - Parameters:
            - item: The position of the item
            - animated: Should the picker animate the selection
            - notifySelection: Should the delegate be informed of the update?
     */
    private func selectItem(_ item: Int, animated: Bool, notifySelection: Bool) {
        
        //Tell the collectionView to select the item at the item index parameter and set if this should be animated
        self.collectionView.selectItem(at: IndexPath(item: item, section: 0), animated: animated, scrollPosition: UICollectionView.ScrollPosition())
        
        //Scroll the picker to the item index parameter
        self.scrollToItem(item, animated: animated)
        
        //Updated the selected position to be the item index parameter
        self.selectedPosition = item
        
        //If the picker should notify the delegate about the selection
        if notifySelection {
            self.delegate?.pickerView?(self, didSelectItem: item)
        }
    }
}

//MARK: - Extensions
//Implement relevant collectionView delegate functions
extension KPPickerView: UICollectionViewDelegate {
    
    //When a cell is tapped
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //select the item at the index path of the cell
        self.selectItem(indexPath.item, animated: true, notifySelection: true)
        
        let tappedCell = self.collectionView.cellForItem(at: indexPath) as! PickerCollectionViewCell
        tappedCell.label.textColor = textColor
        
        let middleCell = self.collectionView.cellForItem(at: cellInMiddleIndexPath) as! PickerCollectionViewCell
        middleCell.label.textColor = selectedTextColor
    }
    
}

//Implement relevant collectionView dataSource functions
extension KPPickerView: UICollectionViewDataSource {
    
    //Tell the collectionView to only have a single section
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    //Tell the collectionView how many items that will be shown in the picker
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //If the picker's dataSource is set, return the count of items in the picker's dataSource
        //Otherwise, return 0 if the picker's dataSource is not set
        return self.dataSource != nil ? self.dataSource!.numberOfItems(self) : 0
    }
    
    //Logic for setting up the cells used in the picker
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //Create a cell by dequeueing a reusable cell using the PickerCell's class name as the reuse indetifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(PickerCollectionViewCell.self), for: indexPath) as! PickerCollectionViewCell

        //try to get the label for the cell's index path from the data source
        if let text = self.dataSource?.pickerView(self, textForItem: indexPath.item) {
            
            //setup the colors in the cell
            cell.selectedTint = self.selectedTextColor
            cell.textColor = self.textColor
            
            //setup the label externally from the cell itself
            cell.label.text = text
            cell.label.font = self.font
            cell.label.textColor = self.textColor
            //cell.label.bounds = CGRect(origin: CGPoint.zero, size: self.sizeForString(text as NSString))
            
            //if the cell's index path matches the middle cell's index path
            if cellInMiddleIndexPath == indexPath {
                
                //set the label color to look like its been select
                cell.label.textColor = self.selectedTextColor
            } else {
                
                //default back to the normal text color otherwise
                cell.label.textColor = self.textColor
            }

            //continue if the delegate is set
            if let delegate = self.delegate {
                
                //allow the label to be configured outside of this view
                delegate.pickerView?(self, configureLabel: cell.label, forItem: indexPath.item)

                //allow the margin to be configured directly for the cell's index path
                if let margin = delegate.pickerView?(self, marginSpacingForItem: indexPath.item) {
                    cell.label.frame = cell.label.frame.insetBy(dx: -margin.width, dy: -margin.height)
                }
            }
        }
        
        
        return cell
    }


}

//Implement relevant collectionView flow layout delegate functions
extension KPPickerView: UICollectionViewDelegateFlowLayout {
    
    //Inform the layout what the size for each cell should be
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        //Create a new cell using item spacing as the width and the collectionView's height as the height
        var size = CGSize(width: self.itemSpacing, height: collectionView.bounds.size.height)

        //Conintue if we can get string for the index path
        if let title = self.dataSource?.pickerView(self, textForItem: indexPath.item) {
            
            //Append the width of the string to with of the size utlising the picker's font
            size.width += self.sizeForString(title as NSString).width
            
            //Continue if we can get a margin for the index path
            if let margin = self.delegate?.pickerView?(self, marginSpacingForItem: indexPath.item) {
                
                //If we do get a width, double the width and append it to the size
                size.width += margin.width * 2
            }
        }
        
        //return the calcuated size for the cell at the index path
        return size
    }
    
    //Return zero for the minimum line spacing
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.zero
    }
    
    //Return zero for the minimum item spacing
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.zero
    }
    
    //Setup the inset for the picker
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        //Get the count of all the cells in the picker
        let number = self.collectionView(collectionView, numberOfItemsInSection: section)
        
        //Get the indexPaths of the first and last item in the picker
        let firstIndexPath = IndexPath(item: 0, section: section)
        let lastIndexPath = IndexPath(item: number - 1, section: section)
        
        //Get the sizes of the first and last item
        let firstSize = self.collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: firstIndexPath)
        let lastSize = self.collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: lastIndexPath)

        //Setup the edge insets used for the picker
        return UIEdgeInsets(top: 0,
                            left: (collectionView.bounds.size.width - firstSize.width) / 2,
                            bottom: 0,
                            right: (collectionView.bounds.size.width - lastSize.width) / 2)
    }
}

extension KPPickerView: UIScrollViewDelegate {
    
    //Select the cell at the center of the collectionView when the scroll view finishes decelerating
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let center = self.convert(self.collectionView.center, to: self.collectionView)
        if let indexPath = self.collectionView.indexPathForItem(at: center) {
            self.selectItem(indexPath.item, animated: true, notifySelection: true)
        }
    }

    //Select the cell at the center of the collectionView when the scroll view finishes being dragged
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let center = self.convert(self.collectionView.center, to: self.collectionView)
            if let indexPath = self.collectionView.indexPathForItem(at: center) {
                self.selectItem(indexPath.item, animated: true, notifySelection: true)
            }
        }
    }
    
    //This function is responsible for keeping the mask in place while scrolling
    //as well as visiually selecting cells
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //Keep the mask fixed in place while scrolling
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        self.collectionView.layer.mask?.frame = self.collectionView.bounds
        CATransaction.commit()
        
        //This next part is used to "visually" select a item as it scroll past the middle of the collection view
        //Note that this doesn't trigger the picker to select anything
        
        //get the center of the collection view relative to itself
        let center = self.convert(self.collectionView.center, to: self.collectionView)
        //print("CollectionView Center Point: \(center.x)")


        //try to get an index path for the item at the center point
        if let indexPath = self.collectionView.indexPathForItem(at: center) {

            //grab a reference of the cell at the index path above
            let cell: PickerCollectionViewCell = self.collectionView.cellForItem(at: indexPath) as! PickerCollectionViewCell

            //get the center point of the cell realtive to the collection view
            let middle = self.collectionView.convert(cell.center, to: self.collectionView)
            //print("Cell at center's center position relative to collection view: \(middle.x)")

            //calculate thresholds for where the cell has to be between before selection
            let lowerThreshold = center.x - CGFloat(selectionThreshold)
            let upperThreshold = center.x + CGFloat(selectionThreshold)

            //if the middle point of the cell falls between the threshold then it will be be visually selected
            if (lowerThreshold <= middle.x && middle.x <= upperThreshold) {
                //print("In Middle")

                //select the item at the center position so that the cell changes color when in the middle of the picker
                self.collectionView.selectItem(
                    at: indexPath,
                    animated: false,
                    scrollPosition: UICollectionView.ScrollPosition())

                /* set this property to the index path of the cell which is at the center of the collection view
                 * if the index path changes, the didSet on the property will fire the selection trigger
                 *
                 * This logic ensures that the haptic feedback only fires once as the middle cell trueley falls within the selection threshold
                 */
                cellInMiddleIndexPath = indexPath

            }

            //if the cell is outside the defined threshold
            else {

                //deselect the cell to play the deselection animation when outside of the threshold
                if ( shouldDeselectWhenOutsideTreshold ) {
                    self.collectionView.deselectItem(at: indexPath, animated: true)
                }

            }


        }
        
    }
    
}
