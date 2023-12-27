import Foundation



//Person

protocol PersonProtocol:AnyObject{

    var name:String {get}

}



class Person:PersonProtocol,Show{

    internal var name:String

    

    init?(){

        return nil

    }



    init(name:String){

        self.name = name

    }



    func show() {

        print(name)

    }

}



class Customer:Person{

    

}





class Actor:Person{

    var movies:[String] = []

}



//end Person





//Content

protocol Content:AnyObject,Show{

    var title:String {get set}

    var description:String {get}

    var author:String {get}

}



protocol MovieProtocol:Content{

    var releaseDate:String {get}

    init?()

}

extension MovieProtocol{

   var titleUpper:String{

        get{title.uppercased()}

        set{setTitle(newTitle:newValue)}

    }



    func setTitle(newTitle:String){

        title = newTitle

    }

}



protocol Show{

    func show()->Void

}



class Movie{

    var title: String = ""

    var description: String

    var author: String

    var releaseDate:String

    var titleUpper:String{

        get{title.uppercased()}

        set{title = newValue}

    }

    var actors:[Actor] = []



    required init?() {

        return nil

    }



    init(title:String,description:String,author:String,releaseDate:String){

        self.description = description

        self.author = author

        self.releaseDate = releaseDate

        self.setTitle(newTitle: title)

    }



    init(title:String,description:String,author:String){

        self.description = description

        self.author = author

        self.releaseDate = "-"

        self.setTitle(newTitle: title)



    }



    init(title:String,description:String,author:String,releaseDate:String,actors:[Actor]){

        self.description = description

        self.author = author

        self.releaseDate = releaseDate

        self.actors = actors

        self.setTitle(newTitle: title)

    }



    func setTitle(newTitle:String){

        self.title = newTitle

    }



    func show(){

        print(titleUpper)

    }



    func showDetail(){

        print(titleUpper)

        print(description)

        print("Director: ",author)

        print("Release Date : ",releaseDate)

    }

}



extension Movie:MovieProtocol{}



//end Content



//Store

protocol StoreProtocol{

    associatedtype Item where Item:Show

    var items:[Item?] {get}

    subscript(index:Int)->Item? {set get}

}





protocol Queue:StoreProtocol,Show {

    mutating func enqueue(item: Item) 

    mutating func dequeue() -> Item?

}



struct Store<T: Show>: Queue {

    var items: [T?] = []

    var count:Int{

        get{items.count}

    }



    subscript(index:Int)->T?{

        get{

            if index < count{

                return items[index]

            }

            return nil

        }

        set{

            items[index] = newValue

        }

    }



    mutating func enqueue(item: T) {

        items.append(item)

    }



    mutating func dequeue() -> T?{

        if items.isEmpty {return nil}

        return items.removeFirst()

    }

    

    func getSelf()->[T?]{return items}



    func show(){

        var i = 1

        items.forEach({

            print("----------------")

            if let showTime = $0{

                print(i,".",terminator: "")

                i += 1

                showEach(item:showTime)

            }

            print("----------------")

        })

    }

}



// protocol BoxProtocol{

//     associatedtype Item

// }



// struct Box:BoxProtocol{

//     var items:[any BoxProtocol]

//     var count:Int{return items.count}

//        subscript(index:Int)->(any BoxProtocol)?{

//         get{

//             if index < count{

//                 return items[index]

//             }

//             return nil

//         }

//         set{

//             items[index] = newValue

//         }

//     }



// }

//end Store



//cinema & theater

class Theater:Show{

    static var count = 0

    var id:Int

    var showsTime:[ShowTime] = []

    weak var cinema:Cinema?



    init(cinema:Cinema){

        Theater.count += 1

        self.cinema = cinema

        self.id = Theater.count

    }



    func addShowTime(time:String){

        showsTime.append(ShowTime(time: time,theater: self))

    }



    func addMovieAndShowTime(time:String,movie:Movie){

        showsTime.append(ShowTime(movie: movie, time: time, theater: self))

    }



    func addMovie(index:Int,movie:Movie){

        if index > showsTime.count{

            return

        }

        showsTime[index].movie = movie

        cinema?.showTimeList.append(showsTime[index])

    }



