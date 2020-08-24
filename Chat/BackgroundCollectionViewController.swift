//
//  BackgroundCollectionViewController.swift
//  Chat
//
//  Created by  mac on 2/21/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class BackgroundCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wallpapers"
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }


    // MARK: UICollectionViewDataSource


    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BackgroundCollectionViewCell", for: indexPath) as! BackgroundCollectionViewCell
        cell.photo.image = UIImage(named: "wp\(indexPath.row)")
        cell.photo.clipsToBounds = true
        cell.noWallpaperLabel.isHidden = (indexPath.row == 0) ? false : true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(view.frame.width/3 - 2, view.frame.height/2)
        return CGSize(width: view.frame.width/3 - 2, height: view.frame.height/3.25 - 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? BackgroundCollectionViewCell{
            wallpaperName = "wp\(indexPath.row)"
            DEFAULTS.set(wallpaperName, forKey: "wallpaperName")
            self.navigationController?.popViewController(animated: true)
        }
    }


}


