//
//  ViewController.swift
//  MovieSoundBoard
//
//  Created by Yuval Anteby on 26/03/2022.
//

import UIKit
import SDWebImage
import GoogleMobileAds
import Firebase
import FirebaseFirestore

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADFullScreenContentDelegate, GADBannerViewDelegate {
    
    var movies = [MovieClass]()
    @IBOutlet weak var movieTableView: UITableView!
    var soundJSON_Default = URL(string: "https://firebasestorage.googleapis.com/v0/b/series-304ee.appspot.com/o/MovieSoundboardIOS%2FSound-JSON-IOS.json?alt=media&token=e79d1c62-b704-40c7-801b-ad16bdb26b44")
    var movieJSON_Default = URL(string:"https://firebasestorage.googleapis.com/v0/b/series-304ee.appspot.com/o/MovieSoundboardIOS%2FMovies-JSON-IOS.json?alt=media&token=a9fadb38-9d6d-4fe2-a81a-d94aac4dbb1a")
    var movieJSON:URL?
    var soundJSON:URL?
    @IBOutlet weak var bannerView: GADBannerView!
    
    ///Return amount of elements in chosen sounds array
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    ///Setting up the cell design
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = movieTableView.dequeueReusableCell(withIdentifier: "movieTVC") as! MovieTVC
        cell.movieImg.sd_setImage(with: URL(string: movies[indexPath.row].studio_img))
        cell.nameLbl.text = movies[indexPath.row].studio_name
        cell.MovieView.layer.cornerRadius = 30
        cell.nameLbl.layer.cornerRadius = 30
        cell.MovieView.layer.masksToBounds = true
        return cell
    }
    
    ///Clicked row (moving to a new screen)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showSounds", sender: self)
    }
    
    ///Preparing a new screen (sending parameters)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SoundViewController{
            destination.soundJSONurl = soundJSON_Default
            destination.chosenStudio = movies[(movieTableView.indexPathForSelectedRow?.row)!].studio_name
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadLinks()
        setupAds()
        parseJSON(){
            self.movieTableView.reloadData()
        }
        movieTableView.delegate = self
        movieTableView.dataSource = self
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
    
    
    private func downloadLinks(){
        let db = Firestore.firestore()
        let docRef = db.collection("movie_board").document("Links")

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                let movieDownload = data?["movies"] as? String ?? ""
                let soundDownload = data?["sounds"] as? String ?? ""
                if  movieDownload != ""{
                    self.movieJSON = URL(string: movieDownload)
                } else {
                    self.movieJSON = self.movieJSON_Default
                }
                if soundDownload != ""{
                    self.soundJSON = URL(string: soundDownload)
                } else {
                    self.soundJSON = self.soundJSON_Default
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    ///Parsing JSON file
    func parseJSON(completed: @escaping() -> ()) {
        URLSession.shared.dataTask(with: movieJSON_Default!) { (data, response, error) in
            
            if error == nil{
                do {
                    self.movies = try JSONDecoder().decode([MovieClass].self, from: data!)
                    DispatchQueue.main.async {
                        completed()
                    }
                } catch {
                    let er = "ERROR: "
                    print(er + String(describing: error))
                }
            }
        }.resume()
    }
    
    ///Setting up ads (banner & interstitial)
    private func setupAds() {
        ///Bannner
        bannerView.adUnitID = "ca-app-pub-8435112864602169/4814232427"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
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
}