    // func closeMovie(id:Int){

    //  if id > showsTime.count{

    //     return

    //  }

    //  cinema!.showTimeHistory.append(showsTime[id])

    //  showsTime[id].movie = nil

    // }

    

    func show(){

        showsTime.forEach({

            if $0.movie != nil{

            $0.movie!.show()

            }else{

                print("Movie : - ")

            }

            print($0.time)

        })

    }



    struct ShowTime:Show{

        static var count = 0

        var id:Int

        var movie:MovieProtocol?

        var time:String

        var available = true

        var seats:[[Seat]] = [[]]

        unowned var theater:Theater?





        init(time:String,theater:Theater){

            ShowTime.count += 1

            self.id = ShowTime.count

            self.time = time

            self.seats = generateSeats()

            self.theater = theater

        }



        init(movie:Movie,time:String,theater:Theater){

            ShowTime.count += 1

            self.id = ShowTime.count

            self.movie = movie

            self.time = time

            self.seats = generateSeats()

            self.theater = theater

        }



        mutating func setAvailableSeat(rowCol:[[Int]]){

            for (_,item) in rowCol.enumerated(){

                seats[item[0]][item[1]].available = false

            }

        }



        func getSeat(rowCol:[Int])->Seat{

            return seats[rowCol[0]][rowCol[1]]

        }



        enum SeatError:Error{

            case notFound,notAvailable

        }



        func checkSeat(seatNumber:String)throws ->[Int]{

            for(row,itemRow) in seats.enumerated(){

                    for (col,itemCol) in itemRow.enumerated(){

                        if itemCol.number == seatNumber {

                            if itemCol.available == false{

                                throw SeatError.notAvailable

                            }

                            return [row,col]

                        }

                    }

                }

            throw SeatError.notFound

        }



        func show(){

            if !available{

                print("Closed")

            }else{

                if let theaterNo = theater?.id{

                    print("Theater No. ",theaterNo)

                }

                print("Time : ",time)

                if let title = movie?.titleUpper{

                print("Title : ",title)

                }

            }

        }

  



        struct Seat{

            var number:String

            var available:Bool = true

            var price:Double



            init(number:String,price:Double){

                self.number = number

                self.price = price

            }

            

        }



        private func  generateSeats()->[[Seat]]{

            var seats:[[Seat]] = []

            let seatLetter = Array("ABCDEFGHIJ")

            for row in 0..<10{

                var rowSeats:[Seat] = []

                for column in 0..<10{

                    rowSeats.append(Seat(number:"\(seatLetter[row])\(column)",price : seatLetter[row] == "I" || seatLetter[row] ==  "J" ? 220 : 180))

                }

                seats.append(rowSeats )

            }

            return seats

        }

    }

}



class Cinema{

    var moviesList = Store<Movie>()

    var theaters = Store<Theater>()

    var showTimeHistory:[Theater.ShowTime] = []

    var showTimeList:[Theater.ShowTime] = []

    var ticketHistory = Store<Ticket>()



    init(theaterNumber:Int){

        for _ in 0..<theaterNumber{

            theaters.enqueue(item: Theater(cinema: self))

        }

    }



    func addMovie(movie:Movie){

        moviesList.enqueue(item: movie)

    }



    func removeMovie(index:Int){

        moviesList[index] = nil

    }



    func showMovie(title:String){

        var no = 0

        showTimeList.forEach({

            if $0.movie?.titleUpper == title && $0.available{

                    print("-------------------")

                    print(no)

                    print("Theater No.",$0.id)

                    $0.show()

                    print("-------------------")

            }

            no += 1

        })

    }

}



protocol TicketProtocol{

    

}



struct Ticket:Show{

    var seatNumber:String

    var movie:String

    var price:Double

    var theaterNo:String





    func show() {

        print("Theater No. ",theaterNo)

        print("movie : ",movie)

        print("Seat No. : ",seatNumber)

        print("price : ",price)

    }



    static func sum(tickets:Store<Ticket>)->Double{

        var ticket = Ticket(seatNumber: "", movie: "", price: 0,theaterNo: "-")

        for i in 0..<tickets.count{

            if let thisTicket = tickets[i]{

                ticket += thisTicket

            }

        }

        return ticket.price

    }

}



