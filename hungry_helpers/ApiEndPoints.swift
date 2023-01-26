/**
 This class contains the end points of all the urls.
 */

import Foundation

class ApiEndPoints: NSObject {
    
    struct Onboarding {
        static let getSettings = "get_settings"
        static let verifyNumber = "auth/verifyNumber"
        static let signup = "registration"
        static let getCategories = "get_categories"
        static let getCities = "get_cities"
        static let getKeywords = "get_keywords"
        static let getStaticpage = "get_staticpage"
        static let inquiry = "inquiry"
        static let getPopupBanner = "get_popup_banner"
    }
    
    struct News {
        static let getNews = "get_news"
        static let getNewsDetail = "get_news_detail"
        static let addBookmark = "add_bookmark"
        static let removeBookmark = "remove_bookmark"
        static let getBookmark = "get_bookmark"
        
    }
    
    struct UploadStories {
        static let addStories = "add_stories"
    }
    
}
