//
//  Book.swift
//  BookPort
//
//  Created by Zhifu Ge on 2016-11-06.
//  Copyright © 2016 Zhifu Ge. All rights reserved.
//

import Foundation

struct Book {
    let isbn: String
    let title: String
    let author: String
    let user: String
    let imageUrl: URL?

    init?(json: [String: Any]) {
        guard let isbn = json["isbn"] as? String,
            let user = json["bookuser"] as? String,
            let title = json["title"] as? String,
            let imageLink = json["imageLinks"] as? String,
            let author = json["authors"] as? String
        else {
            return nil
        }

        self.isbn = isbn
        self.user = user
        self.title = title
        self.author = author

        let imageLinkString = imageLink.replacingOccurrences(of: "\\", with: "")
        self.imageUrl = URL(string: imageLinkString)
    }
}
