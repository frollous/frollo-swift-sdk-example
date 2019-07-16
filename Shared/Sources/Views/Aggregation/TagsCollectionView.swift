//
//  TagsCollectionView.swift
//  FrolloSDK iOS Example
//
//  Created by Maher Santina on 8/5/19.
//  Copyright © 2019 Frollo. All rights reserved.
//

import UIKit
import FrolloSDK

class TagCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
}

class TagsCollectionView: UICollectionView {
    
    var data: [String] = [] {
        didSet {
            updateView()
        }
    }

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        delegate = self
        dataSource = self
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        dataSource = self
        initView()
    }
    
    func initView() {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        layout.estimatedItemSize = CGSize(width: 50, height: frame.height)
    }
    
    func updateView() {
        reloadData()
    }
}

extension TagsCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let name = data[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TagCollectionViewCell
        cell.nameLabel.text = name
        return cell
    }
}

extension TagsCollectionView: UICollectionViewDelegateFlowLayout {
    
}
