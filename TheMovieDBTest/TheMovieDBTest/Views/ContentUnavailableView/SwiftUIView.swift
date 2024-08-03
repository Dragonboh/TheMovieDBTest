//
//  SwiftUIView.swift
//  TheMovieDBTest
//
//  Created by admin on 03.08.2024.
//

import SwiftUI

struct ContentUnavailableView: View
{
    var title: LocalizedStringKey
    var systemImage: String
    var descriptionText: Text?

    init(_ title: LocalizedStringKey, systemImage: String, description: Text? = nil)
    {
        self.title = title
        self.systemImage = systemImage
        descriptionText = description
    }

    var body: some View
    {
        VStack
        {
            Image(systemName: systemImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80)
                .padding()
            Text(title)
                .font(.headline)
            if let descriptionText = descriptionText
            {
                descriptionText
                    .font(.subheadline)
            }
        }
    }
}

#Preview {
    ContentUnavailableView(.init("Preview"),
                           systemImage: "xmark.icloud",
                           description: Text("No movies"))
}
