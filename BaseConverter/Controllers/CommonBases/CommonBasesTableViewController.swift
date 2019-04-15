//
//  ViewController.swift
//  BaseConverter
//
//  Created by Dai Tran on 4/20/18.
//  Copyright © 2018 Dai Tran. All rights reserved.
//

import UIKit
import GoogleMobileAds
import MessageUI

class CommonBasesTableViewController: UIViewController {

    let cellId = "cellId"
    
    var bases = [Base(baseLabelText: "BIN", baseTextFieldTag: 0, baseTextFieldText: nil),
                 Base(baseLabelText: "OCT", baseTextFieldTag: 1, baseTextFieldText: nil),
                 Base(baseLabelText: "DEC", baseTextFieldTag: 2, baseTextFieldText: nil),
                 Base(baseLabelText: "HEX", baseTextFieldTag: 3, baseTextFieldText: nil)]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(CommonBasesTableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
        
    var bannerView: GADBannerView?
    
    var interstitial: GADInterstitial?

    var isLightTheme = UserDefaults.standard.bool(forKey: isLightThemeKey)
    
    var isFreeVersion = Bundle.main.infoDictionary?["isFreeVersion"] as? Bool ?? true

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return isLightTheme ? .default : .lightContent
    }
    
    override func viewDidLoad() {
        view.addSubview(tableView)
        
        setupAds()
        setupTableView()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "home"), style: .done, target: self, action: #selector(didTapHome))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "refresh"), style: .plain, target: self, action: #selector(refreshButtonAction))
        self.title = NSLocalizedString("CommonBases", comment: "")
        
        if UserDefaults.standard.object(forKey: isLightThemeKey) == nil {
            UserDefaults.standard.set(true, forKey: isLightThemeKey)
        }
        
        if UserDefaults.standard.object(forKey: decimalPlaceKey) == nil {
            UserDefaults.standard.set(20, forKey: decimalPlaceKey)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadThemeAndUpdateFormat()
    }
    
    @objc func didTapHome() {
        let menuViewController = MenuViewController()
        menuViewController.delegate = self
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: menuViewController)
        
        SideMenuManager.default.menuLeftNavigationController?.navigationBar.backgroundColor = .blue
        SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    @objc func refreshButtonAction() {
        for i in 0..<bases.count {
            bases[i].baseTextFieldText = nil
        }
        guard let visibleCells = tableView.visibleCells as? [CommonBasesTableViewCell] else { return }
        for i in 0..<visibleCells.count {
            let index = visibleCells[i].tag
            visibleCells[i].base = bases[index]
        }
    }
    
    func setupTableView() {
        tableView.constraintTo(top: view.layoutMarginsGuide.topAnchor, bottom: view.layoutMarginsGuide.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, topConstant: 0, bottomConstant: 0, leftConstant: 0, rightConstant: 0)
    }
    
    func setupAds() {
        if isFreeVersion {
            bannerView = createAndLoadBannerView()
            interstitial = createAndLoadInterstitial()
        }
    }
    
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: completion)
    }
    
    
    func presentAlert(title: String, message: String, isUpgradeMessage: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Done", comment: ""), style: .cancel, handler: {(action) in
            self.setNeedsStatusBarAppearanceUpdate()
        }))
        if (isUpgradeMessage) {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Upgrade", comment: ""), style: .default, handler: { (action) in
                self.setNeedsStatusBarAppearanceUpdate()
                self.rateApp(appId: appId) { success in
                    print("RateApp \(success)")
                }
            }))
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    func loadThemeAndUpdateFormat() {
        isLightTheme = UserDefaults.standard.bool(forKey: isLightThemeKey)
        
        self.tableView.backgroundColor = isLightTheme ? UIColor.white : UIColor.black
        
        navigationController?.navigationBar.barTintColor = isLightTheme ? UIColor.white : UIColor.black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: isLightTheme ? UIColor.black : UIColor.white]
        navigationController?.navigationBar.tintColor = isLightTheme ? UIColor.deepBlue : UIColor.orange
        
        tabBarController?.tabBar.tintColor = isLightTheme ? UIColor.deepBlue : UIColor.orange
        tabBarController?.tabBar.barTintColor = isLightTheme ? UIColor.white : UIColor.black
        
        setNeedsStatusBarAppearanceUpdate()
        
        view.backgroundColor = isLightTheme ? UIColor.white : UIColor.black
        
        guard let visibleCells = tableView.visibleCells as? [CommonBasesTableViewCell] else { return }
        for i in 0..<visibleCells.count {
            visibleCells[i].backgroundColor = view.backgroundColor
            visibleCells[i].updateColor()
            let tag = visibleCells[i].tag
            visibleCells[i].base = bases[tag]
        }
    }
}

