import Foundation
import FeedKit
import Files

let replacementMark = "<!-- Enter here -->"

guard let feedUrl = URL(string: "https://www.swiftbysundell.com/podcast?format=RSS") else { fatalError("Error: wrong url") }
guard let feedItems = FeedParser(URL: feedUrl).parse().rssFeed?.items else { fatalError("Error: feed items") }

guard let file = try? File(path: CommandLine.arguments[1]) else { fatalError("Error getting file") }
guard let indexHtml = try? file.readAsString() else { fatalError("Error reading file") }

guard let lowerBound = indexHtml.range(of: replacementMark)?.upperBound else { fatalError("Error getting lowerBound")}
guard let upperBound = indexHtml.range(of: replacementMark, options: String.CompareOptions.backwards)?.lowerBound else { fatalError("Error getting upper bound")}

let newContent = feedItems.reduce("") { (newContent, item) -> String in
    let itemIndex = String((feedItems.firstIndex(of: item) as Int? ?? 1) % 5 + 1)
    return newContent +
        """

            <div class="d-block d-md-flex podcast-entry bg-white mb-5" data-aos="fade-up">
              <div class="image" style="background-image: url('images/img_\(itemIndex).jpg');"></div>
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

        """
}

try file.write(string: indexHtml.replacingCharacters(in: lowerBound..<upperBound, with: newContent))
