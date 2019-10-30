import CoreData
import XCTest
@testable import CoreDataInMemoryFail


class CoreDataInMemoryFailTests: XCTestCase {

    private func createContainer(modify: (NSPersistentStoreDescription) -> ()) -> NSPersistentContainer {
        let bundle = Bundle(for: type(of: self))
        let path = bundle.path(forResource: "InMemoryDatabase", ofType: "sqlite")!
        let url = URL(fileURLWithPath: path)
        let fileManager = FileManager.default
        let uuid = UUID().uuidString

        let saveDirectory = fileManager
                .urls(for: .cachesDirectory, in: .userDomainMask)[0]
                .appendingPathComponent(uuid)

        let saveLocation = saveDirectory.appendingPathComponent(url.lastPathComponent)

        try! fileManager.createDirectory(at: saveDirectory, withIntermediateDirectories: false)
        try! fileManager.copyItem(at: url, to: saveLocation)

        let persistentContainer = createPersistentContainer(dataModelName: "InMemoryDatabase")
        let storeDescription = NSPersistentStoreDescription(url: saveLocation)


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