extension CommonBasesTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CommonBasesTableViewCell
        cell.base = bases[indexPath.row]
        cell.tag = indexPath.row
        cell.updateColor()
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }

}

extension CommonBasesTableViewController: CommonTableViewCellDelegate {
    func presentCopiedAlert(message: String) {
        self.presentAlert(title: message, message: "", isUpgradeMessage: false)
    }
    
    func updateAllBases(bases: [Base], excepted tag: Int) {
        self.bases = bases
        guard let visibleCells = tableView.visibleCells as? [CommonBasesTableViewCell] else { return }
        for i in 0..<visibleCells.count {
            if i == tag {
                continue
            }
            let index = visibleCells[i].tag
            visibleCells[i].base = bases[index]
        }
    }
}


extension CommonBasesTableViewController: MenuViewControllerDelegate {
    func presentSetting() {
        let vc = SettingViewController()
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.navigationItem.title = "Setting"
        self.present(navigationVC, animated: true, completion: nil)
    }
    
    func presentMailComposer() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
    }
    
    func presentRatingAction() {
        let appIdString = isFreeVersion ? appIdFree : appId
        rateApp(appId: appIdString) { success in
            print("RateApp \(success)")
        }
    }
    
    func presentShareAction() {
        let appIdString = isFreeVersion ? appIdFree : appId
        let message: String = "https://itunes.apple.com/app/\(appIdString)"
        let vc = UIActivityViewController(activityItems: [message], applicationActivities: [])
        vc.popoverPresentationController?.sourceView = self.view
        present(vc, animated: true)
    }
}

extension CommonBasesTableViewController:  MFMailComposeViewControllerDelegate {
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["universappteam@gmail.com"])
        mailComposerVC.setSubject("[Base-Converter++ Feedback]")
        
        return mailComposerVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension CommonBasesTableViewController : GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        
        // Reposition the banner ad to create a slide down effect
        let translateTransform = CGAffineTransform(translationX: 0, y: -bannerView.bounds.size.height)
        bannerView.transform = translateTransform
        
        UIView.animate(withDuration: 0.5) {
            self.tableView.tableHeaderView?.frame = bannerView.frame
            bannerView.transform = CGAffineTransform.identity
            self.tableView.tableHeaderView = bannerView
        }
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
}

extension CommonBasesTableViewController : GADInterstitialDelegate {
    private func createAndLoadInterstitial() -> GADInterstitial? {
        let adUnitID = debug ? interstialAdsUnitIDTrial : interstialAdsUnitID
        interstitial = GADInterstitial(adUnitID: adUnitID)
        
        guard let interstitial = interstitial else {
            return nil
        }
        
        let request = GADRequest()
        // Remove the following line before you upload the app
        request.testDevices = [ kGADSimulatorID ]
        interstitial.load(request)
        interstitial.delegate = self
        
        return interstitial
    }
    
    private func createAndLoadBannerView() -> GADBannerView? {
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        guard let bannerView = bannerView else {
            return nil
        }
        bannerView.adUnitID = debug ? bannerAdsUnitIDTrial : bannerAdsUnitID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
        return bannerView
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        presentAlert(title: NSLocalizedString("Appname", comment: ""), message: NSLocalizedString("UpgradeMessage", comment: ""), isUpgradeMessage: true)
    }
    
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        presentAlert(title: NSLocalizedString("Appname", comment: ""), message: NSLocalizedString("UpgradeMessage", comment: ""), isUpgradeMessage: true)
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        ad.present(fromRootViewController: self)
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        presentAlert(title: NSLocalizedString("Appname", comment: ""), message: NSLocalizedString("UpgradeMessage", comment: ""), isUpgradeMessage: true)
    }
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
