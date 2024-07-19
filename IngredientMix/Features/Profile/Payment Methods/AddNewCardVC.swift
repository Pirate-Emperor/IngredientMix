//
//  PaymentMethodsVC.swift
//  IngredientMix
//

import UIKit

final class AddNewCardVC: UIViewController {
    
    private lazy var backButtonView: NavigationBarButtonView = {
        let view = NavigationBarButtonView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backButtonTapped))
        view.addGestureRecognizer(tapGesture)
        view.configureAsBackButton()
        return view
    }()
    
    private lazy var cardSectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorManager.shared.lightGraySectionColor
        view.layer.cornerRadius = 24
        return view
    }()
    
    private lazy var cardNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 550])
        label.text = "Card Name"
        return label
    }()
    
    private lazy var cardNameField: TextField = {
        let field = TextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.returnKeyType = .next
        field.associatedLabel = cardNameLabel
        field.delegate = self
        return field
    }()
    
    private lazy var cardNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 550])
        label.text = "Card Number"
        return label
    }()
    
    private lazy var cardNumberField: TextField = {
        let field = TextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.keyboardType = .numberPad
        field.associatedLabel = cardNumberLabel
        field.delegate = self
        return field
    }()
    
    private lazy var mmyyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 550])
        label.text = "MM/YY"
        return label
    }()
    
    private lazy var mmyyField: TextField = {
        let field = TextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.keyboardType = .numberPad
        field.associatedLabel = mmyyLabel
        field.delegate = self
        return field
    }()
    
    private lazy var cvcLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 550])
        label.text = "CVC"
        return label
    }()
    
    private lazy var cvcField: TextField = {
        let field = TextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.keyboardType = .numberPad
        field.associatedLabel = cvcLabel
        field.delegate = self
        return field
    }()
    
    private lazy var cardholderNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 14, axis: [Constants.fontWeightAxis : 550])
        label.text = "Cardholder Name"
        return label
    }()
    
    private lazy var cardholderNameField: TextField = {
        let field = TextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.autocapitalizationType = .allCharacters
        field.returnKeyType = .done
        field.associatedLabel = cardholderNameLabel
        field.delegate = self
        return field
    }()
    
    private lazy var preferredPaymentMethodCheckBox: CheckBox = {
        let checkbox = CheckBox()
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.addTarget(self, action: #selector(preferredPaymentMethodCheckBoxDidTapped), for: .touchUpInside)
        checkbox.isChecked = false
        return checkbox
    }()
    
    private lazy var preferredPaymentMethodLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 550])
        label.text = "Preferred payment method"
        label.numberOfLines = 2
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(preferredPaymentMethodCheckBoxDidTapped))
        label.addGestureRecognizer(tapGesture)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var userAgreementCheckBox: CheckBox = {
        let checkbox = CheckBox()
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.addTarget(self, action: #selector(userAgreementCheckBoxDidTapped), for: .touchUpInside)
        checkbox.isChecked = false
        checkbox.associatedLabel = userAgreementLabel
        return checkbox
    }()
    
    private lazy var userAgreementLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorManager.shared.labelGray
        label.font = UIFont.getVariableVersion(of: "Raleway", size: 16, axis: [Constants.fontWeightAxis : 550])
        label.text = "I have read and accept the terms of use, rules of flight and privacy policy"
        label.numberOfLines = 2
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userAgreementCheckBoxDidTapped))
        label.addGestureRecognizer(tapGesture)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var addCardButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = Constants.regularButtonHeight / 2
        button.backgroundColor = ColorManager.shared.regularButtonColor
        button.setTitle("Add Card", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.6), for: .highlighted)
        button.titleLabel?.font = UIFont.getVariableVersion(of: "Raleway", size: 17, axis: [Constants.fontWeightAxis : 550])
        button.addTarget(self, action: #selector(addCardButtonTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(addCardButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return button
    }()
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupUI()
        setupConstraints()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Private methods
    
    private func setupNavBar() {
        title = "New Card"
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: ColorManager.shared.label,
            .font: UIFont.getVariableVersion(of: "Raleway", size: 21, axis: [Constants.fontWeightAxis : 650])
        ]
        
        navigationController?.navigationBar.titleTextAttributes = titleAttributes
        navigationController?.interactivePopGestureRecognizer?.delegate = self

        let backBarButtonItem = UIBarButtonItem(customView: backButtonView)
        navigationItem.leftBarButtonItem = backBarButtonItem
    }
    
    private func setupUI() {
        view.backgroundColor = ColorManager.shared.background
        
        view.addSubview(cardNameLabel)
        view.addSubview(cardNameField)
        view.addSubview(cardSectionView)
        view.addSubview(preferredPaymentMethodCheckBox)
        view.addSubview(preferredPaymentMethodLabel)
        view.addSubview(userAgreementCheckBox)
        view.addSubview(userAgreementLabel)
        view.addSubview(addCardButton)
        
        cardSectionView.addSubview(cardNumberLabel)
        cardSectionView.addSubview(cardNumberField)
        cardSectionView.addSubview(mmyyLabel)
        cardSectionView.addSubview(mmyyField)
        cardSectionView.addSubview(cvcLabel)
        cardSectionView.addSubview(cvcField)
        cardSectionView.addSubview(cardholderNameLabel)
        cardSectionView.addSubview(cardholderNameField)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            cardNameLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 32),
            cardNameLabel.leadingAnchor.constraint(equalTo: cardNameField.leadingAnchor, constant: 16),
            cardNameField.topAnchor.constraint(equalTo: cardNameLabel.bottomAnchor, constant: 8),
            cardNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            cardNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            cardNameField.heightAnchor.constraint(equalToConstant: Constants.regularFieldHeight),
            
            cardSectionView.topAnchor.constraint(equalTo: cardNameField.bottomAnchor, constant: 24),
            cardSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cardNumberLabel.topAnchor.constraint(equalTo: cardSectionView.topAnchor, constant: 32),
            cardNumberLabel.leadingAnchor.constraint(equalTo: cardSectionView.leadingAnchor, constant: 16),
            cardNumberField.topAnchor.constraint(equalTo: cardNumberLabel.bottomAnchor, constant: 8),
            cardNumberField.leadingAnchor.constraint(equalTo: cardSectionView.leadingAnchor, constant: 16),
            cardNumberField.trailingAnchor.constraint(equalTo: cardSectionView.trailingAnchor, constant: -16),
            cardNumberField.heightAnchor.constraint(equalToConstant: Constants.regularFieldHeight),
            mmyyLabel.topAnchor.constraint(equalTo: cardNumberField.bottomAnchor, constant: 12),
            mmyyLabel.leadingAnchor.constraint(equalTo: mmyyField.leadingAnchor, constant: 16),
            mmyyField.topAnchor.constraint(equalTo: mmyyLabel.bottomAnchor, constant: 8),
            mmyyField.leadingAnchor.constraint(equalTo: cardSectionView.leadingAnchor, constant: 16),
            mmyyField.heightAnchor.constraint(equalToConstant: Constants.regularFieldHeight),
            mmyyField.widthAnchor.constraint(equalTo: cardSectionView.widthAnchor, multiplier: 0.5, constant: -20),
            cvcField.topAnchor.constraint(equalTo: mmyyField.topAnchor),
            cvcField.leadingAnchor.constraint(equalTo: mmyyField.trailingAnchor, constant: 8),
            cvcField.trailingAnchor.constraint(equalTo: cardSectionView.trailingAnchor, constant: -16),
            cvcField.heightAnchor.constraint(equalToConstant: Constants.regularFieldHeight),
            cvcLabel.topAnchor.constraint(equalTo: mmyyLabel.topAnchor),
            cvcLabel.leadingAnchor.constraint(equalTo: cvcField.leadingAnchor, constant: 16),
            cardholderNameLabel.topAnchor.constraint(equalTo: mmyyField.bottomAnchor, constant: 12),
            cardholderNameLabel.leadingAnchor.constraint(equalTo: cardholderNameField.leadingAnchor, constant: 16),
            cardholderNameField.topAnchor.constraint(equalTo: cardholderNameLabel.bottomAnchor, constant: 8),
            cardholderNameField.leadingAnchor.constraint(equalTo: cardSectionView.leadingAnchor, constant: 16),
            cardholderNameField.trailingAnchor.constraint(equalTo: cardSectionView.trailingAnchor, constant: -16),
            cardholderNameField.heightAnchor.constraint(equalToConstant: Constants.regularFieldHeight),
            cardholderNameField.bottomAnchor.constraint(equalTo: cardSectionView.bottomAnchor, constant: -32),
            
            preferredPaymentMethodCheckBox.topAnchor.constraint(equalTo: cardSectionView.bottomAnchor, constant: 32),
            preferredPaymentMethodCheckBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            preferredPaymentMethodCheckBox.widthAnchor.constraint(equalToConstant: Constants.checkboxSize),
            preferredPaymentMethodCheckBox.heightAnchor.constraint(equalToConstant: Constants.checkboxSize),
            preferredPaymentMethodLabel.topAnchor.constraint(equalTo: preferredPaymentMethodCheckBox.topAnchor),
            preferredPaymentMethodLabel.leadingAnchor.constraint(equalTo: preferredPaymentMethodCheckBox.trailingAnchor, constant: 8),
            preferredPaymentMethodLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            userAgreementCheckBox.topAnchor.constraint(equalTo: preferredPaymentMethodCheckBox.bottomAnchor, constant: 32),
            userAgreementCheckBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            userAgreementCheckBox.widthAnchor.constraint(equalToConstant: Constants.checkboxSize),
            userAgreementCheckBox.heightAnchor.constraint(equalToConstant: Constants.checkboxSize),
            userAgreementLabel.topAnchor.constraint(equalTo: userAgreementCheckBox.topAnchor),
            userAgreementLabel.leadingAnchor.constraint(equalTo: userAgreementCheckBox.trailingAnchor, constant: 8),
            userAgreementLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            addCardButton.heightAnchor.constraint(equalToConstant: Constants.regularButtonHeight),
            addCardButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addCardButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addCardButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16)
        ])
    }
    
    private func isFormValid() -> Bool {
        var isValid = true
        
        if cardNameField.text?.isEmpty ?? true {
            cardNameField.isInWarning = true
            isValid = false
        } else {
            cardNameField.isInWarning = false
        }
        
        if cardNumberField.text?.replacingOccurrences(of: " ", with: "").count != 16 {
            cardNumberField.isInWarning = true
            isValid = false
        } else {
            cardNumberField.isInWarning = false
        }
        
        if let mmyyText = mmyyField.text, mmyyText.count == 5 {
            let components = mmyyText.split(separator: "/")
            if components.count == 2, let month = Int(components[0]), let year = Int(components[1]) {
                if month < 1 || month > 12 || !isValidDate(month: month, year: year) {
                    mmyyField.isInWarning = true
                    isValid = false
                }
            } else {
                mmyyField.isInWarning = true
                isValid = false
            }
        } else {
            mmyyField.isInWarning = true
            isValid = false
        }
        
        if cvcField.text?.count != 3 {
            cvcField.isInWarning = true
            isValid = false
        } else {
            cvcField.isInWarning = false
        }
        
        if let cardholderName = cardholderNameField.text, cardholderName.count < 2 {
            cardholderNameField.isInWarning = true
            isValid = false
        } else {
            cardholderNameField.isInWarning = false
        }
        
        if !userAgreementCheckBox.isChecked {
            userAgreementCheckBox.isInWarning = true
            isValid = false
        } else {
            userAgreementCheckBox.isInWarning = false
        }
        
        return isValid
    }
    
    private func isValidDate(month: Int, year: Int) -> Bool {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2000 + year
        components.month = month
        components.day = 1

        if let date = calendar.date(from: components), date >= Date() {
            return true
        }
        return false
    }
    
    // MARK: - Objc methods
    
    @objc
    private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func userAgreementCheckBoxDidTapped() {
        userAgreementCheckBox.isChecked.toggle()
    }
    
    @objc
    private func preferredPaymentMethodCheckBoxDidTapped() {
        preferredPaymentMethodCheckBox.isChecked.toggle()
    }
    
    @objc
    private func addCardButtonTouchDown() {
        UIView.animate(withDuration: 0.05) {
            self.addCardButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc
    private func addCardButtonTouchUp() {
        UIView.animate(withDuration: 0.05, delay: 0.05, options: [], animations: {
            self.addCardButton.transform = CGAffineTransform.identity
        }, completion: nil)
        
        if isFormValid() {
            do {
                try CoreDataManager.shared.saveCard(cardName: cardNameField.text!,
                                                    cardNumber: cardNumberField.text!,
                                                    cardExpirationDate: mmyyField.text!,
                                                    cardCVC: cvcField.text!,
                                                    cardholderName: cardholderNameField.text!,
                                                    isPreferred: preferredPaymentMethodCheckBox.isChecked)
            } catch {
                let error = error as NSError
                if error.code == 1 {
                    let notification = UserNotification(message: "A payment method with this name already exists.", type: .error)
                    notification.show(in: self)
                } else {
                    UserNotification.show(for: error, in: self)
                }
            }
            
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }

}

// MARK: - Text fields methods

extension AddNewCardVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == cardNumberField {
            return formatCardNumber(textField: textField, range: range, replacementString: string)
        }
        
        if textField == mmyyField {
            let resultString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
            if resultString.count == 2 || resultString.count == 3 {
                if let month = Int(resultString.prefix(2)), month < 1 || month > 12 {
                    return false
                }
            }
            return formatMMYY(textField: textField, range: range, replacementString: string)
        }
        
        if textField == cvcField {
            return formatCVC(textField: textField, range: range, replacementString: string)
        } 
        
        if textField == cardholderNameField {
            return formatCardholderName(textField: textField, range: range, replacementString: string)
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == cardNameField {
            cardNumberField.becomeFirstResponder()
        } else if textField == cardholderNameField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == cardholderNameField {
            cardholderNameField.isInWarning = false
            textField.keyboardType = .asciiCapable
            textField.reloadInputViews()
        } else if let field = textField as? TextField {
            field.isInWarning = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == cardholderNameField {
            textField.text = textField.text?.uppercased()
        }
    }
    
    private func formatCardNumber(textField: UITextField, range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        let formattedString = newString.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
        
        let maxLength = 16
        if formattedString.count > maxLength {
            return false
        }
        
        var formattedNumber = ""
        for (index, character) in formattedString.enumerated() {
            if index % 4 == 0 && index > 0 {
                formattedNumber.append(" ")
            }
            formattedNumber.append(character)
        }
        
        textField.text = formattedNumber
        if formattedString.count == maxLength {
            mmyyField.becomeFirstResponder()
        }
        return false
    }
    
    private func formatMMYY(textField: UITextField, range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        let formattedString = newString.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
        
        let maxLength = 4
        if formattedString.count > maxLength {
            return false
        }
        
        var formattedDate = ""
        for (index, character) in formattedString.enumerated() {
            if index == 2 {
                formattedDate.append("/")
            }
            formattedDate.append(character)
        }
        
        textField.text = formattedDate
        if formattedString.count == maxLength {
            cvcField.becomeFirstResponder()
        }
        return false
    }
    
    private func formatCVC(textField: UITextField, range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        let formattedString = newString.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
        
        let maxLength = 3
        if formattedString.count > maxLength {
            return false
        }
        
        textField.text = formattedString
        if formattedString.count == maxLength {
            cardholderNameField.becomeFirstResponder()
        }
        return false
    }
    
    private func formatCardholderName(textField: UITextField, range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.letters.union(.whitespaces)
        if string.rangeOfCharacter(from: allowedCharacters.inverted) != nil {
            return false
        }
        return true
    }
}

// MARK: - UIGestureRecognizerDelegate

extension AddNewCardVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}