extension Ticket{

    static func += (ticket1:inout Ticket,ticket2:Ticket){

        ticket1.price =  ticket1.price + ticket2.price

    }

}

// end cinema



//function

func showEach<T:Show>(item:T){

    item.show()

}



func showArray<T:Show>(items:[T]){

    var i = 1

    items.forEach{

        print("\(i).",terminator: "")

        i += 1

        $0.show()

        print("----------------")

    }

}





func joinQueue<T:Queue>(first : T,second : T) -> some Queue {

    var sumQueue = Store<T.Item>()

    var copyQueue1 = first

    while let item = copyQueue1.dequeue(){

        sumQueue.enqueue(item: item)

    }

    var copyQueue2 = second

    while let item = copyQueue2.dequeue(){

        sumQueue.enqueue(item: item)

    }



    return sumQueue

}



func pauseFunc(_ text:String = ""){

    print(text,terminator: "")

    let _ = readLine()

}





//end function





//Error

enum InputError:Error{

    case invalidInput

}



//end Error



//data



//make actor

let actor1 = Actor(name: "Actor1")

let actor2 = Actor(name: "Actor2")

let actor3 = Actor(name: "Actor3")



//make movies

let movie1 = Movie(title: "Movie1", description: "aaaaaaaaa", author: "Joe", releaseDate: "12-11-2023", actors: [actor1,actor2,actor3])

let movie2 = Movie(title: "Movie2", description: "bbbbbb", author: "Jame", releaseDate: "13-11-2023")

let movie3 = Movie(title: "Movie3", description: "ccccccc", author: "Jax", releaseDate: "14-11-2023")

let movie4 = Movie(title: "Movie4", description: "dddddd", author: "Jane", releaseDate: "15-11-2023")







//make cinema

let cinema = Cinema(theaterNumber: 5)

cinema.addMovie(movie: movie1)

cinema.addMovie(movie: movie2)

cinema.addMovie(movie: movie3)

cinema.addMovie(movie: movie4)





//make showTime

cinema.theaters[0]?.addShowTime(time: "13.30")

cinema.theaters[0]?.addMovie(index: 0, movie: movie1)

cinema.theaters[1]?.addShowTime(time: "15.30")

cinema.theaters[1]?.addMovie(index: 0, movie: movie1)

cinema.theaters[2]?.addShowTime(time: "11.30")

cinema.theaters[2]?.addMovie(index: 0, movie: movie2)

cinema.theaters[3]?.addShowTime(time: "14.30")

cinema.theaters[3]?.addMovie(index: 0, movie: movie3)

cinema.theaters[4]?.addShowTime(time: "18.30")

cinema.theaters[4]?.addMovie(index: 0, movie: movie4)

cinema.theaters[4]?.addShowTime(time: "11.30")

cinema.theaters[4]?.addMovie(index: 1, movie: movie4)

cinema.theaters[4]?.addShowTime(time: "12.00")

cinema.theaters[4]?.addMovie(index: 0, movie: movie1)



//end data



//resultBuilder

@resultBuilder

struct DisplaySeatBuilder {

    static func buildBlock(_ components: [[Theater.ShowTime.Seat]]) -> [[Theater.ShowTime.Seat]] {

        return components

    }

}



// Usage

func displaySeats(@DisplaySeatBuilder _ content: () -> [[Theater.ShowTime.Seat]]) {

    let seats = content()

    print("------------------------------")

    print("|          screen            |")

    print("------------------------------")



    seats.forEach { row in

        var seatRow = ""

        row.forEach {

            seatRow += ($0.available ? "\($0.number) " : " X ")

        }

        print(seatRow)

    }

}



//display



func main(){

    while true{

        system("clear")

        print("1.Admin")

        print("2.Select Movie")

        do{

            if let input = Int(readLine()!){

                   switch input{

                        case 1:

                            displayLoginAdminPage()

                        case 2:

                            displaySelectMovie()

                        default:

                            throw InputError.invalidInput

                   }

            }else{

                throw InputError.invalidInput

            }

        }catch{

            pauseFunc("\(error)")

        }

    }

}



