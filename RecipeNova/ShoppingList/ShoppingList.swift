
import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct ShoppingListEntryView : View {
    var entry: Provider.Entry
    @ObservedObject var list:Synced
    
    var body: some View {
        ZStack{
            VStack{
                Text("Shopping List")
                    .foregroundColor(Color.red)
                    .font(Font.system(size: 18, weight: .medium, design: .rounded))
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 5, trailing: 10))
                Text(list.value.replacingOccurrences(of: "\n", with: ""))
                    .foregroundColor(Color(UIColor.label))
                    .font(Font.system(size: 17, weight: .regular, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
            }
        }
    }
    
}

@main
struct ShoppingList: Widget {
    let kind: String = "ShoppingList"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ShoppingListEntryView(entry: entry, list: Synced())
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct ShoppingList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ShoppingListEntryView(entry: SimpleEntry(date: Date()), list: Synced())
                .previewContext(WidgetPreviewContext(family: .systemMedium))
        }
    }
}

class Synced: ObservableObject {
    @Published var value:String = SyncWApp()
}

func SyncWApp()->String{
    if let userDefaults = UserDefaults(suiteName:"group.Cooper-Kattner.RecipeNova") {
        guard let ingredients = userDefaults.string(forKey: "List") else{
            return ""
        }
        return ingredients
    }
    return ""
}
