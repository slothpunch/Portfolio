from google_play_scraper import app, reviews_all, reviews, Sort

class AppInfo:
    
    ###########
    # English #
    ###########
    
    def __init__ (self, app_id, num_reviews = 1):
        self.app_id = app_id
        self.num_reviews = num_reviews
    
    def get_en_app_details(self):
        app_details= app(
            self.app_id,
            lang='en', # defaults to 'en'
            country='us' # defaults to 'us'
        )
        return app_details
    
    def get_en_all_reviews(self):
        all_reviews = reviews_all(
            self.app_id,
            sleep_milliseconds=0, # defaults to 0
            lang='en', # defaults to 'en'
            country='us', # defaults to 'us'
            sort=Sort.MOST_RELEVANT, # defaults to Sort.MOST_RELEVANT
            filter_score_with=None # defaults to None(means all score) upto 5
        )
        return all_reviews
    
    def get_en_reviews(self):
        result, continuation_token = reviews(
            self.app_id,
            lang='en', # defaults to 'en'
            country='us', # defaults to 'us'
            sort=Sort.NEWEST, # defaults to Sort.NEWEST
            count=self.num_reviews, # defaults to 100
            filter_score_with=None # defaults to None(means all score)
        )
        return result
    
    ##########
    # Korean #
    ##########
    
    def get_ko_app_details(self):
        app_details= app(
            self.app_id,
            lang='ko', 
            country='kr' 
        )
        return app_details
    
    def get_ko_all_reviews(self):
        all_reviews = reviews_all(
            self.app_id,
            sleep_milliseconds=0, 
            lang='ko',
            country='kr', 
            sort=Sort.MOST_RELEVANT, 
            filter_score_with=None
        )
        return all_reviews
    
    def get_ko_reviews(self):
        result, continuation_token = reviews(
            self.app_id,
            lang='ko', 
            country='kr', 
            sort=Sort.NEWEST, 
            count=self.num_reviews, 
            filter_score_with=None 
        )
        return result
