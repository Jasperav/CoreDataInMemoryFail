//
//  ViewController.swift
//  CoreDataInMemoryFail
//
//  Created by Jasper Visser on 30/10/2019.
//  Copyright © 2019 Jasper Visser. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//
//        let person = Person(context: context)
//
//        person.age = 1
//
//        try! context.save()
    }


}

