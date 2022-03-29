# KPPicker
<img src="https://github.com/Kohdepitcher/KPPicker/blob/main/Resources/Picker.jpeg" width="360"/>

## About

An easy to use horizontal picker that is designed to mimic the look and feel of Apple's very own picker in their Memoji builder screen.
Allows for easy customisation and even customising each individual label shown in the picker

This library is based upon the now deprecated AKPickerView library available at: [AKPickerView Repo](https://github.com/akkyie/AKPickerView-Swift),
KPPicker is missing some features like the 3D wheel effect and is missing support for Images to be displayed instead of labels.
If these features are requested, I can add those features to this library

## Navigate

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
    - [Customisation](#customisation)
- [Demo](#demo)


## Requirements

 - iOS 12 and higher
 - Swift 4.0 and higher

## Installation

This UI component can currently be installed via the following methods:

### Swift Package Manager

If you prefer to install the UI component through Apple's own dependency manager than you just need to add the URL of this Github repo to your Xcode project.
To do this, go to `File > Add Packages` and then 

### Manual

If you prefer to not use any dependency measures, you can install the component manually.
To do this, just put the `Sources/KPPicker` folder into your Xcode project and don't forget to choose `Copy items if needed` and `Create groups`.


## Usage

1. Instantiate a KPPicker and set the delegate and data source
    ```swift
    import UIKit
    import KPPicker

    class ViewController: UIView Controller {

        @IBOutlet var picker: KPPickerView!

        override func viewDidLoad() {
            super.viewDidLoad()

            self.picker.delegate = self
            self.picker.dataSource = self

            self.picker.font = UIFont.systemFont(ofSize: 17, weight: .bold)
            self.picker.textColor = UIColor()
            self.picker.selectedTextColor = UIColor()
            self.picker.maskEnabled = true
            self.picker.itemSpacing = 40

            self.picker.reloadData()
        }
    }
    ```

2. Tell the picker how many labels will be shown and what text to use using the required protocols
    ```swift
    extension ViewController: KPPickerViewDataSource {
        func numberOfItems(_ pickerView: KPPickerView) -> Int {
            return self.array.count
        }

        func pickerView(_ pickerView: KPPickerView, textForItem item: Int) -> String {
            return self.array[item]
        }
    }
    ```
    Note that you can also customise the label for each individual label using the `configureLabel` delegate function. When customising the label, avoid setting `font` and `textColor` as this is set by the picker and applied to all labels automatically and will be overriden while scrolling.
    ```swift
    extension ViewController: KPPickerViewDelegate {
        func pickerView(_ pickerView: KPPickerView, configureLabel label: UILabel, forItem item: Int) {
            
            /*customise label*/
            label.backgroundColor = .red
        }
    }
    ```

3. To get the position of the selected option, implement the `didSelectItem` delegate func and use the `int` that it returns.
    ```swift
    extension ViewController: KPPickerViewDelegate {
        func pickerView(_ pickerView: KPPickerView, didSelectItem item: Int) {
            self.selectedIndex = item
        }
    }
    ```

## Additional Functions

## Selecting Items Manually

To select a label manually, use the `selectItem` function to select a label at a specified index
```swift
self.picker.selectItem()
```

### Reload Data

When updating the customisation properties or when the backing array changes, you need to reload the picker for the changes to take affect
```swift
self.picker.reloadDate()
```

## Customisation

### Font

You can customise the font of the picker by setting the picker's font with the `font` variable
```swift
self.picker.font = UIFont.systemFont(ofSize: 17, weight: .bold)
```

### Text Color

You can control the colour of the unselected label in the picker by setting the `textColor `variable
```swift
self.picker.textColor = UIColor()
```

### Selected Text Color

You can control the colour of the selected label in the picker by setting the `selectedTextColor `variable
```swift
self.picker.selectedTextColor = UIColor()
```

### Mask

You can enable or disable the mask applied to the edges of the picker by setting `true` or `false` on the `maskEnabled`
```swift
self.picker.maskEnabled = true
```

### Item Spacing

You can control the spacing between each label in the picker by setting the `itemSpacing `variable
```swift
self.picker.itemSpacing = 40
```

### Selection Threshold

Sets the range left and right from the center that a cell is considered to be in the middle to be selected
```swift
self.picker.selectionThreshold = 10
```

### Unselect When Outside Threshold

Changes the selection logic for the threshold, if set to `true` then the picker will unselect an option as it scrolls outside the threshold. If set to `false` then the picker will keep that option selected until a new label enters the threshold
```swift
self.picker.shouldDeselectWhenOutsideTreshold = true
```

## Demo
This UI component comes with a demo app that can be installed to the simulator or a device to test it out.
From it you can customise the picker including all the customisable properties listed above