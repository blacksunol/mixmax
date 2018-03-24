//: Playground - noun: a place where people can play

import UIKit


var str = "Hello, playground"

struct Item {
    var url = "http"
    
}

func callPath(item: Item, finished:  @escaping (_ item: Item) -> ()) {
    print("\(item.url)")
    var newItem = item
    newItem.url = "acb"
    finished(newItem)
    
}
let items = [Item(url: "122"), Item(url: "333"), Item(url: "444")]
let a = items.map { callPath(item: $0, finished: { (item) in
    print("#\(item.url)")
    
}) }

let item = Item()
callPath(item: item) { (item) in
    print(item.url)
}
