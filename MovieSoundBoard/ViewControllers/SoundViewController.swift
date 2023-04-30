//
//  SoundViewController.swift
//  MovieSoundBoard
//
//  Created by Yuval Anteby on 27/03/2022.
//

import UIKit
import StreamingKit
import SDWebImage
import GoogleMobileAds

class SoundViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADFullScreenContentDelegate, GADBannerViewDelegate{
    
    var soundJSON_Default = URL(string: "https://firebasestorage.googleapis.com/v0/b/series-304ee.appspot.com/o/MovieSoundboardIOS%2FSound-JSON-IOS.json?alt=media&token=e79d1c62-b704-40c7-801b-ad16bdb26b44")
    var movieJSON_Default = URL(string:"https://firebasestorage.googleapis.com/v0/b/series-304ee.appspot.com/o/MovieSoundboardIOS%2FMovies-JSON-IOS.json?alt=media&token=a9fadb38-9d6d-4fe2-a81a-d94aac4dbb1a")
    
    var soundJSONurl:URL?
    var chosenStudio:String?
    @IBOutlet weak var soundTableView: UITableView!
    var allSounds = [SoundClass]()
    var chosenSounds = [SoundClass]()
    var audioURL:URL?
    let audioPlayer: STKAudioPlayer = STKAudioPlayer()
    
    @IBOutlet weak var bannerView: GADBannerView!
    private var interstitial: GADInterstitialAdBeta?
    var count = 0
    
    ///Return amount of elements in chosen sounds array
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chosenSounds.count
    }
    
    ///Setting up the cell design
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = soundTableView.dequeueReusableCell(withIdentifier: "soundTVC") as! SoundTVC
        cell.soundImgView.sd_setImage(with: URL(string: chosenSounds[indexPath.row].img))
        cell.soundNameLbl.text = chosenSounds[indexPath.row].name
        cell.soundView.layer.cornerRadius = 30
        cell.soundNameLbl.layer.cornerRadius = 30
        cell.soundView.layer.masksToBounds = true
        return cell
    }
    
    ///Clicked row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        audioPlayer.stop()
        audioURL = URL(string: chosenSounds[indexPath.row].sound)
        audioPlayer.play(audioURL!)
        count = count + 1
        if interstitial != nil && count % 5 == 0 {
            interstitial?.present(fromRootViewController: self)
          }
        else{print("Ad not ready")}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = chosenStudio
        setupAds()
        parseJSON(){
            self.chosenSounds = self.allSounds.filter { $0.studio.lowercased().contains(self.chosenStudio?.lowercased() ?? "") }
            self.soundTableView.reloadData()
            print("")
        }
        self.soundTableView.delegate = self
        self.soundTableView.dataSource = self
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.backgroundColor = UIColor.darkGray
            self.navigationItem.standardAppearance = navBarAppearance
            self.navigationItem.scrollEdgeAppearance = navBarAppearance
        }
    }
    
    ///Parsing JSON file
    func parseJSON(completed: @escaping() -> ()) {
        URLSession.shared.dataTask(with: soundJSONurl!) { (data, response, error) in
            
            if error == nil{
                do {
                    self.allSounds = try JSONDecoder().decode([SoundClass].self, from: data!)
                    DispatchQueue.main.async {
                        completed()
                    }
                } catch {
                    let er = "ERROR: "
                    print(er + String(describing: error))
                }
            }
        }.resume()}
    
    ///Setting up ads (banner & interstitial)
    private func setupAds() {
        ///Bannner
        bannerView.adUnitID = "ca-app-pub-8435112864602169/4814232427"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        ///Interstitial
        let request = GADRequest()
           GADInterstitialAdBeta.load(withAdUnitID:"ca-app-pub-8435112864602169/7057252389",
                                       request: request,
                             completionHandler: { [self] ad, error in
                               if let error = error {
                                 print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                 return
                               }
                               interstitial = ad
                               interstitial?.fullScreenContentDelegate = self
                             })
    }
    
      /// Tells the delegate that the ad failed to present full screen content.
      func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
      }

      /// Tells the delegate that the ad presented full screen content.
      func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present full screen content.")
      }

      /// Tells the delegate that the ad dismissed full screen content.
      func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
      }
    
    /// If user pressed back button stop the audio
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            audioPlayer.stop()
        }
    }
}
