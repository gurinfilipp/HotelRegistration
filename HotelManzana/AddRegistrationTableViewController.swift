//
//  AddRegistrationTableViewController.swift
//  HotelManzana
//
//  Created by Philip on 15.03.2021.
//

import UIKit
import Foundation

class AddRegistrationTableViewController: UITableViewController, SelectRoomTypeTableViewControllerDelegate {
    
    
    
    var registration: Registration? {
        guard let roomType = roomType else {return nil}
        let firstName = firstNameTextField.text ?? ""
            let lastName = lastNameTextField.text ?? ""
            let email = emailTextField.text ?? ""
            let checkInDate = checkInDatePicker.date
            let checkOutDate = checkOutDatePicker.date
            let numberOfAdults = Int(numberOfAdultsStepper.value)
            let numberOfChildren = Int(numberOfChildrenStepper.value)
            let hasWifi = wifiSwitch.isOn
        
            return Registration(firstName: firstName,
                                lastName: lastName,
                                emailAddress: email,
                                checkInDate: checkInDate,
                                checkOutDate: checkOutDate,
                                numberOfAdults: numberOfAdults,
                                numberOfChildren: numberOfChildren,
                                wifi: hasWifi,
                                roomType: roomType)
    }
    
    func selectRoomTypeTableViewController(_ controller: SelectRoomTypeTableViewController, didSelect roomType: RoomType) {
        self.roomType = roomType
        updateRoomType()
    }
    
    var roomType: RoomType?
    
    
    
    func updateRoomType() {
        if let roomType = roomType {
            roomTypeLabel.text = roomType.name
        } else {
            roomTypeLabel.text = "Not Set"
        }
        

      updateChargesSection()
    }
    
    
    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
    
