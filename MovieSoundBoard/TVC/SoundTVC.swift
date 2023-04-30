//
//  SoundTVC.swift
//  MovieSoundBoard
//
//  Created by Yuval Anteby on 27/03/2022.
//

import UIKit

class SoundTVC: UITableViewCell {

    @IBOutlet weak var soundView: UIView!
    @IBOutlet weak var soundImgView: UIImageView!
    @IBOutlet weak var soundNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
