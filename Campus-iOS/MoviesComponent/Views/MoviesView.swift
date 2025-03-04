//
//  MoviesView.swift
//  Campus-iOS
//
//  Created by Milen Vitanov on 27.01.22.
//

import SwiftUI

struct MoviesView: View {
    let movies: [Movie]
    @State private var selectedMovie: Movie? = nil
    
    var items: [GridItem] {
        Array(repeating: .init(.adaptive(minimum: 120)), count: 2)
    }
    
    var body: some View {
        ZStack {
            Text("No more movies this semester 😢\nGet excited for the next season!")
                .foregroundColor(Color(UIColor.lightGray))
            ScrollView(.vertical) {
                LazyVGrid(columns: items, spacing: 10) {
                    ForEach(self.movies, id: \.id ) { movie in
                        MovieCard(movie: movie).padding(7)
                            .onTapGesture {
                                selectedMovie = movie
                            }
                    }
                    .sheet(item: $selectedMovie) { movie in
                        MovieDetailedView(movie: movie)
                    }
                }
                .padding(10)
                .background(Color.systemsBackground)
            }
        }
    }
}

//struct MoviesView_Previews: PreviewProvider {
//    static var previews: some View {
//        MoviesView()
//    }
//}
