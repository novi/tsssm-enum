import Cocoa

// Enum: enumerations

// Associated Value Enumerations
// 値付き列挙型

// https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Enumerations.html

enum Barcode {
    case UPCA(Int, Int, Int, Int)
    case QRCode(String)
}

// 値を入れて作成する
let qr = Barcode.QRCode("hello world")
let someUPCA = Barcode.UPCA(1, 2, 3, 4)

let someBar: Barcode = qr

// 値を取り出す
switch someBar {
case .UPCA(let a, let b, let c, let d):
    print("UPCA: \(a)-\(b)-\(c)-\(d)")
case .QRCode(let str):
    print("QR: \(str)")
}

// if case パターンマッチも使える
if case .QRCode(let str) = someBar {
    print("QR: \(str)")
}

switch someBar {
case .UPCA(let val):
    // Tupleでもある
    print("UPCA: \(val.0)-\(val.1)-\(val.2)-\(val.3)")
case .QRCode: break // 値が要らない時
}

// Protocolの実装(拡張)もできる
extension Barcode: CustomStringConvertible {
    var description: String {
        switch self {
        case .UPCA(let val):
            return "this is UPCA: \(val)"
        case .QRCode(let str):
            return "this is QR: \(str)"
        }
    }
}

print(someUPCA.description)
print(qr.description)


// どこで使われているか
// Optional

let optInt: Int? = nil
let optInt2: Int? = .None
let optInt3: Optional<Int> = .None

optInt == optInt2
optInt3 == optInt2

let optSomeInt2: Optional<Int> = .Some(123)
let optSomeInt: Int? = 123

optSomeInt == optSomeInt2

// Result
// HTTPのリクエストなど非同期の結果の取得に使う

enum Result<T> { // ジェネリック型のEnum
    case Success(T)
    case Failure(ErrorType)
}

enum SomeError: ErrorType {
    case HTTPResponseCodeError
}

let result: Result<String> = .Success("Hello world")
//let result: Result<String> = .Failure(SomeError.HTTPResponseCodeError)

switch result {
case .Success(let res):
    print("some request is success, result: \(res)")
case .Failure(let error):
    print("error occured, error: \(error)")
}

// もっと詳細なエラー判定

enum FileReadingError: ErrorType {
    case NoFileError(path: String)
    case ReadingError(path: String, error: ErrorType)
}

func readFile(path path: String) throws -> String {
    // 読み込む処理をする
    // エラーが発生, 例外を投げる
    throw FileReadingError.NoFileError(path: path)
}

do { // 例外をcatchできるスコープを作る
    let string = try readFile(path: "/tmp/1234")
} catch {
    print("\(error)") // 例外をキャッチ
}

do {
    let string = try readFile(path: "/tmp/1234")
} catch FileReadingError.NoFileError(let path) { // この例外の場合だけここでキャッチ
    print("no such file \(path)")
} catch {
    print("\(error)") // それ以外のエラー
}

// TIP
// enum は namespaceを作るので、使うと読みやすくなる場合もある

enum User {
    struct User {
        let userID: Int
    }
    struct Bookmark {
        let user: User
        let url: String
    }
}

let somebody = User.User(userID: 1)
let someBookmark = User.Bookmark(user: somebody, url: "https://google.com")
print("\(someBookmark)")

// もし enum User ではなく、struct User だと
// User() という意味のないstructの実体が生成できてしまう

// 閑話休題

// 再帰的な構造にEnumを使う

enum FileElement {
    indirect case Directory(name: String, contents: [FileElement]) // indirectが必要な場合あり
    case File(name: String)
}

let fileA = FileElement.File(name: "A")
let fileC = FileElement.File(name: "C")

let someDirectory = FileElement.Directory(name: "Music", contents: [fileA, fileC])

let fileB = FileElement.File(name: "B")
let root = FileElement.Directory(name: "/", contents: [someDirectory, fileB])

