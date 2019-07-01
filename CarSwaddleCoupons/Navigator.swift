//
//  Navigator.swift
//  CarSwaddleCoupons
//
//  Created by Kyle Kendall on 6/1/19.
//  Copyright © 2019 Kyle. All rights reserved.
//


import UIKit
import Authentication
import CarSwaddleUI
import Store

extension Navigator {
    
    enum Tab: Int, CaseIterable {
        case coupons
        case authorities
        case mechanics
        case settings
        
        fileprivate var name: String {
            switch self {
            case .coupons:
                return "Coupons"
            case .authorities:
                return "Authorities"
            case .settings:
                return "Settings"
            case .mechanics:
                return "Mechanics"
            }
        }
        
    }
    
}

let navigator = Navigator()

final class Navigator: NSObject, NotificationObserver {
    
    private var appDelegate: AppDelegate
    
    public override init() {
        self.appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        super.init()
        self.observe(selector: #selector(didUpdateCurrentUserAuthorities), name: .didUpdateAllAppData, object: nil)
        self.observe(selector: #selector(currentUserAuthoritiesDidChange), name: .currentUserAuthoritiesDidChange, object: nil)
    }
    
    @objc private func didUpdateCurrentUserAuthorities(_ notification: Notification) {
        DispatchQueue.main.async {
            self.resetLoggedInUIIfNeeded()
        }
    }
    
    @objc private func currentUserAuthoritiesDidChange() {
        DispatchQueue.main.async {
            self.resetLoggedInUIIfNeeded()
        }
    }
    
    public func setupWindow() {
        appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
        appDelegate.window?.rootViewController = navigator.initialViewController()
        appDelegate.window?.makeKeyAndVisible()
        
        #if DEBUG
        let tripleTap = UITapGestureRecognizer(target: self, action: #selector(Navigator.didTripleTap))
        tripleTap.numberOfTapsRequired = 3
        tripleTap.numberOfTouchesRequired = 2
        appDelegate.window?.addGestureRecognizer(tripleTap)
        #endif
        
        if AuthController().token != nil {
            //            pushNotificationController.requestPermission()
            showRequiredScreensIfNeeded()
        }
        
        setupAppearance()
    }
    
    private func setupAppearance() {
        let actionButton = ActionButton.appearance()
        
        actionButton.defaultBackgroundColor = .secondary
        actionButton.disabledBackgroundColor = UIColor.secondary.color(adjustedBy255Points: -70).withAlphaComponent(0.9)
        actionButton.defaultTitleFont = UIFont.appFont(type: .semiBold, size: 20)
        actionButton.setTitleColor(.gray3, for: .disabled)
        
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.appFont(type: .semiBold, size: 20) as Any]
        UINavigationBar.appearance().titleTextAttributes = attributes
        UINavigationBar.appearance().barTintColor = .veryLightGray
        UINavigationBar.appearance().isTranslucent = false
        UITextField.appearance().tintColor = .secondary
        
        let selectedTabBarAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(type: .semiBold, size: 10) as Any,
            .foregroundColor: UIColor.secondary
        ]
        UITabBarItem.appearance().setTitleTextAttributes(selectedTabBarAttributes, for: .selected)
        
        let normalTabBarAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.appFont(type: .regular, size: 10) as Any,
            .foregroundColor: UIColor.lightGray
        ]
        UITabBarItem.appearance().setTitleTextAttributes(normalTabBarAttributes, for: .normal)
        UITabBar.appearance().tintColor = .secondary
        
        UISwitch.appearance().tintColor = .secondary
        UISwitch.appearance().onTintColor = .secondary
        UINavigationBar.appearance().tintColor = .secondary
        
        let barButtonTextAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.appFont(type: .semiBold, size: 17) as Any]
        
        for state in [UIControl.State.normal, .highlighted, .selected, .disabled, .focused, .reserved] {
            UIBarButtonItem.appearance().setTitleTextAttributes(barButtonTextAttributes, for: state)
        }
        
        UITableViewCell.appearance().textLabel?.font = UIFont.appFont(type: .regular, size: 14)
        
        //        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = .secondary
        UISearchBar.appearance().tintColor = .secondary
        let textFieldAppearance = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        textFieldAppearance.defaultTextAttributes = [.font: UIFont.appFont(type: .regular, size: 17) as Any]
        
        CustomAlertAction.cancelTitle = NSLocalizedString("Cancel", comment: "Cancel button title")
        
        LabeledTextField.defaultTextFieldFont = UIFont.appFont(type: .regular, size: 15)
        LabeledTextField.defaultLabelNotExistsFont = UIFont.appFont(type: .semiBold, size: 15)
        LabeledTextField.defaultLabelFont = UIFont.appFont(type: .regular, size: 15)
        
