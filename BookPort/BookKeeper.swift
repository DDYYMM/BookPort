//
//  BookKeeper.swift
//  BookPort
//
//  Created by Zhifu Ge on 2016-11-05.
//  Copyright © 2016 Zhifu Ge. All rights reserved.
//

import Foundation

class BookKeeper {
    static let sharedKeeper = BookKeeper()

    var isShowingNearbyBooks = true

    // books around the user
    private var books: [Book]
    // images for books around the user
    private var bookImages: [UIImage]

    // books that belong to the user
    private var userBooks: [Book]
    // images for books that belong to the user
    private var userBookImages: [UIImage]


    private init() {
        books = [Book]()
        bookImages = [UIImage]()

        userBooks = [Book]()
        userBookImages = [UIImage]()
    }

    // MARK: - public interface

    func loadBooks() {
        if isShowingNearbyBooks {
            loadNearbyBooks()
        } else {
            loadUserBooks()
        }
    }

    private func loadNearbyBooks() {
        guard let userId = UserDefaults().string(forKey: Constants.userIdKey) else {
            // User is not signed in yet
            return
        }

        // load books around the user
        let session = URLSession(configuration: .ephemeral)
        if let url = URL(string: "http://thetsntech.in/ios/books.php") {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let params = "user=\(userId)&distance=5"
            request.httpBody = params.data(using: String.Encoding.utf8)
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                    let (books, bookImages) = self.parseJson(with: data)
                    self.books = books
                    self.bookImages = bookImages

                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NotificationNames.nearbyBooksDidLoadNotification, object: nil)
                    }
                }
            })

            task.resume()
        }
    }

    private func loadUserBooks() {
        guard let userId = UserDefaults().string(forKey: Constants.userIdKey) else {
            // User is not signed in yet
            return
        }

        // load user's books
        let session = URLSession(configuration: .ephemeral)
        if let url = URL(string: "http://thetsntech.in/ios/userbook.php?user=\(userId)") {
            let task = session.dataTask(with: url, completionHandler: { (data, response, error) in
                DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                    let (books, bookImages) = self.parseJson(with: data)
                    self.userBooks = books
                    self.userBookImages = bookImages

                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NotificationNames.userBooksDidLoadNotification, object: nil)
                    }
                }
            })

            task.resume()
        }

    }

    func imageForCell(at indexPath: IndexPath) -> UIImage? {
        if isShowingNearbyBooks {
            return bookImages[indexPath.row]
        } else {
            return userBookImages[indexPath.row]
        }
    }

    func bookForCell(at indexPath: IndexPath) -> Book {
        if isShowingNearbyBooks {
            return books[indexPath.row]
        } else {
            return userBooks[indexPath.row]
        }
    }

    func numberOfBooks() -> Int {
        if isShowingNearbyBooks {
            return books.count
        } else {
            return userBooks.count
        }
    }

    // MARK: - private helpers

    private func parseJson(with data: Data?) -> ([Book], [UIImage]){
        print("called parseJson")
        var books = [Book]()
        var images = [UIImage]()

        guard data != nil else {
            return (books, images)
        }

        if let jsonObject = (try? JSONSerialization.jsonObject(with: data!, options: [])) as? [String: Any] {
            if let myBooks = jsonObject["mybooks"] as? [[String: Any]] {
                let totalBookCount = myBooks.count
                var currentBookNumber = 1
                for bookJson in myBooks {
                    if let book = Book(json: bookJson) {
                        books.append(book)
                        if let imageUrl = book.imageUrl,
                            let imageData = try? Data(contentsOf: imageUrl),
                            let image = UIImage(data: imageData) {
                            images.append(image)
                        } else {
                            // can't get image ove internet, put in a empty UIImage
                            bookImages.append(UIImage())
                        }
                        print("added book \(currentBookNumber) of \(totalBookCount)")
                        currentBookNumber += 1

                    }
                }
            }
        }

        return (books, images)
    }
}