func printFile(element: FileElement, indent: String = "") {
    var indent = indent
    switch element {
    case .File(let name):
        print("\(indent)\(name)")
    case .Directory(let name, let contents):
        print("\(indent)\(name)>")
        indent.appendContentsOf( (0..<name.characters.count).map({ _ in " " }) )
        contents.map({ printFile($0, indent: indent) })
    }
}

printFile(root)



// ステートを管理する

class SomeTask {
    var isRunning = false
    var startedAt: NSDate? = nil
}

let task = SomeTask()
// タスクをスタート
/*
task.isRunning = true
task.startedAt = NSDate(timeIntervalSinceReferenceDate: 200)
*/

if let startedAt = task.startedAt where task.isRunning {
    startedAt
    // startedAt に開始して動いているタスク
    print("the task has started at \(startedAt)")
} else if task.isRunning == false {
    // 動いていないタスク
    print("the task is stopped")
} else {
    // このステートはなんだろう...
    fatalError("invalid state")
}


class BetterTask {
    enum State {
        case Stopped
        case Running(startedAt: NSDate)
    }
    var state: State = .Stopped
}

let betterTask = BetterTask()
//betterTask.state = .Running(startedAt: NSDate(timeIntervalSinceReferenceDate: 200)) // タスクをスタート

switch betterTask.state {
    case .Stopped:
        print("the task is stopped")
    case .Running(let startedAt):
        print("the task has started at \(startedAt)")
}

// Practice: ステートPausedを追加してみる

// Optional型のかわりとして使う

// これはデータベースに、User.Bookmarkを保存する(ただし、すでにある場合はスキップ)
// 保存した場合は保存したIDを返す、すでに同じBookmarkが存在した場合はnilを返す
struct Database {
    static func saveOrIgnoreBookmark(database db: String, bookmark: User.Bookmark) throws -> Int? {
        // 保存する処理
        return nil // すでに保存されている
        return 1241 //保存された行のID
    }
}

do {
    let user = User.User(userID: 2)
    let bookmark = User.Bookmark(user: user, url: "https://google.com")
    if let insertId = try Database.saveOrIgnoreBookmark(database: "user", bookmark: bookmark) {
        // 保存した, 保存したときの内部Id
        insertId
    } else {
        // すでに存在
    }
}

// 戻り値がInt? (=Optional<Int>)になっているので、これをenumにする
// 読みやすさ向上やコーディングミスを避ける

extension Database {
    
    enum BookmarkSaveState {
        case saved(insertId: Int)
        case ignored
    }
    
    static func saveOrIgnoreBookmarkBetter(database db: String, bookmark: User.Bookmark) throws -> BookmarkSaveState {
        // 保存する処理
        return .ignored // すでに保存されている
        return .saved(insertId: 1234) //保存された行のID
    }
}

do {
    let user = User.User(userID: 2)
    let bookmark = User.Bookmark(user: user, url: "https://google.com")
    switch try Database.saveOrIgnoreBookmarkBetter(database: "user", bookmark: bookmark) {
    case .saved(let insertId):
        print("saved id:\(insertId)")
    case .ignored:
        print("not saved, already exists.")
    }
}


// やっていることは Int<Optional> と同じではある

do {
    let user = User.User(userID: 2)
    let bookmark = User.Bookmark(user: user, url: "https://google.com")
    switch try Database.saveOrIgnoreBookmark(database: "user", bookmark: bookmark) {
    case .Some(let val):
        print("saved id:\(val)")
    case .None:
        print("not saved, already exists.")
    }
}

// その他
// Enumの値に関数を設定

enum Layouter {
    case Center
    case Left
    case Custom((origin: CGPoint, size: CGSize) -> CGPoint)
}

class MyView: NSView {
    var layouter: Layouter = .Center
}

let view = MyView()

view.layouter = .Center // Viewをセンタリング
// Viewのレイアウトを関数で指定
view.layouter = .Custom({ (origin, size) in
    return origin
})


