//
//  ViewController.swift
//  PopulationQuery
//
//  Copyright © 2017 Michael Edgcumbe. All rights reserved.
//

import UIKit

@objc (MainViewController)
@objcMembers class MainViewController: UIViewController {
    
    @IBOutlet weak var startOverBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var fetchButton: UIButton!
    
    /// The view model
    let model = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.delegate = self
        styleForFetchData()
    }
    
    /**
     Button action for tapping the start over navigation bar button item
     */
    @IBAction func onTapStartOver(_ sender: Any) {
        styleForFetchData()
    }
    
    /**
     Button action for tapping the fetch button
     */
    @IBAction func onTapFetch(_ sender: Any) {
        print("Fetching model")
        styleForFetchInProgress()
        model.refresh()
    }
}

extension MainViewController {
    
    /**
     Updates the view hierarchy to show the elements for fetching population data
     - Returns: void
     */
    func styleForFetchData() {
        startOverBarButtonItem.isEnabled = false
        textView.isHidden = true
        textView.text = ""
        fetchButton.isHidden = false
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] in
            self?.fetchButton.alpha = 1.0
        }, completion: nil)
    }
    
    /**
     Updates the view hierarchy to show a fetch in progress
     - Returns: void
     */
    func styleForFetchInProgress() {
        fetchButton.isHidden = true
        fetchButton.alpha = 0.0
        activityView.startAnimating()
    }
    

    /**
     Updates the view hierarchy to show the results of the population query fetch
     - Returns: void
     */
    func styleForResults() {
        activityView.stopAnimating()
        startOverBarButtonItem.isEnabled = true
        textView.contentOffset = CGPoint.zero
        textView.isHidden = false
    }
}

extension MainViewController : ViewModelDelegate {
    /**
     Delegate method callback for model updates
     - Returns: void
     */
    func modelDidUpdate() {
        styleForResults()
        showResults()
    }
    
    /**
     Updates the content for the textview with the model results
     - Returns: void
    */
    private func showResults() {
        textView.text = model.results()
    }
}

