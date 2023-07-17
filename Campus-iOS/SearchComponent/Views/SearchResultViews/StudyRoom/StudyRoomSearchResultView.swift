//
//  StudyRoomSearchResultView.swift
//  Campus-iOS
//
//  Created by David Lin on 27.12.22.
//

import SwiftUI

struct StudyRoomSearchResultView: View {
    var allResults: [(studyRoomResult: StudyRoomSearchResult, distance: Distances)]
    @State var showRoomsForGroup: [StudyRoom]? = nil
    @State var size: ResultSize = .small
    
    var results: [(studyRoomResult: StudyRoomSearchResult, distance: Distances)] {
        switch size {
        case .small:
            return Array(allResults.prefix(3))
        case .big:
            return Array(allResults.prefix(10))
        }
    }
    
    var body: some View {
        ZStack {
            Color.white
            VStack(alignment: .leading) {
                VStack {
                    ZStack {
                        Text("Study Rooms")
                            .fontWeight(.bold)
                            .font(.title)
                        ExpandIcon(size: $size)
                    }
                }
                ScrollView {
                    ForEach(results, id: \.studyRoomResult) { result in
                        VStack (alignment: .leading) {
                            HStack {
                                Text(result.studyRoomResult.group.name ?? "no group name")
                                    .fontWeight(.heavy)
                                Spacer()
                                GroupDirectionsButton(group: result.studyRoomResult.group) {
                                    Image(systemName: "mappin.and.ellipse")
                                }
                            }
                            Button {
                                withAnimation {
                                    self.showRoomsForGroup = showRoomsForGroup == result.studyRoomResult.rooms ? nil : result.studyRoomResult.rooms
                                }
                            } label: {
                                if showRoomsForGroup == result.studyRoomResult.rooms {
                                    Text("Hide rooms")
                                        .foregroundColor(.gray)
                                        .fontWeight(.light)
                                } else {
                                    Text("Show rooms")
                                        .foregroundColor(.gray)
                                        .fontWeight(.light)
                                }
                            }
                            
                            
                            if let rooms = showRoomsForGroup, showRoomsForGroup == result.studyRoomResult.rooms {
                                ForEach(rooms) { room in
                                    StudyRoomCell(room: room)
                                        .tint(.black)
                                }
                            }
                        }
                    }
                }.padding()
            }
        }
    }
}
