
############################
# app_details and rankings #
############################

import json
import time as time
from datetime import date, datetime

import pandas as pd
import regex as re
from funcy import project  # To select multiple dictionary keys

import gps_app_info

today_date = date.today().strftime('%Y%m%d') # 20230707
today_name = date.today().strftime('%A') # Wednesday

# MongoDB connection
import os

from dotenv import find_dotenv, load_dotenv
from pymongo import MongoClient

load_dotenv(find_dotenv())

password = os.environ.get('MONGODB_PW')

connection_string = f'mongodb+srv://admin:{password}@portfolio.7rxzcna.mongodb.net/'
# connection_string = f'mongodb+srv://admin:admin@portfolio.7rxzcna.mongodb.net/'

client = MongoClient(connection_string)

# Korea
ko_gps_db = client['ko_google_play_store']

ko_apps_collection = ko_gps_db['apps']
ko_apps_numeric_collection = ko_gps_db['apps_numeric']
ko_reviews_collection = ko_gps_db['reviews']
ko_rankings_collection = ko_gps_db['rankings']

# Australia
au_gps_db = client['au_google_play_store']

au_apps_collection = au_gps_db['apps']
au_apps_numeric_collection = au_gps_db['apps_numeric']
au_reviews_collection = au_gps_db['reviews']
au_rankings_collection = au_gps_db['rankings']


