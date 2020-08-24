//
//  WalkthroughViewController.swift
//  Chat
//
//  Created by  mac on 2/25/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit

class WalkthroughViewController: UIViewController {
    
    var walkthroughPageVC: WalkthrougPageViewController?
    
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var nextButton: UIButton! {
        didSet {
            nextButton.layer.cornerRadius = 25
            nextButton.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var skipButton: UIButton! 

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        if let index = walkthroughPageVC?.currentIndex {
            switch index {
            case 0...1 :
                walkthroughPageVC?.forwardPage()
                
            case 2 :
                dismiss(animated: true, completion: nil)
                
            default: break
            }
        }
        
        updateUI()
        
    }
    
    func updateUI(){
        if let index = walkthroughPageVC?.currentIndex {
            switch index {
            case 0...1:
                nextButton.setTitle("NEXT", for: .normal)
                skipButton.isHidden = false
            case 2:
                nextButton.setTitle("GET STARTED", for: .normal)
                skipButton.isHidden = true
            default:
                break
            }
             pageControl.currentPage = index
        }
       
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
        //self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let pageVC = destination as? WalkthrougPageViewController {
            walkthroughPageVC = pageVC
        }
    }

}
