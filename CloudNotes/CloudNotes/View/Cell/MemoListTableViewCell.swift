//
//  MainTableViewCell.swift
//  CloudNotes
//
//  Created by Do Yi Lee on 2021/09/03.
//

import UIKit

final class MemoListTableViewCell: UITableViewCell {
    static let identifier = "cell"
    private var titleLabel: UILabel = UILabel()
    private var bodyLabel: UILabel = UILabel()
    private var dateLabel: UILabel = UILabel()
    private var dateAndBodyStackView: UIStackView = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .disclosureIndicator
        self.setupTitleLabelLayout()
        self.makeHorizontalStackVeiw()
        self.setLabelStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MemoListTableViewCell {
    func configure(_ dataHolder: CellContentDataHolder) {
        self.titleLabel.text = dataHolder.titleLabelText
        self.bodyLabel.text = dataHolder.bodyLabelText
        self.dateLabel.text = dataHolder.dateLabelText
    }
    
    private func setupTitleLabelLayout() {
        self.titleLabel = UILabel()
        self.contentView.addSubview(titleLabel)
        self.titleLabel
            .setPosition(top: contentView.topAnchor,
                         bottom: contentView.bottomAnchor, bottomConstant: -20,
                         leading: safeAreaLayoutGuide.leadingAnchor,
                         leadingConstant: 10,
                         trailing: contentView.trailingAnchor
            )
        
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    private func makeHorizontalStackVeiw() {
        self.dateAndBodyStackView = UIStackView(arrangedSubviews: [self.dateLabel, self.bodyLabel])
        self.dateLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        self.contentView.addSubview(dateAndBodyStackView)
        self.dateAndBodyStackView
            .setPosition(top: titleLabel.bottomAnchor,
                         bottom: contentView.bottomAnchor,
                         leading: titleLabel.leadingAnchor,
                         trailing: contentView.trailingAnchor
            )
        
        self.dateAndBodyStackView.axis = .horizontal
        self.dateAndBodyStackView.distribution = .equalCentering
        self.dateAndBodyStackView.spacing = 40
    }
    
    private func setLabelStyle() {
        self.setDynamicType(titleLabel, .title3)
        self.setDynamicType(dateLabel, .body)
        self.setDynamicType(bodyLabel, .caption1)
        self.titleLabel.textAlignment = .left
        self.bodyLabel.textColor = .gray
    }
    
    private func setDynamicType(_ label: UILabel, _ font: UIFont.TextStyle) {
        label.adjustsFontForContentSizeCategory = true
        label.font = UIFont.preferredFont(forTextStyle: font)
    }
}
