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
//  ContentView.swift
//  KPPickerView
//
//  Created by Kohde Pitcher on 22/2/2022.
//

import SwiftUI

struct ContentView: View {
    
    @State var selectedIndex: Int = 0
    @State var strings = ["First", "Second", "Third", "Fourth", "Fifth", "Sixth", "Seventh", "Eighth", "Nineth", "Tenth"]//["Skin", "Hairstyle", "Brows", "Eyes" , "Head", "Nose", "Mouth", "Ears", "Facial Hair", "Eyewear", "Headgear", "Clothing" ]//
    
    @State var tintColor = Color.blue
    @State var textColor = Color(UIColor.secondaryLabel)
    @State var maskEnabled = true
    
    @State var selectionThreshold = 10
    @State var shouldDeselectWhenOutsideTreshold = true
    @State var spacing = 40
    @State var shouldReload = false
    
    var body: some View {
        NavigationView {
            
            VStack(alignment: .center) {
                
                KPPickerRepresentable(items: $strings, selectedIndex: $selectedIndex, selectedColor: $tintColor, textColor: $textColor, spacing: $spacing, maskEnable: $maskEnabled, selectionThreshold: $selectionThreshold, shouldDeselectWhenOutsideTreshold: $shouldDeselectWhenOutsideTreshold, shouldReload: $shouldReload)
                    .frame(height: 80)
                
                
                    Rectangle()
                    .foregroundColor(.red)
                    .frame(width: 2, height: 10, alignment: .center)
                
                    Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: CGFloat(selectionThreshold * 2), height: 10, alignment: .center)
                    
                    List {
                        
                        Section(header: Text("Debug Information")) {
                            Text("Selected Index: \(selectedIndex)")
                            Text("Selected Value: \(strings[selectedIndex])")
                        }
                        
                        Section(header: Text("Color")) {
                            ColorPicker("Text color", selection: $textColor, supportsOpacity: false)
                                .onChange(of: textColor) { newValue in
                                    shouldReload = true
                                }
                            ColorPicker("Selection color", selection: $tintColor, supportsOpacity: false)
                                .onChange(of: tintColor) { newValue in
                                    shouldReload = true
                                }
                        }
                        
                        Section(header: Text("Selection")) {
                            Stepper("Selection Threshold: \(selectionThreshold)", value: $selectionThreshold, in: 1...200)
                                .onChange(of: selectionThreshold) { newValue in
                                    shouldReload = true
                                }
                            Toggle("Should Picker Deselect When Outside Threshold", isOn: $shouldDeselectWhenOutsideTreshold)
                                .onChange(of: shouldDeselectWhenOutsideTreshold) { newValue in
                                    shouldReload = true
                                }
                        }
                        
                        Section(header: Text("Mask")) {
                            Toggle("Enable Mask", isOn: $maskEnabled)
                                .onChange(of: maskEnabled) { newValue in
                                    shouldReload = true
                                }
                        }
                        
                        Section(header: Text("Layout")) {
                            Stepper("Item spacing: \(spacing)", value: $spacing, in: 0...200)
                                .onChange(of: spacing) { newValue in
                                    shouldReload = true
                                }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .navigationTitle("Picker Example")
                
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
