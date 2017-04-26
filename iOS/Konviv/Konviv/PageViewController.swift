//
//  PageViewController.swift
//  Konviv
//
//  Created by Go-Labs Mac Mini on 24/4/17.
//  Copyright © 2017 Go Labs. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource{
    
    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newVc(viewController: "FirstTab"),
                self.newVc(viewController: "SecondTab"),
                self.newVc(viewController: "ThirdTab")]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.orderedViewControllers.first?.view.backgroundColor = UIColor(patternImage: UIImage(named:"blue-screen")!)
        self.orderedViewControllers[1].view.backgroundColor = UIColor(patternImage: UIImage(named:"gray-screen")!)
        self.orderedViewControllers[2].view.backgroundColor = UIColor(patternImage: UIImage(named:"orange-screen")!)
        self.delegate = self
        self.pageDotsControlConfig()
        self.dataSource = self
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func newVc(viewController: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
       
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
            // return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
            // Uncommment the line below, remove the line above if you don't want the page control to loop.
            // return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    
    //dot indicators
    
    var pageDotsControl = UIPageControl();
    
    func pageDotsControlConfig(){
        pageDotsControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY-270, width: UIScreen.main.bounds.width, height: 50))
        self.pageDotsControl.numberOfPages = orderedViewControllers.count
        self.pageDotsControl.currentPage = 0
        self.pageDotsControl.pageIndicatorTintColor = UIColor(white:1, alpha:0.2)
        self.pageDotsControl.currentPageIndicatorTintColor = UIColor.white
        self.view.addSubview(pageDotsControl)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed :Bool) {
        let pageContent = pageViewController.viewControllers![0]
        self.pageDotsControl.currentPage = orderedViewControllers.index(of:pageContent)!
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