        let labeledTextFieldAppearance = LabeledTextField.appearance()
        labeledTextFieldAppearance.underlineColor = .secondary
    }
    
    public func initialViewController() -> UIViewController {
        if AuthController().token == nil {
            let signUp = LoginViewController.viewControllerFromStoryboard()
            let navigationController = signUp.inNavigationController()
            navigationController.navigationBar.barStyle = .black
            navigationController.navigationBar.isHidden = true
            return navigationController
        } else {
            return loggedInViewController
        }
    }
    
    public var loggedInViewController: UIViewController {
        return tabBarController
    }
    
    private var _tabBarController: UITabBarController?
    public var tabBarController: UITabBarController {
        if let _tabBarController = _tabBarController {
            return _tabBarController
        }
        
        var viewControllers: [UIViewController] = []
        for tab in Tab.allCases {
            guard tabIsAllowed(tab: tab) else { continue }
            let viewController = self.viewController(for: tab)
            viewControllers.append(viewController.inNavigationController())
        }
        
        let tabController = UITabBarController()
        tabController.viewControllers = viewControllers
        tabController.delegate = self
        tabController.view.backgroundColor = .white
        
        self._tabBarController = tabController
        
        tabController.view.layoutIfNeeded()
        ContentInsetAdjuster.defaultBottomOffset = tabController.tabBar.bounds.height
        
        return tabController
    }
    
    private func tabIsAllowed(tab: Tab) -> Bool {
        switch tab {
        case .authorities:
            return true
        case .coupons:
            return Authority.currentUser(has: .createCoupons, in: store.mainContext)
        case .settings:
            return true
        case .mechanics:
            return  Authority.currentUser(has: .readMechanics, in: store.mainContext) || Authority.currentUser(has: .editMechanics, in: store.mainContext)
        }
    }
    
    public func navigateToLoggedInViewController() {
        guard let window = appDelegate.window,
            let rootViewController = window.rootViewController else { return }
        let newViewController = loggedInViewController
        newViewController.view.frame = rootViewController.view.frame
        newViewController.view.layoutIfNeeded()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = newViewController
        }) { completed in
            pushNotificationController.requestPermission()
            self.showRequiredScreensIfNeeded()
        }
    }
    
    public func navigateToLoggedOutViewController() {
        guard let window = appDelegate.window,
            let rootViewController = window.rootViewController else { return }
        let login = LoginViewController.viewControllerFromStoryboard()
        let newViewController = login.inNavigationController()
        newViewController.navigationBar.barStyle = .black
        newViewController.navigationBar.isHidden = true
        newViewController.view.frame = rootViewController.view.frame
        newViewController.view.layoutIfNeeded()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = newViewController
        }) { [weak self] completed in
            self?.removeUI()
        }
    }
    
    private func resetLoggedInUIIfNeeded() {
        guard let window = appDelegate.window,
            let rootViewController = window.rootViewController else { return }
        
        var shouldReset: Bool = false
        for v in tabBarController.viewControllers ?? [] {
            guard let tab = tab(from: v) else {
                shouldReset = true
                break
            }
            if !tabIsAllowed(tab: tab) {
                shouldReset = true
            }
        }
        
        guard shouldReset else { return }
        
        removeUI()
        let newViewController = loggedInViewController
        newViewController.view.frame = rootViewController.view.frame
        newViewController.view.layoutIfNeeded()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = newViewController
        }) { completed in
            pushNotificationController.requestPermission()
            self.showRequiredScreensIfNeeded()
        }
    }
    
    private func removeUI() {
        tabBarController.setViewControllers([], animated: true)
        _tabBarController = nil
        _authoritiesViewController = nil
        _couponsViewController = nil
        _settingsViewController = nil
        _mechanicsViewController = nil
    }
    
    private func showRequiredScreensIfNeeded() {
        let viewControllers = requiredViewControllers()
        guard viewControllers.count > 0 else { return }
        
        let navigationDelegateViewController = NavigationDelegateViewController(navigationDelegatingViewControllers: viewControllers)
        navigationDelegateViewController.externalDelegate = self
        presentAtRoot(viewController: navigationDelegateViewController)
    }
    
    private func presentAtRoot(viewController: UIViewController) {
        appDelegate.window?.rootViewController?.present(viewController, animated: true, completion: nil)
    }
    
    private func requiredViewControllers() -> [NavigationDelegatingViewController] {
        let viewControllers: [NavigationDelegatingViewController] = []
        
//        let currentUser = User.currentUser(context: store.mainContext)
//
//        if currentUser?.firstName == nil || currentUser?.lastName == nil {
//            let name = UserNameViewController.viewControllerFromStoryboard()
//            viewControllers.append(name)
//        }
//
//        if currentUser?.phoneNumber == nil {
//            let phoneNumber = PhoneNumberViewController.viewControllerFromStoryboard()
//            viewControllers.append(phoneNumber)
//        }
//
//        if currentUser?.isPhoneNumberVerified == false {
//            let verify = VerifyPhoneNumberViewController()
//            viewControllers.append(verify)
//        }
        
        return viewControllers
    }
    
