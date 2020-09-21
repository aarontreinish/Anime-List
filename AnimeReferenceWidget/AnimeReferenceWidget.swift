//
//  AnimeReferenceWidget.swift
//  AnimeReferenceWidget
//
//  Created by Aaron Treinish on 9/9/20.
//  Copyright © 2020 Aaron Treinish. All rights reserved.
//

import WidgetKit
import SwiftUI

struct AnimeEntry: TimelineEntry {
    let date = Date()
    //let animeWidget: AnimeWidget
    let animeWidget: [AnimeWidget]
}

struct Provider: TimelineProvider {
    
    //@AppStorage("watching", store: UserDefaults(suiteName: "group.com.aarontreinish.AnimeList"))
    //var animeData: Data = Data()
    
    func getSnapshot(in context: Context, completion: @escaping (AnimeEntry) -> Void) {
//        if let data = UserDefaults.standard.data(forKey: "watching") {
//            //animeData = data
//        }
        guard let data = UserDefaults.standard.data(forKey: "watching") else { return }
        
        guard let anime = try? JSONDecoder().decode([AnimeWidget].self, from: data) else { return }
        print(anime)
        
       // let entry = AnimeEntry(animeWidget: "Anime")
        //let anime = readJSONFromDevice()
        let entry = AnimeEntry(animeWidget: anime)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<AnimeEntry>) -> Void) {
//        if let data = UserDefaults.standard.data(forKey: "watching") {
//            animeData = data
//        }
        guard let data = UserDefaults.standard.data(forKey: "watching") else { return }
        
        guard let anime = try? JSONDecoder().decode([AnimeWidget].self, from: data) else { return }
        print(anime)
        //let entry = AnimeEntry(animeWidget: "Anime")
        //let anime = readJSONFromDevice()
        let entry = AnimeEntry(animeWidget: anime)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
    
    func placeholder(in context: Context) -> AnimeEntry {
//        if let data = UserDefaults.standard.data(forKey: "watching") {
//            animeData = data
//        }
//        guard let data = UserDefaults.standard.data(forKey: "watching") else { return }
//
//        guard let anime = try? JSONDecoder().decode([AnimeWidget].self, from: data) else { return AnimeEntry(animeWidget: [AnimeWidget(image_url: "", name: "Full Metal", mal_id: 1, sentToCloud: 1)]) }
//        print(anime)

        let anime = [AnimeWidget(image_url: "", name: "Full Metal", mal_id: 1, sentToCloud: 1)]
        //return AnimeEntry(animeWidget: "Anime")
        //let anime = readJSONFromDevice()
        return AnimeEntry(animeWidget: anime)
    }
}

struct TestView: View {
    let animeWidget: [AnimeWidget]
    
    var body: some View {
        VStack {
            ForEach(animeWidget) { anime in
                Text("\(anime.name)")
            }
        }
    }
}

struct AnimeReferenceWidgetEntryView : View {
    let entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        
        switch family {
        case .systemSmall:
            VStack {
                ForEach(entry.animeWidget) { anime in
                    Text("\(anime.name)")
                }
            }
            //TestView(animeWidget: entry.animeWidget)
            //Text("\(entry.animeWidget.count)")
            //AnimeWidgetView(animeWidget: entry.animeWidget)
        case .systemMedium:
            VStack {
                ForEach(entry.animeWidget) { anime in
                    Text("\(anime.name)")
                }
            }
           // TestView(animeWidget: entry.animeWidget)
            //AnimeWidgetView(animeWidget: entry.animeWidget)
        case .systemLarge:
            VStack {
                ForEach(entry.animeWidget) { anime in
                    Text("\(anime.name)")
                }
            }
            //TestView(animeWidget: entry.animeWidget)
            //AnimeWidgetView(animeWidget: entry.animeWidget)
        default:
            VStack {
                ForEach(entry.animeWidget) { anime in
                    Text("\(anime.name)")
                }
            }
            //TestView(animeWidget: entry.animeWidget)
            //AnimeWidgetView(animeWidget: entry.animeWidget)
        }
    }
}

@main
struct AnimeReferenceWidget: Widget {
    private let kind = "AnimeReferenceWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) { entry in
            AnimeReferenceWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