        return dateFormatter
    }()
    
    let checkInDateLabelCellIndexPath = IndexPath(row: 0, section: 1)
    let checkInDatePickerCellIndexPath = IndexPath(row: 1, section: 1)
    let checkOutDateLabelCellIndexPath = IndexPath(row: 2, section: 1)
    let checkOutDatePickerCellIndexPath = IndexPath(row: 3, section: 1)
    
    var isCheckInDatePickerVisible: Bool = false {
        didSet {
            checkInDatePicker.isHidden = !isCheckInDatePickerVisible
        }
    }
    
    var isCheckOutDatePickerVisible: Bool = false {
        didSet {
            checkOutDatePicker.isHidden = !isCheckOutDatePickerVisible
        }
    }
    
    
    
    @IBOutlet weak var roomTypeLabel: UILabel!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var checkInDateLabel: UILabel!
    @IBOutlet weak var checkInDatePicker: UIDatePicker!
    @IBOutlet weak var checkOutDateLabel: UILabel!
    @IBOutlet weak var checkOutDatePicker: UIDatePicker!
    
    @IBOutlet weak var numberOfNightsLabel: UILabel!
    @IBOutlet weak var numberOfNightsDatesLabel: UILabel!
    
    
    @IBOutlet weak var numberOfAdultsLabel: UILabel!
    @IBOutlet weak var numberOfAdultsStepper: UIStepper!
    
    @IBOutlet weak var numberOfChildrenLabel: UILabel!
    @IBOutlet weak var numberOfChildrenStepper: UIStepper!
    
    @IBOutlet weak var wifiSwitch: UISwitch!
    
    
    @IBOutlet weak var roomPriceLabel: UILabel!
    @IBOutlet weak var roomDetailLabel: UILabel!
    
    
    @IBOutlet weak var wifiPriceLabel: UILabel!
    @IBOutlet weak var wifiIndicatorLabel: UILabel!
    
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    @IBOutlet weak var doneBarButtonItem: UIBarButtonItem!
    
    var exisitingRegistration: Registration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let existingRegistration = exisitingRegistration {
            title = "View Guest Registration"
            doneBarButtonItem.isEnabled = true
            
            roomType = existingRegistration.roomType
            firstNameTextField.text = existingRegistration.firstName
            lastNameTextField.text = existingRegistration.lastName
            emailTextField.text = existingRegistration.emailAddress
            checkInDatePicker.date = existingRegistration.checkInDate
            checkOutDatePicker.date = existingRegistration.checkOutDate
            numberOfAdultsStepper.value = Double(existingRegistration.numberOfAdults)
            numberOfChildrenStepper.value = Double(existingRegistration.numberOfChildren)
            wifiSwitch.isOn = existingRegistration.wifi
        } else {
            let midnightToday = Calendar.current.startOfDay(for: Date())
            checkInDatePicker.minimumDate = midnightToday
            checkInDatePicker.date = midnightToday
        }

        updateDateViews()
        updateNumberOfGuests()
        updateRoomType()
        updateChargesSection()
    }

    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        updateDateViews()
        updateChargesSection()
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        updateNumberOfGuests()
        updateChargesSection()
    }
    
    @IBAction func wifiSwitchChanged(_ sender: UISwitch) {
        updateChargesSection()
    }
    
    
    @IBSegueAction func selectRoomType(_ coder: NSCoder) -> SelectRoomTypeTableViewController? {
        let selectRoomTypeController =
            SelectRoomTypeTableViewController(coder: coder)
         selectRoomTypeController?.delegate = self
         selectRoomTypeController?.roomType = roomType
     
         return selectRoomTypeController
    }
    
    
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
   
    
    
    func updateDateViews() {
        checkOutDatePicker.minimumDate = Calendar.current.date(byAdding:
           .day, value: 1, to: checkInDatePicker.date)
        checkInDateLabel.text = dateFormatter.string(from:
           checkInDatePicker.date)
        checkOutDateLabel.text = dateFormatter.string(from:
           checkOutDatePicker.date)

       updateChargesSection()
        
    }
    
    
    func updateChargesSection() {
        // Number Of Nights Row
        let diffInDays = Calendar.current.dateComponents([.day], from: checkInDatePicker.date, to: checkOutDatePicker.date)
        let numberOfNights = diffInDays.day ?? 0
        numberOfNightsLabel.text = "\(String(describing: numberOfNights))"
        numberOfNightsDatesLabel.text = "\(checkInDateLabel.text!) - \(checkOutDateLabel.text!)"
        
        // Room Type Row
        let roomPriceTotal: Int
        if let roomType = roomType {
        roomDetailLabel.text = "\(roomType.name) @ $\(roomType.price)/night"
        roomPriceTotal = numberOfNights * roomType.price
        roomPriceLabel.text = "$ \(roomPriceTotal)"
        } else {
            roomPriceTotal = 0
            roomPriceLabel.text = "$ \(roomPriceTotal)"
            roomDetailLabel.text = "Room Type Not Chosen"
        }

        // WiFi Row
        let wifiPriceTotal: Int
        if wifiSwitch.isOn {
            wifiIndicatorLabel.text = "Yes"
            let wifiPricePerDay = 10
            wifiPriceTotal = wifiPricePerDay * numberOfNights
            wifiPriceLabel.text = "\(wifiPriceTotal)"
        } else {
            wifiIndicatorLabel.text = "No"
            wifiPriceTotal = 0
            wifiPriceLabel.text = "\(wifiPriceTotal)"
        }
        
        // Total Row
        totalPriceLabel.text = "$ \(roomPriceTotal + wifiPriceTotal)"
        }
    
    
    override func tableView(_ tableView: UITableView,
       heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case checkInDatePickerCellIndexPath where
           isCheckInDatePickerVisible == false:
            return 0
        case checkOutDatePickerCellIndexPath where
           isCheckOutDatePickerVisible == false:
            return 0
        default:
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView,
       didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    
        if indexPath == checkInDateLabelCellIndexPath &&
           isCheckOutDatePickerVisible == false {
            // check-in label selected, check-out picker is not visible, toggle check-in picker
            isCheckInDatePickerVisible.toggle()
        } else if indexPath == checkOutDateLabelCellIndexPath &&
           isCheckInDatePickerVisible == false {
            // check-out label selected, check-in picker is not visible, toggle check-out picker
            isCheckOutDatePickerVisible.toggle()
        } else if indexPath == checkInDateLabelCellIndexPath ||
           indexPath == checkOutDateLabelCellIndexPath {
            // either label was selected, previous conditions failed meaning at least one picker is visible, toggle both
            isCheckInDatePickerVisible.toggle()
            isCheckOutDatePickerVisible.toggle()
        } else {
            return
        }
    
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    
    
    func updateNumberOfGuests() {
        numberOfAdultsLabel.text =
           "\(Int(numberOfAdultsStepper.value))"
        numberOfChildrenLabel.text =
           "\(Int(numberOfChildrenStepper.value))"
    }
    
    
}

