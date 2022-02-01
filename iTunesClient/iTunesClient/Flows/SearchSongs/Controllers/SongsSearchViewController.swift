//
//  SongsSearchViewController.swift
//  iTunesClient
//
//  Created by Alexander Grigoryev on 01.02.2022.
//

import UIKit

final class SongsSearchViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let presenter: SearchViewOutput
    
    private let searchService = ITunesSearchService()
    
    private var searchView: SearchView {
        return self.view as! SearchView
    }
    
    internal var searchResults = [ITunesApp]() {
        didSet {
            self.searchView.tableView.isHidden = false
            self.searchView.tableView.reloadData()
            self.searchView.searchBar.resignFirstResponder()
        }
    }
    
    private struct Constants {
        static let reuseIdentifier = "reuseId"
    }
    
    // MARK: - Lifecycle
    
    init(presenter: SearchViewOutput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.view = SearchView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.searchView.searchBar.delegate = self
        self.searchView.tableView.register(AppCell.self, forCellReuseIdentifier: Constants.reuseIdentifier)
        self.searchView.tableView.delegate = self
        self.searchView.tableView.dataSource = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.throbber(show: false)
    }
    
    // MARK: - Private
    
//    internal func throbber(show: Bool) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = show
//    }
//
//    internal func showError(error: Error) {
//        let alert = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
//        let actionOk = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//        alert.addAction(actionOk)
//        self.present(alert, animated: true, completion: nil)
//    }
//
//    internal func showNoResults() {
//        self.searchView.emptyResultView.isHidden = false
//    }
//
//    internal func hideNoResults() {
//        self.searchView.emptyResultView.isHidden = true
//    }
}

//MARK: - UITableViewDataSource
extension SongsSearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: Constants.reuseIdentifier, for: indexPath)
        guard let cell = dequeuedCell as? AppCell else {
            return dequeuedCell
        }
        let app = self.searchResults[indexPath.row]
        let cellModel = AppCellModelFactory.cellModel(from: app)
        cell.configure(with: cellModel)
        return cell
    }
}

//MARK: - UITableViewDelegate
extension SongsSearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let app = searchResults[indexPath.row]
//        let appDetaillViewController = AppDetailViewController()
//        appDetaillViewController.app = app
        self.presenter.viewDidSelectApp(app)
//        navigationController?.pushViewController(appDetaillViewController, animated: true)
    }
}

//MARK: - UISearchBarDelegate
extension SongsSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else {
            searchBar.resignFirstResponder()
            return
        }
        if query.count == 0 {
            searchBar.resignFirstResponder()
            return
        }
        self.presenter.viewDidSearch(with: query)
    }
}

//MARK: - Input
extension SongsSearchViewController: SearchViewInput {
    
    func showError(error: Error) {
    let alert = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
    let actionOk = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(actionOk)
    self.present(alert, animated: true, completion: nil)
    }
    func showNoResults() {
        self.searchView.emptyResultView.isHidden = false
        self.searchResults = []
        self.searchView.tableView.reloadData()
    }
    
    func hideNoResults() {
        self.searchView.emptyResultView.isHidden = true
    }
    func throbber(show: Bool) { UIApplication.shared.isNetworkActivityIndicatorVisible = show
    }
}
