//
//  HomeViewController.swift
//  BookPort
//
//  Created by Zhifu Ge on 2016-10-17.
//  Copyright © 2016 Zhifu Ge. All rights reserved.
//

import UIKit

class HomeViewController: UICollectionViewController {
    fileprivate let reuseIdentifier = "Book Cell"
    fileprivate let itemsPerRow: CGFloat = 3
    private let showBookDetailSegueId = "Show book detail"
    private let bookKeeper = BookKeeper.sharedKeeper

    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(dataDidLoad), name: NotificationNames.nearbyBooksDidLoadNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dataDidLoad), name: NotificationNames.userBooksDidLoadNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userDidSignIn), name: NotificationNames.userDidSignInNotification, object: nil)

        self.collectionView?.alwaysBounceVertical = true
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        self.collectionView?.addSubview(refreshControl)

        // load data
        bookKeeper.loadBooks()
    }

    func refresh(sender: UIRefreshControl) {
        bookKeeper.loadBooks()
        sender.endRefreshing()
    }

    @IBAction func didPressSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            // Nearby books
            bookKeeper.isShowingNearbyBooks = true
        default:
            bookKeeper.isShowingNearbyBooks = false
        }

        bookKeeper.loadBooks()
        collectionView?.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        collectionView?.reloadData()
    }

    func dataDidLoad() {
        collectionView?.reloadData()
    }

    func userDidSignIn() {
        bookKeeper.loadBooks()
        collectionView?.reloadData()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookKeeper.numberOfBooks()
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! BookCollectionViewCell

        if let image = bookKeeper.imageForCell(at: indexPath) {
            cell.bookCoverImageView.image = image
        } else {
            cell.backgroundColor = UIColor.red
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: showBookDetailSegueId, sender: indexPath)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = sender as? IndexPath,
            let dvc = segue.destination as? BookDetailViewController {
            dvc.bookCoverImage = bookKeeper.imageForCell(at: indexPath)
            dvc.book = bookKeeper.bookForCell(at: indexPath)
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    private var sectionInsets:UIEdgeInsets  {
        return UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        let height = widthPerItem * 1.6

        return CGSize(width: widthPerItem, height: height)


    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
