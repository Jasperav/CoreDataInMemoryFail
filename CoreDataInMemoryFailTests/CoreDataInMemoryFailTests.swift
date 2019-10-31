import CoreData
import XCTest
@testable import CoreDataInMemoryFail


class CoreDataInMemoryFailTests: XCTestCase {

    private func createContainer(modify: (NSPersistentContainer) -> ()) -> NSPersistentContainer {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "InMemoryDatabase", ofType: "sqlite")!
        let url = URL(fileURLWithPath: path)
        let persistentContainer = createPersistentContainer(dataModelName: "InMemoryDatabase")
        let storeDescription = NSPersistentStoreDescription(url: url)

        persistentContainer.persistentStoreDescriptions = [storeDescription]
        persistentContainer.loadPersistentStores { description, error in
            XCTAssertEqual(storeDescription.type, description.type)
            XCTAssertNil(error)
        }

        modify(persistentContainer)
        return persistentContainer
    }

    func testFail() {
        let persistentContainer = createContainer(modify: { _ in })
        let inMemoryContainer = createContainer { persistentContainer in
            let coordinator = persistentContainer.persistentStoreCoordinator
            coordinator.persistentStores.forEach { (persistentStore) in
                do {
                    try coordinator.migratePersistentStore(persistentStore, to: NSPersistentContainer.defaultDirectoryURL(), options: nil, withType: NSInMemoryStoreType)
                } catch {
                    print("Error while migrating persistentStore")
                }
            }
        }

        let persistentContainerCoordinator = persistentContainer.persistentStoreCoordinator
        persistentContainerCoordinator.persistentStores.forEach { (persistentStore) in
            XCTAssertEqual(persistentStore.type, "SQLite")
        }

        let inMemoryContainerCoordinator = inMemoryContainer.persistentStoreCoordinator
        inMemoryContainerCoordinator.persistentStores.forEach { (persistentStore) in
            XCTAssertEqual(persistentStore.type, NSInMemoryStoreType)
        }

        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        let persistentContainerCount = (try! persistentContainer.viewContext.fetch(fetchRequest)).count
        let inMemoryContainerCount = (try! inMemoryContainer.viewContext.fetch(fetchRequest)).count

        XCTAssertEqual(8, persistentContainerCount)
        XCTAssertEqual(persistentContainerCount, inMemoryContainerCount)
    }

}
