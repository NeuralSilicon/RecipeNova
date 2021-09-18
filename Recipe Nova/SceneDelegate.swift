
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        if let shortcutItem = connectionOptions.shortcutItem {
            switch shortcutItem.type {
            case "com.RecipeNova.Search":
                UI.QA = 2 //QA as in quick action
            case "com.RecipeNova.AddList":
                UI.QA = 1 //QA as in quick action
            default:
                break
            }
            NotificationCenter.default.post(name: NSNotification.Name("QuickAction"), object: nil)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        NotificationCenter.default.post(name: NSNotification.Name("WidgetAction"), object: nil)
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {

        switch shortcutItem.type {
        case "com.RecipeNova.Search":
            UI.QA = 2 //QA as in quick action
        case "com.RecipeNova.AddList":
            UI.QA = 1 //QA as in quick action
        default:
            break
        }
        NotificationCenter.default.post(name: NSNotification.Name("QuickAction"), object: nil)
        completionHandler(true)
    }

}

