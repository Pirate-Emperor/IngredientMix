//
//  DeliveryAddressVC.swift
//  IngredientMix
//

import UIKit
import GoogleMaps

final class AddressVC: UIViewController {
        
    private var location: CLLocation? {
        didSet {
            updateMapView()
        }
    }
    
    private var isNewAddress = true
    private var needToUpdateCoreData = false
    private var oldPlaceName = ""
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()
    
    // MARK: - UI props.
    
    private lazy var backButtonView: NavigationBarButtonView = {
        let view = NavigationBarButtonView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backButtonTapped))
        view.addGestureRecognizer(tapGesture)
        view.configureAsBackButton()
        return view
    }()
    
    private lazy var geolocationButtonView: NavigationBarButtonView = {
        let view = NavigationBarButtonView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(geolocationButtonTapped))
        view.addGestureRecognizer(tapGesture)
        view.configureAsGeolocationButton()
        return view
    }()
    
    private lazy var placeNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 550])
        label.text = "Place Name"
        return label
    }()
    
    private lazy var placeNameField: TextField = {
        let field = TextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.returnKeyType = .next
        field.associatedLabel = placeNameLabel
        field.delegate = self
        return field
    }()
    
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 550])
        label.text = "Address"
        return label
    }()
    
    private lazy var addressField: TextField = {
        let field = TextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.returnKeyType = .done
        field.autocapitalizationType = .words
        field.associatedLabel = addressLabel
        field.delegate = self
        return field
    }()
    
    private lazy var mapSectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorManager.shared.lightGraySectionColor
        view.layer.cornerRadius = 24
        return view
    }()
    
    private lazy var mapView: GMSMapView = {
        let camera = GMSCameraPosition.camera(withLatitude: 41.6903308028158, longitude: 44.807368755121445, zoom: 17.0)
        let mapView = GMSMapView()
        mapView.camera = camera
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.layer.cornerRadius = 14
        mapView.layer.borderWidth = 1
        mapView.layer.borderColor = ColorManager.shared.labelGray.withAlphaComponent(0.1).cgColor
        return mapView
    }()
    
    private lazy var marker: GMSMarker = {
        let marker = GMSMarker()
        if let customIcon = UIImage(named: "GooglePin") {
            marker.icon = customIcon
        }
        return marker
    }()
    
    private lazy var defaultAddressCheckBox: CheckBox = {
        let checkbox = CheckBox()
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.addTarget(self, action: #selector(defaultAddressCheckBoxDidTapped), for: .touchUpInside)
        checkbox.isChecked = false
        return checkbox
    }()
    
    private lazy var defaultAddressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 550])
        label.text = "Use this address by default"
        label.numberOfLines = 2
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(defaultAddressCheckBoxDidTapped))
        label.addGestureRecognizer(tapGesture)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = Constants.regularButtonHeight / 2
        button.backgroundColor = ColorManager.shared.regularButtonColor
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.6), for: .highlighted)
        button.titleLabel?.font = UIFont.getVariableVersion(of: "Raleway", size: 17, axis: [Constants.fontWeightAxis : 550])
        button.addTarget(self, action: #selector(saveButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(saveButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return button
    }()
    
    // MARK: - Controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupUI()
        setupConstraints()
        applyMapStyle()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            applyMapStyle()
        }
    }
    
    // MARK: - internal methods
    
    func configureWithExisting(_ adress: AddressEntity) {
        needToUpdateCoreData = true
        defaultAddressCheckBox.isHidden = true
        defaultAddressLabel.isHidden = true
        oldPlaceName = adress.placeName!
        placeNameField.text = adress.placeName
        addressField.text = adress.address
        location = CLLocation(latitude: adress.latitude, longitude: adress.longitude)
        isNewAddress = false
        title = "Address"
    }
    
    // MARK: - Private methods
    
    private func setupNavBar() {
        if isNewAddress {
            title = "New Address"
        }
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: ColorManager.shared.label,
            .font: UIFont.getVariableVersion(of: "Raleway", size: 21, axis: [Constants.fontWeightAxis : 650])
        ]
        
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        let backBarButtonItem = UIBarButtonItem(customView: backButtonView)
        let geolocationBarButtonItem = UIBarButtonItem(customView: geolocationButtonView)
        navigationItem.leftBarButtonItem = backBarButtonItem
        navigationItem.rightBarButtonItem = geolocationBarButtonItem
    }
    
    private func setupUI() {
        view.backgroundColor = ColorManager.shared.background
        
        view.addSubview(placeNameLabel)
        view.addSubview(placeNameField)
        view.addSubview(addressLabel)
        view.addSubview(addressField)
        view.addSubview(mapSectionView)
        view.addSubview(defaultAddressCheckBox)
        view.addSubview(defaultAddressLabel)
        view.addSubview(saveButton)
        
        mapSectionView.addSubview(mapView)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            placeNameLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 32),
            placeNameLabel.leadingAnchor.constraint(equalTo: placeNameField.leadingAnchor, constant: 16),
            placeNameField.topAnchor.constraint(equalTo: placeNameLabel.bottomAnchor, constant: 8),
            placeNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            placeNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            placeNameField.heightAnchor.constraint(equalToConstant: Constants.regularFieldHeight),
            
            addressLabel.topAnchor.constraint(equalTo: placeNameField.bottomAnchor, constant: 12),
            addressLabel.leadingAnchor.constraint(equalTo: addressField.leadingAnchor, constant: 16),
            addressField.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 8),
            addressField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            addressField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            addressField.heightAnchor.constraint(equalToConstant: Constants.regularFieldHeight),
            
            mapSectionView.topAnchor.constraint(equalTo: addressField.bottomAnchor, constant: 32),
            mapSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mapSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mapSectionView.heightAnchor.constraint(equalToConstant: 240),
            mapView.topAnchor.constraint(equalTo: mapSectionView.topAnchor, constant: 16),
            mapView.leadingAnchor.constraint(equalTo: mapSectionView.leadingAnchor, constant: 16),
            mapView.trailingAnchor.constraint(equalTo: mapSectionView.trailingAnchor, constant: -16),
            mapView.bottomAnchor.constraint(equalTo: mapSectionView.bottomAnchor, constant: -16),
            
            defaultAddressCheckBox.topAnchor.constraint(equalTo: mapSectionView.bottomAnchor, constant: 32),
            defaultAddressCheckBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            defaultAddressCheckBox.widthAnchor.constraint(equalToConstant: Constants.checkboxSize),
            defaultAddressCheckBox.heightAnchor.constraint(equalToConstant: Constants.checkboxSize),
            defaultAddressLabel.topAnchor.constraint(equalTo: defaultAddressCheckBox.topAnchor),
            defaultAddressLabel.leadingAnchor.constraint(equalTo: defaultAddressCheckBox.trailingAnchor, constant: 8),
            defaultAddressLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            saveButton.heightAnchor.constraint(equalToConstant: Constants.regularButtonHeight),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16)
        ])
    }
    
    private func getCoordinatesFrom(_ address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let error = error {
                
                let notification = UserNotification(message: "No coordinates were found for your address. Please check the entered data and try again.", type: .warning)
                notification.show(in: self)
                
                print("Error geocoding address: \(error.localizedDescription)")
                
            } else if let placemark = placemarks?.first {
                self.location = placemark.location
            }
        }
    }
    
    private func getAddressFrom(_ location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                
                let notification = UserNotification(message: "No addresses were found at these coordinates.", type: .warning)
                notification.show(in: self)
                
                print("Error reverse geocoding: \(error.localizedDescription)")
            } else if let placemark = placemarks?.first {
                if let address = placemark.name {
                    self.addressField.text = address
                }
            }
        }
    }
    
    private func updateMapView() {
        if let location = location {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15.0)
            mapView.moveCamera(GMSCameraUpdate.setCamera(camera))
            marker.map = mapView
            marker.position = location.coordinate
        }
    }
    
    private func isAddressValid() -> Bool {
        var isValid = true
        
        if placeNameField.text?.isEmpty ?? true {
            placeNameField.isInWarning = true
            isValid = false
        } else {
            placeNameField.isInWarning = false
        }
        
        if addressField.text?.isEmpty ?? true {
            addressField.isInWarning = true
            isValid = false
        } else {
            addressField.isInWarning = false
        }

        if location == nil {
            // need warning
            isValid = false
        }
        
        return isValid
    }
    
    private func applyMapStyle() {
        let userInterfaceStyle = UITraitCollection.current.userInterfaceStyle
        let styleFileName: String

        switch userInterfaceStyle {
        case .dark:
            styleFileName = "map_dark_style"
        default:
            styleFileName = "map_light_style"
        }

        if let styleURL = Bundle.main.url(forResource: styleFileName, withExtension: "json") {
            do {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } catch {
                ErrorLogger.shared.logError(error, additionalInfo: ["Event": "Failed to load map style."])
                print("Failed to load map style. \(error)")
            }
        }
    }
    
    private func animatePress(for view: UIView) {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            animations: {
                view.alpha = 0.3
            },
            completion: { _ in
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0,
                    animations: {
                        view.alpha = 1
                    }
                )
            }
        )
    }
    
    // MARK: - ObjC methods
    
    @objc
    private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func geolocationButtonTapped() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        animatePress(for: geolocationButtonView)
    }
    
    @objc
    private func defaultAddressCheckBoxDidTapped() {
        defaultAddressCheckBox.isChecked.toggle()
    }
    
    @objc
    private func saveButtonTouchDown() {
        UIView.animate(withDuration: 0.05) {
            self.saveButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc
    private func saveButtonTouchUp() {
        UIView.animate(withDuration: 0.05, delay: 0.05, options: [], animations: {
            self.saveButton.transform = CGAffineTransform.identity
        }, completion: nil)
        
        if isAddressValid() {
            guard let location = location else { return }
            
            if needToUpdateCoreData {
                do {
                    try CoreDataManager.shared.updateAddress(oldPlaceName: oldPlaceName,
                                                             newPlaceName: placeNameField.text!,
                                                             address: addressField.text!,
                                                             latitude: location.coordinate.latitude,
                                                             longitude: location.coordinate.longitude)
                    navigationController?.popViewController(animated: true)
                } catch {
                    let notification = UserNotification(message: "An error occurred while trying to update the address data. Please try again.", type: .error)
                    notification.show(in: self)
                }
            } else {
                do {
                    try CoreDataManager.shared.saveAddress(placeName: placeNameField.text!,
                                                           address: addressField.text!,
                                                           latitude: location.coordinate.latitude,
                                                           longitude: location.coordinate.longitude,
                                                           isDefaultAddress: defaultAddressCheckBox.isChecked)
                    navigationController?.popViewController(animated: true)
                } catch {
                    let notification = UserNotification(message: "An error occurred while trying to save the address. Please try again.", type: .error)
                    notification.show(in: self)
                }
            }
        }
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - CLLocationManagerDelegate

extension AddressVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.location = location
            getAddressFrom(location)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied {
            let notification = UserNotification(message: "You have not given the app access to the location. You can change this in the iOS settings..", type: .error)
            notification.show(in: self)
            print("Geolocation is denied")
        }
        
        if status == .restricted {
            let notification = UserNotification(message: "The application is not authorized to access the location.", type: .error)
            notification.show(in: self)
            print("Geolocation is restricted")
        }
    }
}

// MARK: - UITextFieldDelegate

extension AddressVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == placeNameField {
            addressField.becomeFirstResponder()
        } else if textField == addressField {
            guard let address = textField.text, !address.isEmpty else { return false }
            getCoordinatesFrom(address)
        }
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let field = textField as? TextField {
            field.isInWarning = false
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension AddressVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}
