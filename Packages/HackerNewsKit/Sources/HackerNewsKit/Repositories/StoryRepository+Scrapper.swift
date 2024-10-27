import Combine
import Foundation
import Alamofire
import SwiftSoup

public enum FetchError: Error {
    case noComment
    case possibleParsingFailure(Int)
    case rateLimited
    case networkError(AFError)
    case generic(Error)
}


/// Instead of fetching comments one by one using API, we fetch directly from HN pages, and parse
/// `Comment` using selectors.
extension StoryRepository {
    fileprivate static let itemBaseUrl = "https://news.ycombinator.com/item?id=";
    fileprivate static let athingComtrSelector = "#hnmain > tbody > tr > td > table > tbody > .athing.comtr";
    fileprivate static let commentTextSelector = "td > table > tbody > tr > td.default > div.comment > div.commtext";
    fileprivate static let commentHeaderSelector = "td > table > tbody > tr > td.default > div > span > a";
    fileprivate static let commentAgeSelector = "td > table > tbody > tr > td.default > div > span > span.age";
    fileprivate static let commentIndentSelector = "td > table > tbody > tr > td.ind";
    
    public func fetchCommentsRecursively(from item: any Item, completion: @escaping (Comment?) -> Void) async {
        let itemId = item.id;
        let descendants = item is Story ? item.descendants : nil;
        var parentTextCount = 0
        let dateFormatter : DateFormatter = DateFormatter()
        let locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = locale

        func fetchElements(page: Int) async throws -> Elements {
            do {
                let url = "\(Self.itemBaseUrl)\(itemId)&p=\(page)"
                let response = await AF.request(url).serializingString().response
                let html = try response.result.get()
                
                if page == 1 {
                    parentTextCount = html.components(separatedBy:"parent").count - 1
                }
                
                let document = try SwiftSoup.parse(html)
                let elements = try document.select(Self.athingComtrSelector);
                
                return elements
            } catch {
                if let e = error as? AFError {
                    switch e.responseCode {
                    case 403:
                        throw FetchError.rateLimited
                    default:
                        throw FetchError.networkError(e)
                    }
                }
                throw FetchError.generic(error)
            }
        }
        
        if descendants == 0 || item.kids.isNullOrEmpty {
            completion(nil)
            return
        }
        
        var fetchedCommentIds = Set<Int>();
        var page = 1;
        var elements: Elements
        
        do {
            elements = try await fetchElements(page: page);
        } catch {
            completion(nil)
            return
        }
        
        var indentToParentId = Dictionary<Int, Int>();
        
        if item is Story && (item.descendants ?? 0) > 0 && elements.isEmpty {
            completion(nil)
            return
        }
        
        while elements.isEmpty == false {
            for element in elements {
                /// Get comment id.
                guard let cmtIdString = try? element.attr("id") else { continue }
                guard let cmtId = Int(cmtIdString) else { continue }
                
                /// Get comment text.
                guard let cmtTextElements = try? element.select(Self.commentTextSelector) else { continue }
                guard let cmtText = try? cmtTextElements.first()?.html() else { continue }
                let parsedText = parseCommentTextHtml(html: cmtText)
                
                /// Get comment author.
                guard let cmtHeadElements = try? element.select(Self.commentHeaderSelector) else { continue }
                guard let cmtAuthor = try? cmtHeadElements.first()?.text() else { continue }
                
                /// Get comment age.
                guard let cmtAgeElements = try? element.select(Self.commentAgeSelector) else { continue }
                guard let ageString = try? cmtAgeElements.attr("title").components(separatedBy: .whitespaces).first else { continue }
                guard let timestamp = dateFormatter.date(from: ageString)?.timeIntervalSince1970 else { continue }

                /// Get comment indent.
                guard let cmtIndentElements = try? element.select(Self.commentIndentSelector) else { continue }
                let indentString = try? cmtIndentElements.attr("indent")
                let indent = Int(indentString ?? String()) ?? 0
                
                indentToParentId[indent] = cmtId
                let parentId = indentToParentId[indent - 1] ?? -1
                
                let cmt = Comment(id: cmtId, 
                                  parent: parentId,
                                  text: parsedText,
                                  by: cmtAuthor,
                                  time: Int(timestamp),
                                  level: indent)
                
                fetchedCommentIds.insert(cmt.id)
                completion(cmt)
            }
            
            /// If we didn't successfully got any comment on first page,
            /// and we are sure there are comments there based on the count of
            /// 'parent' text, then this might be a parsing error and possibly is
            /// caused by HN changing their HTML structure, therefore here we
            /// throw an error so that we can fallback to use API instead.
            if page == 1 && parentTextCount > 0 && fetchedCommentIds.isEmpty {
                completion(nil)
                return
            }
            
            if let descendants = descendants, fetchedCommentIds.count >= descendants {
                completion(nil)
                return
            }
            
            page+=1;
            do {
                elements = try await fetchElements(page: page);
            } catch {
                elements = Elements()
            }
        }
        
        completion(nil)
        return
    }
    
    fileprivate func parseCommentTextHtml(html: String) -> String {
        do {
            let replyRegex = try Regex(#"\<div class="reply"\>(.*?)\<\/div\>"#).dotMatchesNewlines()
            let spanRegex = try Regex(#"\<span class="(.*?)"\>(.*?)\<\/span\>"#).dotMatchesNewlines()
            let pRegex = try Regex(#"\<p\>(.*?)\<\/p\>"#).dotMatchesNewlines()
            let codeRegex = try Regex(#"\<pre\>\<code\>(.*?)\<\/code\>\<\/pre\>"#).dotMatchesNewlines()
            let linkRegex = try Regex(#"\<a href=\"(.*?)\".*?\>.*?\<\/a\>"#)
            let iRegex = try Regex(#"\<i\>(.*?)\<\/i\>"#)
            let res = try Entities.unescape(html)
                .replacing(replyRegex) { _ in String() }
                .replacing(spanRegex) { match in
                    if let m = match[2].substring {
                        let matchedStr = String(m)
                        return "\(matchedStr)"
                    }
                    return String()
                }
                .replacing(pRegex) { match in
                    if let m = match[1].substring {
                        let matchedStr = String(m)
                        return "\n\(matchedStr)"
                    }
                    return String()
                }
                .replacing(linkRegex) { match in
                    if let m = match[1].substring {
                        let matchedStr = String(m)
                        return matchedStr
                    }
                    return String()
                }
                .replacing(iRegex) { match in
                    if let m = match[1].substring {
                        let matchedStr = String(m)
                        return "**\(matchedStr)**"
                    }
                    return String()
                }
                .replacing(codeRegex, with: { match in
                    if let m = match[1].substring {
                        let matchedStr = String(m)
                        return "```\n" + matchedStr.replacing("\n", with: "``` \n ``` \n") + "\n```\n"
                    }
                    return String()
                })
            return res.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return error.localizedDescription
        }
    }
}
