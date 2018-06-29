//
//  CoreDataStack.swift
//  DogWalker
//
//  Created by Lauren Nicole Roth on 6/28/18.
//  Copyright © 2018 Lauren Nicole Roth. All rights reserved.
//

import CoreData

class CoreDataStack {
  
  static let persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "DogWalker")
    container.loadPersistentStores { (_, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    return container
  }()
  
  static var context: NSManagedObjectContext { return persistentContainer.viewContext }
  
  class func saveContext () {
    let context = persistentContainer.viewContext
    
    guard context.hasChanges else {
      return
    }
    
    do {
      try context.save()
    } catch {
      let nserror = error as NSError
      fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
    }
  }
}
