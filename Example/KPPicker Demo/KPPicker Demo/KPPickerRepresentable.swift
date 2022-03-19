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
//  AKPickerRepresentable.swift
//  RacesListCountDown
//
//  Created by Kohde Pitcher on 19/2/2022.
//

import SwiftUI
import KPPicker

struct KPPickerRepresentable: UIViewRepresentable {
    
    @Binding var items: [String]
    @Binding var selectedIndex: Int
    @Binding var selectedColor: Color
    @Binding var textColor: Color
    @Binding var spacing: Int
    @Binding var maskEnable: Bool
    @Binding var selectionThreshold: Int
    @Binding var shouldDeselectWhenOutsideTreshold: Bool
    @Binding var shouldReload: Bool
    
    func makeUIView(context: Context) -> KPPickerView {
        let picker = KPPickerView()
        
        //setup the picker
        picker.textColor = UIColor(textColor)
        picker.selectedTextColor = UIColor(selectedColor)
        picker.itemSpacing = CGFloat(spacing)
        picker.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        picker.selectionThreshold = selectionThreshold
        picker.shouldDeselectWhenOutsideTreshold = shouldDeselectWhenOutsideTreshold
        
        //set delegate and datasource for the picker
        picker.delegate = context.coordinator
        picker.dataSource = context.coordinator
        
        //select the first item
        picker.selectItem(0, animated: false)
        
        return picker
    }
    
    func updateUIView(_ uiView: KPPickerView, context: Context) {
        uiView.selectedTextColor = UIColor(selectedColor)
        uiView.textColor = UIColor(textColor)
        uiView.itemSpacing = CGFloat(spacing)
        uiView.maskEnabled = maskEnable
        uiView.selectionThreshold = selectionThreshold
        uiView.shouldDeselectWhenOutsideTreshold = shouldDeselectWhenOutsideTreshold
        
        //optionally reload the picker when shouldReload is set
        /*  This is stop an animation bug from occuring when a label was tapped
            When tapping a label, the updated state for selectedIndex caused the picker to reload which prevented the picker from sliding along when tapped and instead would snap to the new label without animating
         */
        if shouldReload {
            uiView.reloadData()
            
            self.shouldReload = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, KPPickerViewDataSource, KPPickerViewDelegate {
        
        var parent: KPPickerRepresentable
        
        init(_ parent: KPPickerRepresentable) {
            self.parent = parent
        }
        
        func numberOfItems(_ pickerView: KPPickerView) -> Int {
            return parent.items.count
        }
        
        func pickerView(_ pickerView: KPPickerView, textForItem item: Int) -> String {
            return parent.items[item]
        }

        func pickerView(_ pickerView: KPPickerView, didSelectItem item: Int) {
            self.parent.selectedIndex = item
        }
        
        func pickerView(_ pickerView: KPPickerView, configureLabel label: UILabel, forItem item: Int) {
            
        }
        
    }
}

