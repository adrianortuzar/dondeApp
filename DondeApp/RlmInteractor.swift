import Foundation
import RealmSwift

protocol RlmInteractorProtocol {
  func getRealm(fileName: String) -> Realm
  func getRealm(type: RealmType) -> Realm
  /// clean all data from database
  func clean(_ type: RealmType)
  func delete(object: Object, realm: Realm)
  func delete(results: Results<Object>, realm: Realm)
  func addTo(realm: Realm, object: Object)
  func update(object: Object, realm: Realm) throws
}

class RlmInteractor: NSObject, RlmInteractorProtocol {

  let rlmVisitInteractor = RlmVisitInteractor.shared
  let rlmLocationInteractor = RlmLocationInteractor.shared

  static let shared = RlmInteractor()

  private override init() {
    super.init()
  }

  let realmSchemaVersion: UInt64 = 30

  // MARK: realm interactor

  func getRealm(fileName: String) -> Realm {
    var config = Realm.Configuration()
    config.fileURL = Bundle.main.url(forResource: fileName, withExtension: "realm")
    config.schemaVersion = realmSchemaVersion

    Realm.Configuration.defaultConfiguration = config

    do {
      return try Realm()
    } catch {
      fatalError()
    }
  }

  func copyRealmInDocumentsFolder(realm: Realm) throws {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

    guard let url = URL.init(string: documentsPath + "/loc.realm") else {
      return
    }

    try realm.writeCopy(toFile: url, encryptionKey: nil)
  }

  func getRealm(type: RealmType) -> Realm {
    switch type {
    case .defaultType:
      var config = Realm.Configuration()
      config.schemaVersion = realmSchemaVersion
      Realm.Configuration.defaultConfiguration = config

      do {
        return try Realm()
      } catch {
        fatalError()
      }
    case .testType :

      var config = Realm.Configuration()
      config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("test.realm")
      config.schemaVersion = realmSchemaVersion

      Realm.Configuration.defaultConfiguration = config

      do {
        return try Realm()
      } catch {
        fatalError()
      }
    case .locationsTestType:
      return DataManager.shared.getRealm(fileName: "locationsTest")
    }
  }

  /// clean all data from database
  func clean(_ type: RealmType) {
    do {
      let realm = getRealm(type: type)
      try realm.write {
        realm.deleteAll()
      }
    } catch {
      fatalError()
    }
  }

  func delete(object: Object, realm: Realm) {
    do {
      try realm.write {
        realm.delete(object)
      }
    } catch {
      fatalError()
    }
  }

  func delete(results: Results<Object>, realm: Realm) {
    do {
      try realm.write {
        realm.delete(results)
      }
    } catch {
      fatalError()
    }
  }

  func addTo(realm: Realm, object: Object) {
    do {
      try update(object: object, realm: realm)
    } catch {
      // add to realm
      do {
        try realm.write {
          realm.add(object)
        }
      } catch {
        print(error)
      }

      if let visit = object as? RlmVisit {
        rlmVisitInteractor.resetVisitData(visit, realm: realm)
      }
    }
  }

  func update(object: Object, realm: Realm) throws {
    if let visit = object as? RlmVisit {
      try rlmVisitInteractor.updateCurrentVisitWith(visit, realm: realm)
    } else if let location = object as? RlmLocation {
      try rlmLocationInteractor.updateLocationWith(location, realm: realm)
    } else {
      throw NSError.init(domain: "Not possible to update object", code: 0, userInfo: nil)
    }
  }
}
