
import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //QuickActions
        self.AddShortCuts()
        
        //MARK: - Delay Launch to show splash screen
        Thread.sleep(forTimeInterval: 0.3)
        
        //MARK: - Decode Information
        self.DecodeUI()

            
        return true
    }
    
    private func AddShortCuts(){
        //Quick Action ShortCute
        let RecipeIcon = UIApplicationShortcutIcon(systemImageName: "magnifyingglass")
        let Recipe = UIApplicationShortcutItem(type: "com.RecipeNova.Search", localizedTitle: "Search", localizedSubtitle: nil, icon: RecipeIcon, userInfo: nil)
        
        let icon = UIApplicationShortcutIcon(systemImageName: "list.number")
        let List = UIApplicationShortcutItem(type: "com.RecipeNova.AddList", localizedTitle: "Add List", localizedSubtitle: nil, icon: icon, userInfo: nil)
        
        UIApplication.shared.shortcutItems = [Recipe,List]
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.EncodeUI() //Once User Close the App Save All the UserInformation
        self.saveContext()
    }
    
    

    
    //MARK: - Decode UserInformation
    func DecodeUI(){
        let json = UserDefaults.standard.value(forKey: "UserInformation") as? String
        do {
            guard let data = json?.data(using: .utf8) else {
                return UI = UserInformation()
            }
            let DecodedUI = try JSONDecoder().decode(UserInformation.self, from: data)
            UI = DecodedUI
        } catch { print(error) }
    }
    
    //MARK: - Encode UserInformation
    func EncodeUI(){
        do {
            let jsonData = try JSONEncoder().encode(UI)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            UserDefaults.standard.set(jsonString, forKey: "UserInformation")
            
        } catch { print(error) }
    }
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "RecipeNova")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

