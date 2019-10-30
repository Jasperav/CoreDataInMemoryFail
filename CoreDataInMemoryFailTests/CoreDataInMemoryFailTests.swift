import CoreData
import XCTest
@testable import CoreDataInMemoryFail


class CoreDataInMemoryFailTests: XCTestCase {

    private func createContainer(modify: (NSPersistentStoreDescription) -> ()) -> NSPersistentContainer {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "InMemoryDatabase", ofType: "sqlite")!
        let url = URL(fileURLWithPath: path)
        let persistentContainer = createPersistentContainer(dataModelName: "InMemoryDatabase")
        let storeDescription = NSPersistentStoreDescription(url: url)

        modify(storeDescription)

        persistentContainer.persistentStoreDescriptions = [storeDescription]
        persistentContainer.loadPersistentStores { description, error in
            XCTAssertEqual(storeDescription.type, description.type)
            XCTAssertNil(error)
        }

        return persistentContainer
    }

    func testFail() {
        let persistentContainer = createContainer(modify: { _ in })
        let inMemoryContainer = createContainer { storeDescription in
            storeDescription.type = NSInMemoryStoreType
        }

        let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        let persistentContainerCount = (try! persistentContainer.viewContext.fetch(fetchRequest)).count
        let inMemoryContainerCount = (try! inMemoryContainer.viewContext.fetch(fetchRequest)).count

        XCTAssertEqual(8, persistentContainerCount)
        XCTAssertEqual(persistentContainerCount, inMemoryContainerCount)
    }

}
