//
//  WalkthrougPageViewController.swift
//  Chat
//
//  Created by  mac on 2/24/20.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit

class WalkthrougPageViewController: UIPageViewController {
    
    var pageHeadings = ["1", "2", "3"]
    var pageImages = ["onboarding-1", "onboarding-2", "onboarding-3"]
    var pageSubheadings = ["111", "222", "333"]
    var currentIndex = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        if let startingViewController = contentViewController(at: 0) {
            setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
        }
        

        // Do any additional setup after loading the view.
    }
    
    
    
    func forwardPage() {
        currentIndex += 1
        if let nextVC = contentViewController(at: currentIndex) {
            setViewControllers([nextVC], direction: .forward, animated: true, completion: nil)
        }
    }
    

    
    
}



//MARK: - UIPageViewControllerDataSource

extension WalkthrougPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalktroughContentViewController).index
        index -= 1
        
        return contentViewController(at: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
         var index = (viewController as! WalktroughContentViewController).index
           index += 1
           
           return contentViewController(at: index)
    }
    
    func contentViewController(at index: Int) -> WalktroughContentViewController? {
        if index < 0 || index >= pageHeadings.count {
            return nil
        }
        let storyboard = UIStoryboard(name: "OnBoarding", bundle: nil)
        if let pageContentViewController = storyboard.instantiateViewController(withIdentifier: "WalktroughContentViewController") as? WalktroughContentViewController {
            pageContentViewController.imageFile = pageImages[index]
            pageContentViewController.heading = pageHeadings[index]
            pageContentViewController.subHeading = pageSubheadings[index]
            pageContentViewController.index = index
            
            return pageContentViewController
        }
         return nil
    }
    
}
