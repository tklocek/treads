//
//  RunLogCell.swift
//  Treads
//
//  Created by Tomek Klocek on 2019-12-13.
//  Copyright © 2019 Tomek Klocek. All rights reserved.
//

import UIKit

class RunLogCell: UITableViewCell {
    
    // Outlets
    @IBOutlet weak var runDurationLbl: UILabel!
    @IBOutlet weak var totalDistanceLbl: UILabel!
    @IBOutlet weak var averagePaceLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(run: Run){
        runDurationLbl.text = run.duration.formatTimeDurationToString()
        totalDistanceLbl.text = "\(run.distance.metersToKilometers(places: 2)) km"
        averagePaceLbl.text = run.pace.formatTimeDurationToString()
        dateLbl.text = run.date.getDateString()
    }

}
