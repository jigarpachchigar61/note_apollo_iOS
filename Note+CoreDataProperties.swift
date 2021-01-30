//
//  Note+CoreDataProperties.swift
//  note_apollo_iOS
//
//  Created by Jigar Pachchigar on 29/01/21.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var noteAudio: Data?
    @NSManaged public var noteDescription: String?
    @NSManaged public var noteImage: Data?
    @NSManaged public var noteLocation: String?
    @NSManaged public var noteLocLat: String?
    @NSManaged public var noteLocLong: String?
    @NSManaged public var noteName: String?

}

extension Note : Identifiable {

}
