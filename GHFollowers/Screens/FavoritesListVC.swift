//
//  FavoritesListVC.swift
//  GHFollowers
//
//  Created by Глеб Капустин on 30.12.2023.
//

import UIKit

class FavoritesListVC: GFDataLoadingVC {
    
    let tableView               = UITableView()
    var favorites: [Follower]   = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureVC()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getFavorites()
    }
    
    @available(iOS 17.0, *)
    override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
        if favorites.isEmpty {
            var config = UIContentUnavailableConfiguration.empty()
            config.image            = .init(systemName: "star")
            config.text             = "No favorites"
            config.secondaryText    = "Add a favorite on the follower list screen"
            contentUnavailableConfiguration = config
        } else {
            contentUnavailableConfiguration = nil
        }
    }
    
    func configureVC(){
        view.backgroundColor    = .systemBackground
        title                   = " Favorites"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureTableView() {
        view.addSubview(tableView)
        tableView.frame         = view.bounds
        tableView.rowHeight     = 80
        tableView.delegate      = self
        tableView.dataSource    = self
        tableView.removeExcessCells()
        
        tableView.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.reuseID)
    }
    
    func getFavorites() {
        PersistenceManager.retrieveFavorites {[weak self] result in
            guard let self else { return }
            switch result {
            case .success(let favorites):
                self.updateUI(with: favorites)
            case .failure(let error):
                self.presentGFAlert(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok", isQueueUnused: false)
            }
        }
    }
    
    func updateUI(with favorites: [Follower]) {
        guard #available(iOS 17.0, *) else {
            if favorites.isEmpty {
                self.showEmptyStateView(with: "No Favorites?\nAdd one on the follower screen", in: self.view)
            } else {
               updateUINotEmptyState(with: favorites)
            }
            return
        }
        
        setNeedsUpdateContentUnavailableConfiguration()
        updateUINotEmptyState(with: favorites)
    }
    
    func updateUINotEmptyState(with favorites: [Follower]) {
        self.favorites = favorites
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.view.bringSubviewToFront(self.tableView)
        }
    }
}

extension FavoritesListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.reuseID) as! FavoriteCell
        let favorite = favorites[indexPath.row]
        cell.set(favorite: favorite)

        return cell
    }
}

extension FavoritesListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favorite    = favorites[indexPath.row]
        let destVC      = FollowerListVC(username: favorite.login)
        
        navigationController?.pushViewController(destVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        PersistenceManager.updateWith(favorite: favorites[indexPath.row], actionType: .remove) { [weak self] error in
            guard let self else { return }
            guard let error else {
                self.favorites.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .left)
                
                if #available(iOS 17.0, *) {
                    setNeedsUpdateContentUnavailableConfiguration()
                } else {
                    if self.favorites.isEmpty {
                        self.showEmptyStateView(with: "No Favorites?\nAdd one on the follower screen", in: self.view)
                    }
                }
                return
            }
            
            self.presentGFAlert(title: "Unable to remove", message: error.rawValue, buttonTitle: "Ok", isQueueUnused: false)
        }
    }
}