func displayLoginAdminPage(){

   while true{

        system("clear")

        print("Login")

        do{

            print("user : ",terminator: "")

            if let inputUser = readLine(){

                if inputUser == "admin"{

                    print("password : ",terminator: "")

                    if let inputPassword = readLine(){

                        if inputPassword == "1234"{

                            displayAdminPage()

                        }else{

                            throw InputError.invalidInput

                        }

                    }

                }else{

                    throw InputError.invalidInput

                }

            }else{

                throw InputError.invalidInput

            }

        }catch{

            pauseFunc("\(error)")

        }

    }

}



func displayAdminPage(){

    while true{

        system("clear")

        print("Login")

        print("1.Manage Movies")

        print("2.View History")

        print("3.Log out")

        do{

            print("Select : ",terminator: "")

            if let input = Int(readLine()!){

                switch input{

                    case 1:

                        displayMangeMovies()

                    case 2:

                        displayViews()

                    case 3:

                        main()

                    default:

                        throw InputError.invalidInput

                }

            }else{

                throw InputError.invalidInput

            }

        }catch{

            pauseFunc("\(error)")

        }

    }

}



func displayMangeMovies(){

    while true{

        system("clear")

        print("Manage Movies")

        print("1.Add Movie")

        print("2.Add ShowTime")

        print("3.Close ShowTime")

        do{

            if let input = Int(readLine()!){

                switch input{

                    case 1:

                        displayAddMovie()

                    case 2:

                        displayAddShowTime()

                    case 3:

                        displayCloseShowTime()

                    default:

                        throw InputError.invalidInput

                }

            }else{

                throw InputError.invalidInput

            }

        }catch{

            pauseFunc("\(error)")

        }

    }

}



func displayAddMovie(){

    loop:while true{

        system("clear")

        print("Add Movie")

        do{

            print("Title : ",terminator: "")

            if let title = readLine(){

                print("Description : ",terminator: "")

                if let description = readLine(){

                    print("Director : ",terminator: "")

                    if let director = readLine(){

                        print("Title : ",title)

                        print("Description : ",description)

                        print("Director : ",director)

                        print("Do you Ok? (Y:N) : ",terminator: "")

                        if let input = readLine(){

                            switch input{

                                case "Y","y":

                                    cinema.moviesList.enqueue(item: Movie(title: title, description: description, author: director))

                                    pauseFunc("Add Completed!")

                                    displayAdminPage()

                                default:

                                    continue loop

                            }

                        }

                    }

                }

            }

        }catch{

            pauseFunc("\(error)")

        }

    }

}



func displayAddShowTime(){

        loop:while true{

        system("clear")

        print("Add ShowTime")

        do{

            print("Select Theater 1 - \(cinema.theaters.count) : ",terminator: "")

            if let theaterNo = Int(readLine()!){

                if theaterNo > cinema.theaters.count{throw InputError.invalidInput}

                print("Input Show Time : ",terminator: "")

                if let showTime = readLine(){

                    cinema.moviesList.show()

                    print("Select Movies : ",terminator: "")

                        if let movie = Int(readLine()!){

                            if movie > cinema.moviesList.count{throw InputError.invalidInput}

                            if let movieId = cinema.moviesList[movie - 1]{

                                cinema.theaters[theaterNo - 1]?.addMovieAndShowTime(time: showTime, movie: movieId)

                                pauseFunc("Add Completed!")

                            }

                        }else{

                            throw InputError.invalidInput

                        }

                }

            }else{

                throw InputError.invalidInput

            }

        }catch{

            pauseFunc("\(error)")

        }

    }

}



func displayCloseShowTime(){

    loop:while true{

        system("clear")

        print("Close ShowTime")

        do{

            showArray(items: cinema.showTimeList)

            print("Select : ",terminator: "")

            if let index = Int(readLine()!){

                if index > cinema.showTimeList.count{throw InputError.invalidInput}

                cinema.showTimeList[index - 1].available = false

                cinema.showTimeHistory.append(cinema.showTimeList[index - 1])

                cinema.showTimeList[index - 1].theater = nil

                pauseFunc("Closed Completed!")

                displayAdminPage()

            }else{

                throw InputError.invalidInput

            }

        }catch{

            pauseFunc("\(error)")

        }

    }

}



