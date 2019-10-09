//
//  HitCell.swift
//  engineer-ai
//
//  Created by Vitalii Yevtushenko on 09.10.2019.
//  Copyright © 2019 ArcherSoft. All rights reserved.
//

import UIKit

protocol HitCellDelegate: class {
    func hitCellSelectionStateChanged(_ cell: HitCell)
}

final class HitCell: UITableViewCell {

    private (set) var hit: Hit?

    weak var delegate: HitCellDelegate?

    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let toggle = UISwitch()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        return formatter
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        self.hit = nil
        toggle.setOn(false, animated: false)
        titleLabel.text = nil
        dateLabel.text = nil
    }

    func setup(hit: Hit, isSelected: Bool) {
        self.hit = hit
        titleLabel.text = hit.title
        dateLabel.text = Self.dateFormatter.string(from: hit.createdAt)
        setSelected(isSelected, animated: false)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        toggle.setOn(isSelected, animated: animated)
        titleLabel.textColor = selected ? .black : .darkGray
        dateLabel.textColor = selected ? .darkGray : .gray
    }

    @objc func toggleAction(_ sender: Any?) {
        delegate?.hitCellSelectionStateChanged(self)
        setSelected(toggle.isOn, animated: true)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .gray

        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .darkGray
        titleLabel.numberOfLines = 0

        toggle.addTarget(self, action: #selector(HitCell.toggleAction(_:)), for: .valueChanged)

        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)

        accessoryView = toggle

        if #available(iOS 9.0, *) {
            NSLayoutConstraint.activate([
                dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                
                titleLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
                titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
            ])
        } else {
            // Fallback on earlier versions
        }
    }

    required init?(coder: NSCoder) {
        fatalError("This class can't be created from xib or storyboard")
    }
}
