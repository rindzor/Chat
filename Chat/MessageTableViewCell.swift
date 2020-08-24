//
//  MessageTableViewCell.swift
//  Chat
//
//  Created by  mac on 2/7/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    
    @IBOutlet weak var textmessageLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var photoMessage: UIImageView!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var bubbleViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var bubbleRightConstraint: NSLayoutConstraint!
    
    // Инициализация перед запуском
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bubbleView.layer.cornerRadius = 15
        bubbleView.clipsToBounds = true
        bubbleView.layer.borderWidth = 0.4
        
        textmessageLabel.numberOfLines = 0
        
        photoMessage.layer.cornerRadius = 15
        photoMessage.clipsToBounds = true
        
        profileImage.layer.cornerRadius = 16
        profileImage.clipsToBounds = true
        
        photoMessage.isHidden = true
        profileImage.isHidden = true
        textmessageLabel.isHidden = true
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoMessage.isHidden = true
        profileImage.isHidden = true
        textmessageLabel.isHidden = true
    }
    
    func configureCell(uid: String, message: Message, image: UIImage){
        let text = message.text
        if !text.isEmpty {
            textmessageLabel.isHidden = false
            textmessageLabel.text = message.text
            
            let widthValue = text.estimateFrameForText(text).width + 40
            
            if widthValue < 75{
                widthConstraint.constant = 75
            }
            else {
                widthConstraint.constant = widthValue
            }
            dateLabel.textColor = .lightGray
           
        }
        else {
            photoMessage.isHidden = false
            photoMessage.loadImage(message.imageUrl)
            bubbleView.layer.borderColor = UIColor.clear.cgColor
            widthConstraint.constant = 235
            dateLabel.textColor = .white
            
        }
        if uid == message.from {
            bubbleView.backgroundColor = UIColor.groupTableViewBackground
            bubbleView.layer.borderColor = UIColor.clear.cgColor
            
            bubbleRightConstraint.constant = 8
            bubbleViewLeftConstraint.constant = UIScreen.main.bounds.width - widthConstraint.constant - bubbleRightConstraint.constant
        }
        else {
            profileImage.isHidden = false
            bubbleView.backgroundColor = UIColor.white
            profileImage.image = image
            bubbleView.layer.borderColor = UIColor.lightGray.cgColor
            
            bubbleViewLeftConstraint.constant = 55
            bubbleRightConstraint.constant = UIScreen.main.bounds.width - widthConstraint.constant  - bubbleViewLeftConstraint.constant
        }
        
        let date = Date(timeIntervalSince1970: message.date)
        let dateString = timeAgoSinceDate(date, currentDate: Date(), numericDates: true)
        dateLabel.text = dateString
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension String{
    func estimateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)], context: nil)
    }
}
