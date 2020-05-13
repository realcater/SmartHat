import UIKit
import Foundation

extension NewGameVC: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textColor = K.Colors.foreground
        pickerLabel.textAlignment = NSTextAlignment.center
        
        pickerLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        switch component {
        case 0: pickerLabel.text = String(K.SettingsRow.wordsQty[row])+" слов"
        case 1: pickerLabel.text = K.SettingsRow.difficulty[row].name()
        default: pickerLabel.text = String(K.SettingsRow.roundDuration[row])+" сек"
        }
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (component == 1) {
            if (K.SettingsRow.difficulty[row] == .separator1) {
                button.disable()
            } else {
                if playersList.players.count >= K.minPlayersQty {
                    button.enable()
                }
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        let width = pickerView.frame.size.width
        switch component {
        case 0: return 0.27*width
        case 1: return 0.46*width
        default: return 0.27*width
        }
    }
}

// MARK: - Delegates
extension NewGameVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return K.SettingsRow.wordsQty.count
        case 1: return K.SettingsRow.difficulty.count
        default: return K.SettingsRow.roundDuration.count
        }
    }
}
