//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Ahmed Elgendy on 23.10.2022.
//

import Foundation
import CoreData

public final class CoreDataFeedStore {
    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    enum StoreError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Swift.Error)
    }
    
    public init(storeURL: URL) throws {
        guard let model = CoreDataFeedStore.model else {
            throw StoreError.modelNotFound
        }
        do {
            container = try NSPersistentContainer.load(name: CoreDataFeedStore.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
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