def collect_ko_app_and_ranking(df):
    
    print('########################################')
    print('ko_app_combined', df['date_collected'][0])
    print('########################################')
    
    # Append one after another
    ko_app_combined = pd.concat([df['top_grossing'], 
                                df['top_free'], 
                                df['top_paid']])

    # Change it DataFrame, remove duplicates and add collected date
    ko_app_combined = pd.DataFrame(ko_app_combined).rename(columns = {0 : 'app_id'}).reset_index(drop = True)
    print('Before dropping duplicates: ', len(ko_app_combined))
    ko_app_combined = ko_app_combined.drop_duplicates().reset_index(drop = True)
    print('After dropping duplicates: ', len(ko_app_combined))
    ko_app_combined['date_collected'] = df['date_collected'][0]

    # Save ko_app_combined as CSV file
    ko_app_combined.to_csv('./app_id_combined/ko_app_combined_'+ str(today_date) +'.csv', index = False)
    
    ###########
    # Ranking #
    ###########

    # if today_name == 'Thursday':
    # if today_name == 'Monday':
    
    print('\n######################################')
    print('ko_app_ranking', df['date_collected'][0])
    print('########################################')
    
    # Merge top_grossing_ranking, top_free_ranking and top_paid_ranking
    top_grossing_ranking = df[['top_grossing', 'ranking']].rename(columns = {'top_grossing' : 'app_id', 'ranking' : 'top_grossing_ranking'})
    top_free_ranking = df[['top_free', 'ranking']].rename(columns = {'top_free' : 'app_id', 'ranking' : 'top_free_ranking'})
    top_paid_ranking = df[['top_paid', 'ranking']].rename(columns = {'top_paid' : 'app_id', 'ranking' : 'top_paid_ranking'})

    ko_app_ranking = ko_app_combined.merge(top_grossing_ranking, how = 'left', on = 'app_id')
    ko_app_ranking = ko_app_ranking.merge(top_free_ranking, how = 'left', on = 'app_id')
    ko_app_ranking = ko_app_ranking.merge(top_paid_ranking, how = 'left', on = 'app_id')
    ko_app_ranking.fillna(0, inplace = True)
    ko_app_ranking['date_collected'] = str(date.today())
    ko_app_ranking[['top_grossing_ranking', 'top_free_ranking', 'top_paid_ranking']] = ko_app_ranking[['top_grossing_ranking', 'top_free_ranking', 'top_paid_ranking']].astype(int)

    print('ko_app_ranking: ', len(ko_app_ranking))

    # Save ko_app_ranking as CSV file
    ko_app_ranking.to_csv('./app_ranking/ko_app_ranking_'+ str(today_date) +'.csv', index = False)

    # To JSON format
    ko_app_ranking_json = ko_app_ranking.to_json(orient = 'records')
    ko_app_ranking_json_parsed = json.loads(ko_app_ranking_json)
    
    # Insert ko_app_ranking into MongoDB 
    try:
        ko_rankings_collection.insert_many(
            ko_app_ranking_json_parsed[:]
        )
    except: 
        print('ko_rankings_collection error')
            
    
    ###############
    # App details #
    ###############
    
    print('\n######################################')
    print('ko_app_details', df['date_collected'][0])
    print('########################################')
    
    app_detail_list = ['title', 'realInstalls', 'score', 'ratings', 'reviews', 'histogram', 'price', 'free', 'currency', 'sale', 'originalPrice', 'inAppProductPrice', 'developer', 'developerId', 'developerEmail', 'developerAddress', 'genre', 'genreId', 'contentRating', 'contentRatingDescription', 'released', 'updated', 'version', 'url']

    print('Getting app information...')

    # Take 5 mins for 570 apps 
    for index, id in enumerate(ko_app_combined['app_id']):
        try:
            app_info_class = gps_app_info.AppInfo(id)
            # Select only the keys in app_detail_list
            selected_dict = project(app_info_class.get_ko_app_details(), app_detail_list)
            for key in app_detail_list:
                if key != 'histogram':
                    ko_app_combined.loc[index, key] = selected_dict[key]
                else:
                    ko_app_combined.loc[index, 'score_1'] = selected_dict[key][0]
                    ko_app_combined.loc[index, 'score_2'] = selected_dict[key][1]
                    ko_app_combined.loc[index, 'score_3'] = selected_dict[key][2]
                    ko_app_combined.loc[index, 'score_4'] = selected_dict[key][3]
                    ko_app_combined.loc[index, 'score_5'] = selected_dict[key][4]
        except:
            ko_app_combined.loc[index, 'title'] = 'App Not Found'
    
    # Drop rows whose titles are 'App Not Found'
    not_found_index = ko_app_combined[ko_app_combined['title'] == 'App Not Found'].index
    ko_app_combined = ko_app_combined.drop(index = not_found_index).reset_index(drop = True)
    ko_app_combined['date_collected'] = str(date.today()) # 2023-07-07
    
    # Extract numbers from inAppProductPrice and set the min and max price
    pattern = r'\$?(\d+(?:,\d{3})*(?:\.\d+)?)' # 4 Oct 2023
    # pattern = r'\d{1,3}(?:,\d{3})' # it doesn't work - 4 Oct 2023
    ko_app_combined['price_range'] = ko_app_combined['inAppProductPrice'].fillna(0)
    ko_app_combined['price_range'] = ko_app_combined['price_range'].apply(lambda x: re.findall(pattern, str(x)))

    ko_app_combined['inAppProductPrice_min'] = ko_app_combined['price_range'].apply(lambda x: x[0].replace(',', '') if len(x) > 0 else 0)
    ko_app_combined['inAppProductPrice_max'] = ko_app_combined['price_range'].apply(lambda x: x[1].replace(',', '') if len(x) == 2 else 
                                                                            (x[0].replace(',', '') if len(x) == 1 else 0))
    # Change float to date
    ko_app_combined['updated'] = ko_app_combined['updated'].apply(lambda x: datetime.fromtimestamp(x).strftime('%Y-%m-%d %H:%M:%S'))
    
    # Separate ko_app_combined into app_cat_list (categorical) and app_num_list (numerical)
    app_cat_list = ['app_id', 'title', 'date_collected', 'free', 'currency', 'sale', 'inAppProductPrice', 'developer', 'developerId', 'developerEmail', 'developerAddress', 'genre', 'genreId', 'contentRating', 'contentRatingDescription', 'released', 'url']
    app_num_list = ['app_id', 'date_collected', 'realInstalls', 'score', 'ratings', 'reviews', 'score_1', 'score_2', 'score_3', 'score_4', 'score_5', 'price', 'originalPrice', 'inAppProductPrice_min', 'inAppProductPrice_max', 'updated', 'version',]

    # Read all app_id from MongoDB
    db_app_ids = ko_apps_collection.distinct('app_id') # list
    
    # Select app ids not in DB
    new_app_ids = set(ko_app_combined['app_id']).difference(set(db_app_ids))
    new_app_df = ko_app_combined[ko_app_combined['app_id'].isin(new_app_ids)]
    print('new_app_ids: ', len(new_app_ids))
    
    # Separate categorical and numerical columns
    app_cat_df = new_app_df[app_cat_list]
    
    # Not new_app_df but ko_app_combined because the content of app_cat is the same, whereas app_num's is changing everyday
    app_num_df = ko_app_combined[app_num_list]
    
    # Save app_cat_df and app_num_df as CSV file
    print('Save app_cat_df and app_num_df as CSV file.')
    app_cat_df.to_csv('./app_details/ko_app_cat_'+ str(today_date) +'.csv', index = False)
    app_num_df.to_csv('./app_details/ko_app_num_'+ str(today_date) +'.csv', index = False)

    # Convert app_cat_df to JSON format
    app_cat_df_json = app_cat_df.to_json(orient = 'records')
    app_cat_df_json_parsed = json.loads(app_cat_df_json)
    
    # Insert app_cat_df into MongoDB 
    try:
        ko_apps_collection.insert_many(
            app_cat_df_json_parsed[:]
        )
    except: 
        print('ko_apps_collection error')
    
    # Convert app_num_df to JSON format
    app_num_df_json = app_num_df.to_json(orient = 'records')
    app_num_df_json_parsed = json.loads(app_num_df_json)
    
    # Insert app_num_df into MongoDB 
    try:
        ko_apps_numeric_collection.insert_many(
            app_num_df_json_parsed[:]
        )
    except: 
        print('ko_apps_numeric_collection error')
        
    print('End\n\n')



