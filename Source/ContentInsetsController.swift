//
//  ContentInsetsController.swift
//  edX
//
//  Created by Akiva Leffert on 5/18/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

import UIKit

protocol ContentInsetsSourceDelegate : class {
    func contentInsetsSourceChanged(source : ContentInsetsSource)
}

protocol ContentInsetsSource {
    var currentInsets : UIEdgeInsets { get }
    weak var insetsDelegate : ContentInsetsSourceDelegate? { get set }
}

/// General solution to the problem of edge insets that can change and need to
/// match a scroll view. When we drop iOS 7 support there may be a way to simplify this
/// by using the new layout margins API.
///
/// Other things like pull to refresh can be supported by creating a class that implements `ContentInsetsSource`
/// and providing a way to add it to the `insetsSources` list.
///
/// To use:
///  #. Call `setupInController:scrollView:` in the `viewDidLoad` method of your controller
///  #. Call `updateInsets` in the `viewDidLayoutSubviews` method of your controller
class ContentInsetsController: NSObject, ContentInsetsSourceDelegate {
    
    private var scrollView : UIScrollView?
    private weak var owner : UIViewController?
    
    private var insetSources : [ContentInsetsSource] = []
    
    private var offlineController : OfflineModeController?
    private var styles : OEXStyles
    
    init(styles : OEXStyles) {
        self.styles = styles
    }
    
    func setupInController(owner : UIViewController, scrollView : UIScrollView) {
        self.owner = owner
        self.scrollView = scrollView
        
        offlineController?.setupInController(owner)
    }
    
    func supportOfflineMode() {
        let controller = OfflineModeController(styles: styles)
        controller.insetsDelegate = self
        insetSources.append(controller)
        offlineController = controller
        
        self.owner.map {
            controller.setupInController($0)
        }
    }
    
    private var controllerInsets : UIEdgeInsets {
        let topGuideHeight = self.owner?.topLayoutGuide.length ?? 0
        let bottomGuideHeight = self.owner?.bottomLayoutGuide.length ?? 0
        return UIEdgeInsets(top : topGuideHeight, left : 0, bottom : bottomGuideHeight, right : 0)
    }
    
    func contentInsetsSourceChanged(source: ContentInsetsSource) {
        updateInsets()
    }
    
    func updateInsets() {
        let insets = reduce(insetSources.map { return $0.currentInsets }, controllerInsets, +)
        self.scrollView?.contentInset = insets
        self.scrollView?.scrollIndicatorInsets = insets
    }
}