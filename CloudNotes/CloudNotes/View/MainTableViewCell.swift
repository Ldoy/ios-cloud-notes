//
//  MainTableViewCell.swift
//  CloudNotes
//
//  Created by Do Yi Lee on 2021/09/03.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    private var titleLabel: UILabel!
    private var bodyLabel: UILabel!
    private var dateLabel: UILabel!
    private var dateAndBodyStackView: UIStackView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupTitleLabelLayout()
        makeHorizontalStackVeiw()
        setLabelStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MainTableViewCell {
    func configure(_ dataHolder: CellContentDataHolder) {
        titleLabel.text = dataHolder.titleLabelText
        bodyLabel.text = dataHolder.bodyLabelText
        dateLabel.text = dataHolder.dateLabelText
        self.accessoryType = dataHolder.accessoryType
    }
    
    private func setupTitleLabelLayout() {
        titleLabel = UILabel()
        contentView.addSubview(titleLabel)
        
        titleLabel.setPosition(top: contentView.topAnchor,
                               bottom: contentView.bottomAnchor, bottomConstant: -20,
                               leading: contentView.leadingAnchor,
                               trailing: contentView.trailingAnchor)
    }
    
    private func makeHorizontalStackVeiw() {
        dateLabel = UILabel()
        bodyLabel = UILabel()
        dateAndBodyStackView = UIStackView(arrangedSubviews: [self.dateLabel, self.bodyLabel])
        bodyLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        contentView.addSubview(dateAndBodyStackView)
        let height = 30
        dateAndBodyStackView.setPosition(top: contentView.topAnchor, topConstant: CGFloat(height),
                                         bottom: contentView.bottomAnchor,
                                         leading: contentView.leadingAnchor,
                                         trailing: contentView.trailingAnchor)
        dateAndBodyStackView.axis = .horizontal
        dateAndBodyStackView.distribution = .equalCentering
        dateAndBodyStackView.spacing = 40
        dateAndBodyStackView.topAnchor.constraint(greaterThanOrEqualTo: titleLabel.bottomAnchor)
    }
    
    private func setLabelStyle() {
        setDynamicType(titleLabel, .title3)
        setDynamicType(dateLabel, .body)
        setDynamicType(bodyLabel, .caption1)
        titleLabel.textAlignment = .left
        bodyLabel.textColor = .gray
    }
    
    private func setDynamicType(_ label: UILabel, _ font: UIFont.TextStyle) {
        label.adjustsFontForContentSizeCategory = true
        label.font = UIFont.preferredFont(forTextStyle: font)
    }
}