func displayViews(){

        loop:while true{

        system("clear")

        print("Views History")

        print("1.ShowTime")

        print("2.Ticket")

        do{

            print("Select : ",terminator: "")

            if let input = Int(readLine()!){

                switch input{

                    case 1:

                        displayShowTimeHistory()

                    case 2:

                        displayTicketHistory()

                    default:

                        throw InputError.invalidInput

                }

            }else{

                throw InputError.invalidInput

            }

        }catch{

            pauseFunc("\(error)")

        }

    }

}



func displayShowTimeHistory(){

    for item in cinema.showTimeHistory{

           if let theaterNo = item.theater?.id{

                    print("Theater No. ",theaterNo)

                }

                print("Time : ",item.time)

                if let title = item.movie?.titleUpper{

                print("Title : ",title)

                }

    }

    pauseFunc()

    displayAdminPage()

}



func displayTicketHistory(){

    cinema.ticketHistory.show()

    pauseFunc()

    displayAdminPage()

}   





//----

func displaySelectMovie(){

    while true{

    system("clear")

        cinema.moviesList.show()

        print("Select Movie : ",terminator: "")

            do{

                if let input = Int(readLine()!){

                    if input == 999{main()}

                    if input > cinema.moviesList.count{throw InputError.invalidInput}

                    if let movieName =  cinema.moviesList[input - 1]?.titleUpper{

                        cinema.showMovie(title:movieName)

                        displaySelectShowTime()

                    }

                }else{

                    throw InputError.invalidInput

                }

            }catch{

                pauseFunc("\(error)")

            }

    }

}



func displaySelectShowTime(){

    while true{

        print("Select ShowTime : ",terminator: "")

        do{

            if let input = Int(readLine()!){

                if input >= cinema.showTimeList.count{throw InputError.invalidInput}

                displaySelectSeat(showTimeIndex: input)

            }else{

                throw InputError.invalidInput

            }

        }catch{

            pauseFunc("\(error)")

        }

    }

}



func displaySelectSeat(showTimeIndex:Int){

    let showTime = cinema.showTimeList[showTimeIndex]

    showTime.show()

    // var tickets:[Ticket] = []

    var tickets = Store<Ticket>()

    var arrayRowCol:[[Int]] = []

    selectSeat:while true{

        system("clear")

        displaySeats{

            showTime.seats

        }

        print("Select Seat : ",terminator: "")

        do{

            if let input = readLine(){

                let rowCol = try showTime.checkSeat(seatNumber: input.uppercased())

                arrayRowCol.append(rowCol)

                if let movieName = showTime.movie?.titleUpper{

                    if let theaterNo = showTime.theater?.id{

                        tickets.enqueue(item:Ticket(seatNumber: input, movie: movieName, price: showTime.getSeat(rowCol: rowCol).price,theaterNo: "\(theaterNo)"))

                    }

                }

                print("Do you want to select more : ",terminator: "")

                if let reInput = readLine(){

                    switch reInput {

                        case "Y","y":

                            continue selectSeat

                        default:

                            displayBuyTicket(rowCol: arrayRowCol, showTimeIndex: showTimeIndex,tickets:tickets)

                    }

                }

            }

        }catch{

            pauseFunc("\(error)")

        }

    }

}



func displayBuyTicket(rowCol:[[Int]],showTimeIndex:Int,tickets:Store<Ticket>){

    while true{

        system("clear")

        var total:Double = Ticket.sum(tickets: tickets)

        tickets.show()



        print("total : ",total)

        do{

            print("Input Money : ",terminator: "")

            if let input = Double(readLine()!){

                if input < total{throw InputError.invalidInput}

                pauseFunc("Purchase Completed!")

                cinema.showTimeList[showTimeIndex].setAvailableSeat(rowCol: rowCol)

                cinema.ticketHistory = joinQueue(first: cinema.ticketHistory, second: tickets) as! Store<Ticket>

                cinema.ticketHistory.show()

                pauseFunc()

                displaySelectMovie()

            }else{

                throw InputError.invalidInput

            }

        }catch{

            pauseFunc("\(error)")

        }

    }

}

// displaySelectMovie()

main()