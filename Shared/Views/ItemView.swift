//
//  ItemVew.swift
//  ZCombinator
//
//  Created by Jiaqi Feng on 7/19/22.
//

import SwiftUI
import WebKit
import RichText

struct ItemView<T : ItemProtocol>: View {
    @StateObject var vm: ItemViewModel<T> = ItemViewModel<T>()
    let level: Int
    let item: T
    
    init(item: T, level: Int = 0){
        self.level = level
        self.item = item
    }
    
    var body: some View {
        mainItemView.onAppear {
            if self.vm.item == nil {
                self.vm.item = item
            }
        }
    }
    
    @ViewBuilder
    var mainItemView: some View {
        if level == 0 {
            ScrollView{
                VStack(spacing: 0) {
                    nameRow.padding(.leading, 6)
                    if item is Story {
                        if let url = URL(string: item.url.valueOrEmpty) {
                            LinkView(url: url)
                                .padding()
                        } else {
                            VStack(spacing: 0) {
                                Text("\(item.title.valueOrEmpty)")
                                    .fontWeight(.semibold)
                                    .padding(.leading, 12)
                                    .padding(.bottom, 6)
                                Text("\(item.text.valueOrEmpty)")
                                    .font(.system(size: 16))
                                    .padding(.leading, 4)
                            }
                        }
                    } else if item is Comment {
                        Text("\(item.text.valueOrEmpty)")
                            .padding(.leading, Double(4 * (level - 1)))
                    }
                    if vm.status == .idle {
                        Button {
                            Task {
                                await vm.loadKids()
                            }
                        } label: {
                            Text("Load \(item.kids.countOrZero) \(item.kids.isMoreThanOne ? "replies":"reply")")
                        }
                    } else if vm.status == .loading {
                        LoadingIndicator()
                    }
                    VStack(spacing: 0) {
                        ForEach(vm.kids){ comment in
                            ItemView<Comment>(item: comment, level: level + 1 )
                                .padding(.trailing, 4)
                        }.id(UUID())
                    }
                }
            }.navigationBarTitleDisplayMode(.inline)
        } else {
            ZStack {
                if level > 1 {
                    HStack {
                        getColor(level: level)
                            .frame(width: 1)
                        Spacer()
                    }
                }
                VStack {
                    nameRow
                    if item is Story {
                        Text("\(item.title.valueOrEmpty)")
                            .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0))
                    } else if item is Comment {
                        if item.text.isNotNullOrEmpty {
                            Text(item.text.valueOrEmpty)
                                .font(.system(size: 16))
                                .textSelection(.enabled)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, Double(4 * (level - 1)))
                        } else {
                            Text("deleted").font(.footnote).foregroundColor(.gray)
                        }
                    }
                    if vm.status == Status.loading {
                        LoadingIndicator()
                    } else if vm.status != Status.loaded && item.kids.isNotNullOrEmpty {
                        Button {
                            Task {
                                await vm.loadKids()
                            }
                        } label: {
                            Text("Load \(item.kids.countOrZero) \(item.kids.isMoreThanOne ? "replies":"reply")")
                                .font(.footnote.weight(.bold))
                                .foregroundColor(.orange)
                        }
                        .buttonStyle(.bordered)
                    } 
                    VStack {
                        ForEach(vm.kids){ comment in
                            ItemView<Comment>(item: comment, level: level + 1)
                        }.id(UUID())
                    }.buttonStyle(PlainButtonStyle())
                    Spacer()
                }
                .frame(alignment: .leading)
                .padding(EdgeInsets(top: 6, leading: 6, bottom: 0, trailing: 0))
            }
            .frame(maxWidth:.infinity)
            .frame(alignment: .leading)
        }
    }
    
    @ViewBuilder
    var nameRow: some View {
        HStack {
            Text(item.by)
                .borderedFootnote()
                .foregroundColor(getColor(level: level))
            if let karma = item.score {
                Text("\(karma) karma")
                    .borderedFootnote()
                    .foregroundColor(getColor(level: level))
            }
            Text(item.timeAgo)
                .borderedFootnote()
                .foregroundColor(getColor(level: level))
            Spacer()
        }
    }
    
    func getColor(level: Int) -> Color {
        var level = level
        let initialLevel = level
        
        if colors[initialLevel] != nil {
            return colors[initialLevel]!
        }
        
        while level >= 10 {
            level = level - 10
        }
        
        let r = 255
        var g = level * 40 < 255 ? 152 : (level * 20).clamped(to: 0...255)
        var b = (level * 40).clamped(to: 0...255)
        
        if (g == 255 && b == 255) {
            g = (level * 30 - 255).clamped(to: 0...255)
            b = (level * 40 - 255).clamped(to: 0...255)
        }
        
        let color = Color.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
        
        colors[initialLevel] = color
        
        return color
    }
}

var colors = [Int: Color]()

struct ItemVew_Previews: PreviewProvider {
    static var previews: some View {
        //ItemView(item: Story())
        EmptyView()
    }
}
