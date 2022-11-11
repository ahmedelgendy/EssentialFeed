//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 23.10.2022.
//

import Foundation
import CoreData

public final class CoreDataFeedStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    public init(storeURL: URL) throws {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
    
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    func perform(completion: @escaping (NSManagedObjectContext) -> ())  {
        let context = self.context
        context.perform {
            completion(context)
        }
    }
}
