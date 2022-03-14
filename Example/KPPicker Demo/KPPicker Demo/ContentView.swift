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
    
    var body: some View {
        NavigationView {
            
            VStack(alignment: .center) {
                
                KPPickerRepresentable(items: $strings, selectedIndex: $selectedIndex, selectedColor: $tintColor, textColor: $textColor, spacing: $spacing, maskEnable: $maskEnabled, selectionThreshold: $selectionThreshold, shouldDeselectWhenOutsideTreshold: $shouldDeselectWhenOutsideTreshold)
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
                            ColorPicker("Selection color", selection: $tintColor, supportsOpacity: false)
                        }
                        
                        Section(header: Text("Selection")) {
                            Stepper("Selection Threshold: \(selectionThreshold)", value: $selectionThreshold, in: 1...200)
                            Toggle("Should Picker Deselect When Outside Threshold", isOn: $shouldDeselectWhenOutsideTreshold)
                        }
                        
                        Section(header: Text("Mask")) {
                            Toggle("Enable Mask", isOn: $maskEnabled)
                        }
                        
                        Section(header: Text("Layout")) {
                            Stepper("Item spacing: \(spacing)", value: $spacing, in: 0...200)
//                            Toggle("Should Bounce When Scrolling Past Ends", isOn: $shouldBounceAtEnds)
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