def collect_au_app_and_ranking(df):
    
    print('########################################')
    print('au_app_combined', df['date_collected'][0])
    print('########################################')
    
    # Append one after another
    au_app_combined = pd.concat([df['top_grossing'], 
                                df['top_free'], 
                                df['top_paid']])

    # Change it DataFrame, remove duplicates and add collected date
    au_app_combined = pd.DataFrame(au_app_combined).rename(columns = {0 : 'app_id'}).reset_index(drop = True)
    print('Before dropping duplicates: ', len(au_app_combined))
    au_app_combined = au_app_combined.drop_duplicates().reset_index(drop = True)
    print('After dropping duplicates: ', len(au_app_combined))
    au_app_combined['date_collected'] = df['date_collected'][0]

    # Save au_app_combined as CSV file
    au_app_combined.to_csv('./app_id_combined/au_app_combined_'+ str(today_date) +'.csv', index = False)
    
    ###########
    # Ranking #
    ###########

    # if today_name == 'Thursday':
    # if today_name == 'Monday':
    
    print('\n########################################')
    print('au_app_ranking', df['date_collected'][0])
    print('########################################')
    
    # Merge top_grossing_ranking, top_free_ranking and top_paid_ranking
    top_grossing_ranking = df[['top_grossing', 'ranking']].rename(columns = {'top_grossing' : 'app_id', 'ranking' : 'top_grossing_ranking'})
    top_free_ranking = df[['top_free', 'ranking']].rename(columns = {'top_free' : 'app_id', 'ranking' : 'top_free_ranking'})
    top_paid_ranking = df[['top_paid', 'ranking']].rename(columns = {'top_paid' : 'app_id', 'ranking' : 'top_paid_ranking'})

    au_app_ranking = au_app_combined.merge(top_grossing_ranking, how = 'left', on = 'app_id')
    au_app_ranking = au_app_ranking.merge(top_free_ranking, how = 'left', on = 'app_id')
    au_app_ranking = au_app_ranking.merge(top_paid_ranking, how = 'left', on = 'app_id')
    au_app_ranking.fillna(0, inplace = True)
    au_app_ranking['date_collected'] = str(date.today())
    au_app_ranking[['top_grossing_ranking', 'top_free_ranking', 'top_paid_ranking']] = au_app_ranking[['top_grossing_ranking', 'top_free_ranking', 'top_paid_ranking']].astype(int)

    print('au_app_ranking: ', len(au_app_ranking))
    
    # Save au_app_ranking as CSV file
    au_app_ranking.to_csv('./app_ranking/au_app_ranking_'+ str(today_date) +'.csv', index = False)

    # To JSON format
    au_app_ranking_json = au_app_ranking.to_json(orient = 'records')
    au_app_ranking_json_parsed = json.loads(au_app_ranking_json)
    
    # Insert au_app_ranking into MongoDB 
    try:
        au_rankings_collection.insert_many(
            au_app_ranking_json_parsed[:]
        )
    except: 
        print('au_rankings_collection error')
            
    
    ###############
    # App details #
    ###############
    
    print('\n######################################')
    print('au_app_details', df['date_collected'][0])
    print('########################################')
    
    app_detail_list = ['title', 'realInstalls', 'score', 'ratings', 'reviews', 'histogram', 'price', 'free', 'currency', 'sale', 'originalPrice', 'inAppProductPrice', 'developer', 'developerId', 'developerEmail', 'developerAddress', 'genre', 'genreId', 'contentRating', 'contentRatingDescription', 'released', 'updated', 'version', 'url']

    print('Getting app information...')

    # Take 5 mins for 570 apps 
    for index, id in enumerate(au_app_combined['app_id']):
        try:
            app_info_class = gps_app_info.AppInfo(id)
            # Select only the keys in app_detail_list
            selected_dict = project(app_info_class.get_en_app_details(), app_detail_list)
            for key in app_detail_list:
                if key != 'histogram':
                    au_app_combined.loc[index, key] = selected_dict[key]
                else:
                    au_app_combined.loc[index, 'score_1'] = selected_dict[key][0]
                    au_app_combined.loc[index, 'score_2'] = selected_dict[key][1]
                    au_app_combined.loc[index, 'score_3'] = selected_dict[key][2]
                    au_app_combined.loc[index, 'score_4'] = selected_dict[key][3]
                    au_app_combined.loc[index, 'score_5'] = selected_dict[key][4]
        except:
            au_app_combined.loc[index, 'title'] = 'App Not Found'
    
    # Drop rows whose titles are 'App Not Found'
    not_found_index = au_app_combined[au_app_combined['title'] == 'App Not Found'].index
    au_app_combined = au_app_combined.drop(index = not_found_index).reset_index(drop = True)
    au_app_combined['date_collected'] = str(date.today()) # 2023-07-07
    
    # Extract numbers from inAppProductPrice and set the min and max price
    pattern = r'\$?(\d+(?:,\d{3})*(?:\.\d+)?)' # 4 Oct 2023
    # pattern = r'\d{1,3}(?:,\d{3})' # it doesn't work -- 4 Oct 2023 
    au_app_combined['price_range'] = au_app_combined['inAppProductPrice'].fillna(0)
    au_app_combined['price_range'] = au_app_combined['price_range'].apply(lambda x: re.findall(pattern, str(x)))

    au_app_combined['inAppProductPrice_min'] = au_app_combined['price_range'].apply(lambda x: x[0].replace(',', '') if len(x) > 0 else 0)
    au_app_combined['inAppProductPrice_max'] = au_app_combined['price_range'].apply(lambda x: x[1].replace(',', '') if len(x) == 2 else 
                                                                            (x[0].replace(',', '') if len(x) == 1 else 0))

    # Change float to date
    au_app_combined['updated'] = au_app_combined['updated'].apply(lambda x: datetime.fromtimestamp(x).strftime('%Y-%m-%d %H:%M:%S'))

    # Separate au_app_combined into app_cat_list (categorical) and app_num_list (numerical)
    app_cat_list = ['app_id', 'title', 'date_collected', 'free', 'currency', 'sale', 'inAppProductPrice', 'developer', 'developerId', 'developerEmail', 'developerAddress', 'genre', 'genreId', 'contentRating', 'contentRatingDescription', 'released', 'updated', 'version', 'url']
    app_num_list = ['app_id', 'date_collected', 'realInstalls', 'score', 'ratings', 'reviews', 'score_1', 'score_2', 'score_3', 'score_4', 'score_5', 'price', 'originalPrice', 'inAppProductPrice_min', 'inAppProductPrice_max']

    # Read all app_id from MongoDB
    db_app_ids = au_apps_collection.distinct('app_id') # list
    
    # Select app ids not in DB
    new_app_ids = set(au_app_combined['app_id']).difference(set(db_app_ids))
    new_app_df = au_app_combined[au_app_combined['app_id'].isin(new_app_ids)]
    print('new_app_ids: ', len(new_app_ids))

    # Separate categorical and numerical columns
    app_cat_df = new_app_df[app_cat_list]
    
    # Not new_app_df but au_app_combined because the content of app_cat is the same, whereas app_num's is changing everyday
    app_num_df = au_app_combined[app_num_list]
    
    # Save app_cat_df and app_num_df as CSV file
    print('Save app_cat_df and app_num_df as CSV file.')
    app_cat_df.to_csv('./app_details/au_app_cat_'+ str(today_date) +'.csv', index = False)
    app_num_df.to_csv('./app_details/au_app_num_'+ str(today_date) +'.csv', index = False)

    # Convert app_cat_df to JSON format
    app_cat_df_json = app_cat_df.to_json(orient = 'records')
    app_cat_df_json_parsed = json.loads(app_cat_df_json)
    
    # Insert app_cat_df into MongoDB 
    try:
        au_apps_collection.insert_many(
            app_cat_df_json_parsed[:]
        )
    except: 
        print('au_apps_collection error')
    
    # Convert app_num_df to JSON format
    app_num_df_json = app_num_df.to_json(orient = 'records')
    app_num_df_json_parsed = json.loads(app_num_df_json)
    
    # Insert app_num_df into MongoDB 
    try:
        au_apps_numeric_collection.insert_many(
            app_num_df_json_parsed[:]
        )
    except: 
        print('au_apps_numeric_collection error')
        
    print('End')