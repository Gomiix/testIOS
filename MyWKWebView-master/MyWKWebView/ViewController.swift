//
//  ViewController.swift
//  Hive Mind Solutions S.L.
//

import UIKit
import WebKit


class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    
    @IBOutlet var fcmTokenMessage: UILabel!
    @IBOutlet var remoteFCMTokenMessage: UILabel!
    
    // MARK: - Private
    private let searchBar = UISearchBar()
    public var webView: WKWebView!
    private let refreshControl = UIRefreshControl()
    private let searchPath = "/search?q="
    public var baseUrl = AppDelegate.GlobalVariable.urlToken
    public var tokenId = AppDelegate.GlobalVariable.fToken

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
      
        //esto no hace falta descomntar a no ser que se queira poner una toolbar inferior para colocar flechas de back y forward
        // Navigation buttons
        //backButton.isEnabled = false
        //forwardButton.isEnabled = false
        
        // Search bar
        //self.navigationItem.titleView = searchBar
        //searchBar.delegate = self
        
      
        
        // Web view
        let webViewPrefs = WKPreferences()
        webViewPrefs.javaScriptEnabled = true
        webViewPrefs.javaScriptCanOpenWindowsAutomatically = true
        let webViewConf = WKWebViewConfiguration()
        webViewConf.preferences = webViewPrefs
        webView = WKWebView(frame: view.frame, configuration: webViewConf)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.scrollView.keyboardDismissMode = .onDrag
        view.addSubview(webView)
        webView.navigationDelegate = self
        
        // Refresh control
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
        webView.scrollView.addSubview(refreshControl)
        view.bringSubview(toFront: refreshControl)
        print("la url a cargar es: ", baseUrl);
        load(url: baseUrl)

        



        
        /*
        NotificationCenter.default.addObserver(
             self,
             selector: #selector(displayFCMToken(notification:)),
             name: Notification.Name("FCMToken"),
             object: nil
           )
 */
         }
    
   

    // MARK: - Private methods
    
    private func load(url: String) {
        
        
        var loaded = false
        func load() {
            if !loaded {
                print("-----------RECARGA DEL WEBVIEW-------------")
                webView.reload()
            }
            loaded = true
        }

        
        
        
        var urlToLoad: URL!
        if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
            urlToLoad = url
        } else {
            urlToLoad = URL(string: "\(baseUrl)\(searchPath)\(url)")!
        }
        webView.load(URLRequest(url: urlToLoad))
    }
    
    @objc private func reload() {
        webView.reload()
    }
    
}


// MARK: - UISearchBarDelegate

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.endEditing(true)
        load(url: searchBar.text ?? "")
    }
    
}

// MARK: - WKNavigationDelegate

extension ViewController: WKNavigationDelegate {
    
    // Finish
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let javascript = "localStorage.setItem('fcm', '\(tokenId)')"
        let javascriptAux = "localStorage.setItem('os', 'ios')"
        print("EL CÓDIGO JS QUE SE EJECUTA ES : \(javascript)")
    
        webView.evaluateJavaScript(javascript) { (_, err) in ViewController.load()}
        
        webView.evaluateJavaScript(javascriptAux) { (_, err) in ViewController.load()}
        
        
        refreshControl.endRefreshing()
        // si se quiere poner botones de back y forward para que refresque sino funciona preguntarme 
        //backButton.isEnabled = webView.canGoBack
        //forwardButton.isEnabled = webView.canGoForward
        view.bringSubview(toFront: refreshControl)
    }
    
    // Start
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        refreshControl.beginRefreshing()
        searchBar.text = webView.url?.absoluteString
    }
    
    
    

    // Error
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        refreshControl.beginRefreshing()
        view.bringSubview(toFront: refreshControl)
    }
    
}
/** descomentar esto para las notificaciones
 
@IBAction func handleLogTokenTouch(_ sender: UIButton) {
   // [START log_fcm_reg_token]
   let token = Messaging.messaging().fcmToken
   print("FCM token: \(token ?? "")")
   // [END log_fcm_reg_token]
   fcmTokenMessage.text = "Logged FCM token: \(token ?? "")"

   // [START log_iid_reg_token]
   Messaging.messaging().token { token, error in
     if let error = error {
       print("Error fetching remote FCM registration token: \(error)")
     } else if let token = token {
       print("Remote instance ID token: \(token)")
       self.remoteFCMTokenMessage.text = "Remote FCM registration token: \(token)"
     }
   }
   // [END log_iid_reg_token]
}
 @IBAction func handleSubscribeTouch(_ sender: UIButton) {
    // [START subscribe_topic]
    Messaging.messaging().subscribe(toTopic: "weather") { error in
      print("Subscribed to weather topic")
    }
    // [END subscribe_topic]
  }

  @objc func displayFCMToken(notification: NSNotification) {
    guard let userInfo = notification.userInfo else { return }
    if let fcmToken = userInfo["token"] as? String {
      fcmTokenMessage.text = "Received FCM token: \(fcmToken)"
    }
  }
*/


