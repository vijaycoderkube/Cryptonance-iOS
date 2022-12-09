//
//  DatePickerViewController.swift
//  Cryptonance
//
//  Created by Dhruv Jariwala on 28/10/22.
//

import UIKit

/// DatePicker View presents date picker to select perticular date
class DatePickerViewController: UIViewController {

    //define Outlets
    @IBOutlet weak var pickerDoneButton: UIButton?
    @IBOutlet weak var pickerCancelButton: UIButton?
    @IBOutlet weak var datePicker: UIDatePicker?
    ///Background view header buttons ie. cancel and done
    @IBOutlet weak var headerView: UIView?
    ///Background view DatePicker Popup
    @IBOutlet weak var datePickerBGView: UIView?
    
    
    //MARK: - Variables
    var datePickerCustomMode = datepickerMode(customPickerMode:UIDatePicker.Mode.date)
    var pickerDelegate : datePickerDelegate?
    var isSetDate = false
    var setDateValue : Date?
    
    //MARK: viewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()
    }
}


protocol datePickerDelegate {
    func setDateValue(dateValue : Date,type:Int)
}

struct datepickerMode {
    var pickerMode : UIDatePicker.Mode
    
    init(customPickerMode:UIDatePicker.Mode) {
        self.pickerMode = customPickerMode
    }
}


//MARK: - UI Functions
extension DatePickerViewController{
    
    /// This function will use for the setup ui when view contoller will load
    func setUpUI() {
        
        datePicker?.maximumDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())
        
        [datePickerBGView, headerView].forEach { (view) in
            view?.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
        
        datePicker?.datePickerMode = datePickerCustomMode.pickerMode
        datePicker?.date = Date()
        
        if(isSetDate) {
            datePicker?.setDate(setDateValue ?? Date(), animated: false)
        }
        
        if #available(iOS 13.4, *) {
            if #available(iOS 14.0, *) {
                datePicker?.preferredDatePickerStyle = .inline
            } else {
                datePicker?.preferredDatePickerStyle = .compact
            }
            datePicker?.sizeToFit()
        }
    }
}


//MARK: - Button click events
extension DatePickerViewController{
    
    /// Click Event for continue Button
    @IBAction func pickerCancelButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func pickerDoneButtonAction(_ sender: Any) {
        if datePickerCustomMode.pickerMode == .time {
            
            pickerDelegate?.setDateValue(dateValue: datePicker!.date, type: 1)
        }
        else {
            pickerDelegate?.setDateValue(dateValue: datePicker!.date, type: 0)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}

