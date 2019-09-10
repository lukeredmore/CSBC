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
        if UIDevice.current.orientation.isLandscape {
            print("Application is running on a landscape iPad")
            let layout = ColumnFlowLayout(
                cellsPerRow: 4,
                minimumInteritemSpacing: (bounds.width - 360)/4,
                minimumLineSpacing: (bounds.height - 390)/3,
                sectionInset: UIEdgeInsets(top: (bounds.height - 390)/6, left: (bounds.width - 360)/8, bottom: (bounds.height - 390)/6, right: (bounds.width - 360)/8)
            )
            return layout
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            print("Application is running on a portrait iPad")
            let layout = ColumnFlowLayout(
            cellsPerRow: 3,
            minimumInteritemSpacing: (bounds.width - 260)/3,
            minimumLineSpacing: (bounds.height - 520)/4,
            sectionInset: UIEdgeInsets(top: (bounds.height - 520)/8, left: (bounds.width - 270)/6, bottom: (bounds.height - 520)/8, right: (bounds.width - 270)/6)
            )
            return layout
        } else {
            print("Application is running on a portrait iPhone")
            let layout = ColumnFlowLayout(
                cellsPerRow: 3,
                minimumInteritemSpacing: (bounds.width - 270)/3,
                minimumLineSpacing: 65,
                sectionInset: UIEdgeInsets(top: 30.0, left: (bounds.width - 270)/6, bottom: 30.0, right: (bounds.width - 270)/6)
            )
            return layout
        }
    }
    
    init(frame: CGRect) {
        super.init(frame: frame, collectionViewLayout: UICollectionViewLayout())
        collectionViewLayout = columnLayout
        backgroundColor = .csbcBackground
        bounces = true
        alwaysBounceVertical = true
        register(CSBCCollectionViewCell.self, forCellWithReuseIdentifier: "iconCell")
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CSBCCollectionViewCell: UICollectionViewCell {
    private let buttonImageView : UIImageView = {
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
        imgView.contentMode = .scaleAspectFit
        imgView.clipsToBounds = false
        return imgView
    }()
    private let buttonLabel : UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 90, width: 90, height: 40))
        label.font = UIFont(name: "gotham", size: 22)
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        label.clipsToBounds = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.4
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(buttonImageView)
        addSubview(buttonLabel)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func displayContent(image: UIImage?, title: String) {
        buttonImageView.image = image
        buttonLabel.text = title
    }
}

///Custom UICollectionViewFlowLayout supporting a constant number of cells per row
class ColumnFlowLayout: UICollectionViewFlowLayout {
    private var cellsPerRow: CGFloat

    init(cellsPerRow: Int, minimumInteritemSpacing: CGFloat = 0, minimumLineSpacing: CGFloat = 0, sectionInset: UIEdgeInsets = .zero) {
        self.cellsPerRow = CGFloat(cellsPerRow)
        super.init()
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.minimumLineSpacing = minimumLineSpacing
        self.sectionInset = sectionInset
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        let marginsAndInsets = sectionInset.left + sectionInset.right + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + (minimumInteritemSpacing * CGFloat(cellsPerRow - 1))
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
        itemSize = CGSize(width: itemWidth, height: itemWidth)
    }
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }

}