//    func showEnterNewPasswordScreen(resetToken: String) {
//        let enterPassword = EnterNewPasswordViewController.create(resetToken: resetToken)
//        presentAtRoot(viewController: enterPassword.inNavigationController())
//    }
//
    private var _authoritiesViewController: AuthoritiesViewController?
    private var authoritiesViewController: AuthoritiesViewController {
        if let _authoritiesViewController = _authoritiesViewController {
            return _authoritiesViewController
        }

        let authoritiesViewController = AuthoritiesViewController.viewControllerFromStoryboard()
        let title = NSLocalizedString("Authorities", comment: "Title of tab item.")
        authoritiesViewController.tabBarItem = UITabBarItem(title: title, image: nil, selectedImage: nil)
        _authoritiesViewController = authoritiesViewController
        return authoritiesViewController
    }
    
    private var _mechanicsViewController: MechanicListViewController?
    private var mechanicsViewController: MechanicListViewController {
        if let _mechanicsViewController = _mechanicsViewController {
            return _mechanicsViewController
        }
        
        let mechanicsViewController = MechanicListViewController()
        let title = NSLocalizedString("Mechanics", comment: "Title of tab item.")
        mechanicsViewController.tabBarItem = UITabBarItem(title: title, image: nil, selectedImage: nil)
        mechanicsViewController.title = title
        _mechanicsViewController = mechanicsViewController
        return mechanicsViewController
    }
    
    private var _couponsViewController: CouponsViewController?
    private var couponsViewController: CouponsViewController {
        if let _couponsViewController = _couponsViewController {
            return _couponsViewController
        }
        
        let couponsViewController = CouponsViewController.viewControllerFromStoryboard()
        let title = NSLocalizedString("Coupons", comment: "Title of tab item.")
        couponsViewController.tabBarItem = UITabBarItem(title: title, image: nil, selectedImage: nil)
        _couponsViewController = couponsViewController
        return couponsViewController
    }
    
    private var _settingsViewController: SettingsViewController?
    private var settingsViewController: SettingsViewController {
        if let _settingsViewController = _settingsViewController {
            return _settingsViewController
        }
        
        let settingsViewController = SettingsViewController.viewControllerFromStoryboard()
        let title = NSLocalizedString("Settings", comment: "Title of tab item.")
        settingsViewController.tabBarItem = UITabBarItem(title: title, image: nil, selectedImage: nil)
        _settingsViewController = settingsViewController
        return settingsViewController
    }
    
    private func viewController(for tab: Tab) -> UIViewController {
        switch tab {
        case .coupons:
            return couponsViewController
        case .authorities:
            return authoritiesViewController
        case .settings:
            return settingsViewController
        case .mechanics:
            return mechanicsViewController
        }
    }
    
    private func tab(from viewController: UIViewController) -> Tab? {
        var root: UIViewController
        if let navigationController = viewController as? UINavigationController,
            let navRoot = navigationController.viewControllers.first {
            root = navRoot
        } else {
            root = loggedInViewController
        }
        
        if root == self.couponsViewController {
            return .coupons
        } else if root == self.authoritiesViewController {
            return .authorities
        } else if root == self.settingsViewController {
            return .settings
        } else if root == self.mechanicsViewController {
            return .mechanics
        }
        return nil
    }
    
    lazy private var transition: HorizontalSlideTransition = {
        return HorizontalSlideTransition(delegate: self)
    }()
    
}

#if DEBUG
extension Navigator: TweakViewControllerDelegate {
    
    @objc private func didTripleTap() {
        let allTweaks = Tweak.all
        let tweakViewController = TweakViewController.create(with: allTweaks, delegate: self)
        let navigationController = tweakViewController.inNavigationController()
        
        presentAtRoot(viewController: navigationController)
        //        appDelegate.window?.rootViewController?.present(navigationController, animated: true, completion: nil)
    }
    
    func didDismiss(requiresAppReset: Bool, tweakViewController: TweakViewController) {
        if requiresAppReset {
            logout.logout()
        }
    }
    
}
#endif

extension Navigator: UITabBarControllerDelegate {
    
    private static let didChangeTabEvent = "Did Change Tab"
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        //        guard let tab = self.tab(from: viewController) else { return }
        //        trackEvent(with: Navigator.didChangeTabEvent, attributes: ["Screen": tab.name])
    }
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return transition
    }
    
}

extension Navigator: HorizontalSlideTransitionDelegate {
    
    func relativeTransition(_ transition: HorizontalSlideTransition, fromViewController: UIViewController, toViewController: UIViewController) -> HorizontalSlideDirection {
        guard let fromTab = self.tab(from: fromViewController),
            let toTab = self.tab(from: toViewController) else { return .left }
        return fromTab.rawValue < toTab.rawValue ? .left : .right
    }
    
}


extension Navigator: NavigationDelegateViewControllerDelegate {
    
    func didFinishLastViewController(_ navigationDelegateViewController: NavigationDelegateViewController) {
        appDelegate.window?.rootViewController?.dismiss(animated: true, completion: nil)
        navigateToLoggedInViewController()
    }
    
    func didSelectLogout(_ navigationDelegateViewController: NavigationDelegateViewController) {
        appDelegate.window?.endEditing(true)
        logout.logout()
    }
    
}

