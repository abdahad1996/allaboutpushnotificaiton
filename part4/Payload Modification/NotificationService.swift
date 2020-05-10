/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UserNotifications
import CoreData

class NotificationService: UNNotificationServiceExtension {
  
//  Using app groups with Core Data really only requires two changes to the default setup.
//  1. The first difference is that you have to tell iOS exactly where to write the internal .sqlite file since the default doesn’t work with app groups. Be sure you use the exact name that you gave the App Group!
//  2. Creating the container is no different than the default setup.
//  3. However, the container has to know that it’s using your custom location.
//  4. Then, just load the store like normal and return the container.
//  Now, your main app knows exactly where to write the Core Data database to, but your extension still doesn’t have this information.
//  Copy the lazily computed property you just used exactly as is and then paste it into Payload Modification/NotificationService.swift file, inside of the NotificationService class. Remember to add an import CoreData statement or you’ll get a build error. Now, you can access your data model in the extension.
  
  lazy private var persistentContainer: NSPersistentContainer = {
    let groupName = "group.com.raywenderlich.PushNotifications"
    let url = FileManager.default
      .containerURL(forSecurityApplicationGroupIdentifier: groupName)!
      .appendingPathComponent("PushNotifications.sqlite")
    
    let container = NSPersistentContainer(name: "PushNotifications")
    
    container.persistentStoreDescriptions = [
      NSPersistentStoreDescription(url: url)
    ]
    
    container.loadPersistentStores(completionHandler: { _, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    
    return container
  }()
  
   var contentHandler: ((UNNotificationContent) -> Void)?
      var bestAttemptContent: UNMutableNotificationContent?

  //  this is called when your notification arrives. You have roughly 30 seconds to perform whatever actions you need to take. If you run out of time, iOS will call the second method, serviceExtensionTimeWillExpire to give you one last chance to hurry up and finish.
      override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
          self.contentHandler = contentHandler
          bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
          print("hellooooo")
          if let bestAttemptContent = bestAttemptContent {
              // Modify the notification content here...
            
            //modify text
            bestAttemptContent.title = "\(bestAttemptContent.title) [b]"
              bestAttemptContent.body = "\(bestAttemptContent.body) [hh]"
  //          // 1
  //          print("URL",request.content.userInfo["media-url"])
  //
            //add video or image
         if let urlPath = request.content.userInfo["media-url"] as? String,
            let url = URL(string: urlPath) {
            // 2
            let destination = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(url.lastPathComponent)
            do { // 3
            let data = try Data(contentsOf: url)
              try data.write(to: destination)
            // 4
              //media(video,audio) file attachedwith notification
              //file specifeid should be in disk and supported format types
                let attachment = try UNNotificationAttachment(
                  identifier: "",
                  url: destination)
            // 5
            bestAttemptContent.attachments = [attachment]
              
            }
            catch let err {
              print("err",err)
            // 6
              
            }

            }
            
              //increment badge count
            if let incr = bestAttemptContent.badge as? Int { switch incr {
            case 0:
            UserDefaults.extensions.badge = 0
            bestAttemptContent.badge = 0
            default:
               let current = UserDefaults.extensions.badge
              let new = current + incr
              UserDefaults.extensions.badge = new
              bestAttemptContent.badge = NSNumber(value: new) }
              }
            
            contentHandler(bestAttemptContent)

          }
      }
      
      override func serviceExtensionTimeWillExpire() {
          // Called just before the extension will be terminated by the system.
          // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
          if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
              contentHandler(bestAttemptContent)
          }
      }

  }
