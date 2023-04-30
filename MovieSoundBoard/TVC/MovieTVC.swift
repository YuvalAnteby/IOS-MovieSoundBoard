//
//  MovieTVC.swift
//  MovieSoundBoard
//
//  Created by Yuval Anteby on 26/03/2022.
//

import UIKit

class MovieTVC: UITableViewCell {
    
    
    @IBOutlet weak var movieImg: UIImageView!
    @IBOutlet weak var MovieView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
