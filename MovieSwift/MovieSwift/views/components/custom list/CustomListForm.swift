//
//  CustomListForm.swift
//  MovieSwift
//
//  Created by Thomas Ricouard on 18/06/2019.
//  Copyright © 2019 Thomas Ricouard. All rights reserved.
//

import SwiftUI

struct CustomListForm : View {
    @EnvironmentObject var state: AppState

    @State var listName: String = ""
    @State var movieSearch: String = ""
    @State var listMovieCover: Int?
    
    var body: some View {
        NavigationView {
            Form {
                TopSection(listMovieCover: $listMovieCover, movieSearch: $movieSearch, listName: $listName)
                MovieSearchSection(movieSearch: $movieSearch, listMovieCover: $listMovieCover)
                SaveCancelSection(listName: $listName, listMovieCover: $listMovieCover)
            }
            .navigationBarTitle(Text("New list"))
        }
    }
}

struct TopSection: View {
    @EnvironmentObject var state: AppState
    
    @Binding var listMovieCover: Int?
    @Binding var movieSearch: String
    @Binding var listName: String
    
    func onKeyStroke() {
        if !movieSearch.isEmpty {
            state.dispatch(action: MoviesActions.FetchSearch(query: movieSearch))
        }
    }
    
    var body: some View {
        Section(header: Text("List information"),
                content: {
                        TextField($listName, placeholder: Text("Name your list"))
                    if listMovieCover == nil {
                        TextField($movieSearch,
                                  placeholder: Text("Add movie as your cover"))
                            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification)
                                .debounce(for: 0.5,
                                          scheduler: DispatchQueue.main),
                                       perform: onKeyStroke)
                            .textFieldStyle(.plain)
                            .disabled(listMovieCover != nil)
                    }
                    if listMovieCover != nil {
                        MovieRow(movieId: listMovieCover!)
                        Button(action: {
                            self.listMovieCover = nil
                        }, label: {
                            Text("Remove cover").color(.red)
                        })
                    }
        })
    }
}

struct MovieSearchSection: View {
    @EnvironmentObject var state: AppState
    
    @Binding var movieSearch: String
    @Binding var listMovieCover: Int?
    
    var searchedMovies: [Int] {
        return state.moviesState.search[movieSearch]?.prefix(2).map{ $0 } ?? []
    }
    
    var body: some View {
        Section() {
            ForEach(searchedMovies) { movieId in
                MovieRow(movieId: movieId).tapAction {
                    self.listMovieCover = movieId
                    self.movieSearch = ""
                }
            }
        }
    }
}

struct SaveCancelSection: View {
    @EnvironmentObject var state: AppState
    @Environment(\.isPresented) var isPresented
    
    @Binding var listName: String
    @Binding var listMovieCover: Int?
    
    var body: some View {
        Section {
            Button(action: {
                self.state.dispatch(action: MoviesActions.AddCustomList(list: CustomList(name: self.listName,
                                                                                    cover: self.listMovieCover,
                                                                                    movies: [])))
                self.isPresented?.value = false
                
            }, label: {
                Text("Create").color(.blue)
            })
            Button(action: {
                self.isPresented?.value = false
            }, label: {
                Text("Cancel").color(.red)
            })
        }
    }
}

#if DEBUG
struct CustomListForm_Previews : PreviewProvider {
    static var previews: some View {
        CustomListForm().environmentObject(sampleStore)
    }
}
#endif
