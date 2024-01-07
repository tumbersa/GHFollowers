//
//  FollowerListVC.swift
//  GHFollowers
//
//  Created by Глеб Капустин on 30.12.2023.
//

import UIKit


class FollowerListVC: GFDataLoadingVC {
    
    enum Section {
        case main
    }
    
    var username: String!
    var followers: [Follower]           = []
    var filteredFollowers: [Follower]   = []
    var page                            = 1
    var hasMoreFollowers                = true
    var isSearching                     = false
    var isLoadingMoreFollowers          = false
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!
    
    init(username: String) {
        super.init(nibName: nil, bundle: nil)
        self.username   = username
        title           = username
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureVC()
        configureSearchController()
        configureCollectionView()
        getFollowers(username: username, page: page)
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    func configureVC() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButoon = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButoon
    }
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
    }
    
    func configureSearchController(){
        let searchController                    = UISearchController()
        searchController.searchResultsUpdater   = self
        searchController.searchBar.placeholder  = "Search for a username"
        navigationItem.searchController         = searchController
    }
    
    func getFollowers(username: String, page: Int) {
        showLoadingView()
        isLoadingMoreFollowers = true
        
        if #unavailable(iOS 15.0) {
            NetworkManager.shared.getFollowers(for: username, page: page) {[weak self] result in
                guard let self else { return }
                self.dismissLoadingView()
                switch result {
                case .success(let followers):
                    self.updateUI(with: followers)
                case .failure(let error):
                    self.presentGFAlert(
                        title: "Bad Stuff Happend",
                        message: error.rawValue,
                        buttonTitle: "Ok",
                        isQueueUnused: false)
                }
                self.isLoadingMoreFollowers = false
            }
        } else {
            Task {
                defer {
                    dismissLoadingView()
                    isLoadingMoreFollowers = false
                }
                
                do {
                    let followers = try await NetworkManager.shared.getFollowers(for: username, page: page)
                    updateUI(with: followers)
                } catch {
                    if let gfError = error as? GFError {
                        presentGFAlert(title: "Bad Stuff Happend",message: gfError.rawValue, buttonTitle: "Ok")
                    } else {
                        presentDefaultError()
                    }
                }
                
                ///No special error handling
//                guard let followers = try? await NetworkManager.shared.getFollowers(for: username, page: page) else {
//                    presentDefaultError()
//                    return
//                }
//                updateUI(with: followers)
            }
        }
    }
    
    func updateUI(with followers: [Follower]) {
        if followers.count < 100 { self.hasMoreFollowers = false }
        self.followers.append(contentsOf: followers)
        
        if self.followers.isEmpty {
            let message = "This user doesn't have any followers. Go follow them 🙂"
            DispatchQueue.main.async {
                self.showEmptyStateView(with: message, in: self.view)
            }
        }
        self.updateData(on: self.followers)
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Follower>(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, follower) -> UICollectionViewCell? in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerCell.reuseID, for: indexPath) as! FollowerCell
                cell.set(follower: follower)
                return cell
        })
    }
    
    func updateData(on followers: [Follower]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    @objc func addButtonTapped() {
        showLoadingView()
        
        guard #available(iOS 15.0, *) else {
            NetworkManager.shared.getUserInfo(for: username) {[weak self] result in
                guard let self else { return }
                self.dismissLoadingView()
                switch result {
                case .success(let user):
                    self.addUserToFavorites(user: user)
                case .failure(let error):
                    self.presentGFAlert(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok", isQueueUnused: false)
                }
            }
        }
        
        Task {
            defer {
                dismissLoadingView()
            }
            
            do {
                let user = try await NetworkManager.shared.getUserInfo(for: username)
                addUserToFavorites(user: user)
            } catch {
                if let gfError = error as? GFError {
                    presentGFAlert(title: "Something went wrong", message: gfError.rawValue, buttonTitle: "Ok")
                } else {
                    presentDefaultError()
                }
            }
        }
    }
    
    func addUserToFavorites(user: User) {
        let favorite = Follower(login: user.login, avatarUrl: user.avatarUrl)
        
        PersistenceManager.updateWith(favorite: favorite, actionType: .add) {[weak self] error in
            guard let self else { return }
            guard let error else {
                self.presentGFAlert(title: "Success!", message: "You have successfuly favorited this user🎉", buttonTitle: "Yeeeeeih", isQueueUnused: false)
                return
            }
            
            self.presentGFAlert(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok", isQueueUnused: false)
        }
    }
}


extension FollowerListVC: UICollectionViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY         = scrollView.contentOffset.y
        let contentHeight   = scrollView.contentSize.height
        let height          = scrollView.frame.height
        
        if offsetY > contentHeight - height {
            guard hasMoreFollowers, !isLoadingMoreFollowers else { return }
            page += 1
            getFollowers(username: username, page: page)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activeArray         = isSearching ? filteredFollowers : followers
        let follower            = activeArray[indexPath.item]
        
        let destinationVC       = UserInfoVC()
        destinationVC.delegate  = self
        destinationVC.username  = follower.login
        let navigationVC        = UINavigationController(rootViewController: destinationVC)
        present(navigationVC, animated: true)
    }
}

extension FollowerListVC: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text,
              !filter.isEmpty else {
            filteredFollowers.removeAll()
            updateData(on: followers)
            isSearching = false
            return
        }
        
        isSearching = true
        filteredFollowers = followers.filter({
            $0.login.lowercased().contains(filter.lowercased())
        })
        updateData(on: filteredFollowers)
    }
}

extension FollowerListVC: UserInfoVCDelegate {
    func didRequestFollowers(for username: String) {
        self.username   = username
        title           = username
        page            = 1
        followers.removeAll()
        filteredFollowers.removeAll()
        
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        getFollowers(username: username, page: page)
    }
}
