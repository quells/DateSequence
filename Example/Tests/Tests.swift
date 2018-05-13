// https://github.com/Quick/Quick

import Quick
import Nimble
import DateSequence

class TableOfContentsSpec: QuickSpec {
    override func spec() {
        let start = "2018-01-01"
        let end   = "2018-01-31"
        let endDate = DashedISO8601DateFormatter.shared.date(from: end)!
        
        describe("a bounded date sequence") {
            context("can have an open right bound") {
                // [start, end)
                let open = try! DateSequence(from: start, to: end, every: (1, .day))
                it("will not contain the end date") {
                    expect(try! open.contains(end)) == false
                }
            }
            
            context("can have a closed right bound") {
                // [start, end]
                let closed = try! DateSequence(from: start, through: end, every: (1, .day))
                it("might contain the end date") {
                    expect(try! closed.contains(end)) == true
                }
                
                // [start, end)
                let maybe = try! DateSequence(from: start, through: end, every: (7, .day))
                it("might not contain the end date") {
                    expect(try! maybe.contains(end)) == false
                }
            }
            
            context("always") {
                let open   = try! DateSequence(from: start, to:      end, every: (1, .day))
                let closed = try! DateSequence(from: start, through: end, every: (1, .day))
                it("has a closed left bound") {
                    expect(try! open.contains(start)) == true
                    expect(try! closed.contains(start)) == true
                }
            }
            
            context("can be reversed") {
                let reversed = try! (try! DateSequence(from: start, through: end, every: (1, .day))).reversed()
                it("starts with the end") {
                    expect(reversed.first) == endDate
                }
            }
            
            context("can be consumed") {
                let sequence = try! DateSequence(from: start, through: end, every: (1, .day))
                for _ in sequence { /* do stuff */ }
                it("will return nil") {
                    expect(sequence.next()).to(beNil())
                }
            }
            
            context("can be stored in an array") {
                let sequence = try! DateSequence(from: start, through: end, every: (1, .day))
                let array = Array(sequence)
                for _ in array { /* do stuff */ }
                it("will not be consumed") {
                    expect(array.count) == 31
                }
            }
        }
        
        describe("an infinite date sequence") {
            context("goes on forever") {
                let daily = try! DateSequence(starting: start, every: (1, .day))
                
                it("still works with contain") {
                    expect(try! daily.contains(end)) == true
                    expect(daily.contains(endDate)) == true
                }
                
                it("mostly works with contain") {
                    expect { try daily.contains { _ in return false } }.to(throwError())
                }
                
                it("throws if you try to reverse it") {
                    expect{ try daily.reversed() }.to(throwError())
                }
                
                let millenia = try! DateSequence(starting: start, every: (1000, .year))
                for _ in 0...1000 { _ = millenia.next() }
                
                it("will never return nil") {
                    expect(millenia.next()).toNot(beNil())
                }
            }
        }
    }
}
