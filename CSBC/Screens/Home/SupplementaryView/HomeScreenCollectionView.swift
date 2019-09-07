//
//  HomeScreenCollectionView.swift
//  CSBC
//
//  Created by Luke Redmore on 9/6/19.
//  Copyright © 2019 Catholic Schools of Broome County. All rights reserved.
//

import UIKit

class HomeScreenCollectionView: UICollectionView {
    
    private var columnLayout : ColumnFlowLayout {
        let layout = ColumnFlowLayout(
        cellsPerRow: 3,
        minimumInteritemSpacing: (UIScreen.main.bounds.width)/15.88,
        minimumLineSpacing: (UIScreen.main.bounds.height-133)/15.88,
        sectionInset: UIEdgeInsets(top: 30.0, left: 10.0, bottom: 30.0, right: 10.0)
        )
        layout.cellsPerRow = UIDevice.current.orientation.isLandscape ? 4 : 3
        layout.minimumInteritemSpacing = (UIScreen.main.bounds.width)/9
        layout.minimumLineSpacing = (UIScreen.main.bounds.height-133)/12
        if UIScreen.main.bounds.width == 1366 {
            layout.minimumLineSpacing = (UIScreen.main.bounds.height-133)/9
            layout.sectionInset = UIEdgeInsets(top: 35.0, left: 85.0, bottom: 20.0, right: 85.0)
        } else if UIScreen.main.bounds.width == 1112 {
            layout.sectionInset = UIEdgeInsets(top: 60.0, left: 85.0, bottom: 20.0, right: 85.0)
        } else if UIScreen.main.bounds.height == 1366 {
            layout.sectionInset = UIEdgeInsets(top: 20.0, left: 85.0, bottom: 20.0, right: 85.0)
        } else if traitCollection.horizontalSizeClass == .regular && UIDevice.current.orientation.isLandscape {
            layout.sectionInset = UIEdgeInsets(top: 35.0, left: 85.0, bottom: 20.0, right: 85.0)
        } else if traitCollection.horizontalSizeClass == .regular {
            layout.sectionInset = UIEdgeInsets(top: 30.0, left: 60.0, bottom: 30.0, right: 60.0)
        } else {
            print("Application is running on an iPhone")
            layout.minimumInteritemSpacing = 0//(UIScreen.main.bounds.width)/16
            layout.minimumLineSpacing = (UIScreen.main.bounds.height-133)/15.88
            layout.sectionInset = UIEdgeInsets(top: 30.0, left: 10.0, bottom: 30.0, right: 10.0)
        }
        return layout
    }

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: columnLayout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
