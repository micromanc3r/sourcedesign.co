import Foundation
import FeedKit
import Files

let replacementMark = "<!-- Enter here -->"

guard let feedUrl = URL(string: "https://www.swiftbysundell.com/podcast?format=RSS") else { fatalError("Error: wrong url") }
guard let feedItems = FeedParser(URL: feedUrl).parse().rssFeed?.items else { fatalError("Error: feed items") }

let indexHtmlPathString = CommandLine.arguments[1]

guard let indexHtmlFile = try? File(path: indexHtmlPathString) else { fatalError("Error getting file") }
guard let indexHtml = try? indexHtmlFile.readAsString() else { fatalError("Error reading file") }

guard let lowerBound = indexHtml.range(of: replacementMark)?.upperBound else { fatalError("Error getting lowerBound")}
guard let upperBound = indexHtml.range(of: replacementMark, options: String.CompareOptions.backwards)?.lowerBound else { fatalError("Error getting upper bound")}

var pageCount = 0
let itemsPerPage = 5
let newContent = feedItems.reduce("") { (newContent, item) -> String in
    let itemIndex = (feedItems.firstIndex(of: item) as Int? ?? 1) % itemsPerPage
    if itemIndex == 0 {
        pageCount += 1
    }
    
    let itemIndexString = String(itemIndex + 1)
    return newContent +
        (itemIndex == 0 ? "\n   <div class=\"container page\" id=\"page\(pageCount)\">" : "") +
        """

            <div class="d-block d-md-flex podcast-entry bg-white mb-5" data-aos="fade-up">
              <div class="image" style="background-image: url('images/img_\(itemIndexString).jpg');"></div>
              <div class="text">

                <h3 class="font-weight-light"><a href="single-post.html">\(item.title ?? "Missing title")</a></h3>
                <div class="text-white mb-3"><span class="text-black-opacity-05"><small>By \(item.author ?? "Unknown") <span class="sep">/</span> \(item.pubDate?.description ?? "Unknown") <span class="sep">/</span> 1:30:20</small></span></div>
                <p class="mb-4">\(item.description ?? "No description")</p>

                <div class="player">
                  <audio id="player2" preload="none" controls style="max-width: 100%">
                    <source src="\(item.media?.mediaContents?.first?.attributes?.url ?? "audio link missing")" type="audio/mp3">
                  </audio>
                </div>

              </div>
            </div>

        """ +
        (itemIndex == itemsPerPage - 1 ? "</div>" : "")
}

try indexHtmlFile.write(string: indexHtml.replacingCharacters(in: lowerBound..<upperBound, with: newContent))

// javascript
let pagingJavaScriptPathString = indexHtmlPathString.replacingOccurrences(of: "index.html", with: "js/paging.js")

guard let pagingJavaScriptFile = try? File(path: pagingJavaScriptPathString) else { fatalError("Error getting file") }
guard let pagingJavaScript = try? pagingJavaScriptFile.readAsString() else { fatalError("Error reading file") }

guard let lowerBound2 = pagingJavaScript.range(of: replacementMark)?.upperBound else { fatalError("Error getting lowerBound")}
guard let upperBound2 = pagingJavaScript.range(of: replacementMark, options: String.CompareOptions.backwards)?.lowerBound else { fatalError("Error getting upper bound")}

let newContent2 = "\ntotalPages: \(pageCount),\n//"

try pagingJavaScriptFile.write(string: pagingJavaScript.replacingCharacters(in: lowerBound2..<upperBound2, with: newContent2))
