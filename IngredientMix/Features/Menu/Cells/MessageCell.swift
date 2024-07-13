//
//  MessageCell.swift
//  IngredientMix
//

import UIKit

class MessageCell: UITableViewCell {
    static let id = "MessageCell"

    var message = "" {
        didSet {
            messageLabel.text = message
            setupUI()
        }
    }
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .white
        label.text = "Mon 14:33"
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Raleway", size: 14)
        label.textColor = .white
        label.numberOfLines = 1
        return label
    }()
    
    private func setupUI() {
        backgroundColor = .clear
        addSubview(timeLabel)
        addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            timeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    func setAsNoMessagesCell() {
        backgroundColor = .clear
        addSubview(messageLabel)
        
        messageLabel.text = "You don't have any messages yet"
        
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
