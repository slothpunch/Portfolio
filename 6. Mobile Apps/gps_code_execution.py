import gps_crawling
import etl_code

# games + apps 
GROSSING_URL = 'https://play.google.com/store/apps/collection/topgrossing?clp=ChMKEQoLdG9wZ3Jvc3NpbmcQBxgD:S:ANO1ljJpBI4&gsr=ChUKEwoRCgt0b3Bncm9zc2luZxAHGAM%3D:S:ANO1ljJ_fZk&'
FREE_URL = 'https://play.google.com/store/apps/collection/topselling_free?clp=ChcKFQoPdG9wc2VsbGluZ19mcmVlEAcYAw%3D%3D:S:ANO1ljLwMrI&gsr=ChkKFwoVCg90b3BzZWxsaW5nX2ZyZWUQBxgD:S:ANO1ljIxP20&'
PAID_URL = 'https://play.google.com/store/apps/collection/topselling_paid?clp=ChcKFQoPdG9wc2VsbGluZ19wYWlkEAcYAw%3D%3D:S:ANO1ljKH1g0&gsr=ChkKFwoVCg90b3BzZWxsaW5nX3BhaWQQBxgD:S:ANO1ljK56mE&'
KO_URL = 'hl=ko&gl=kr'
AU_URL = 'hl=en&gl=au'

ko_url_list = [GROSSING_URL+KO_URL, FREE_URL+KO_URL, PAID_URL+KO_URL]
au_url_list = [GROSSING_URL+AU_URL, FREE_URL+AU_URL, PAID_URL+AU_URL]

ko_app_data = gps_crawling.get_app_data(ko_url_list, 'ko')
au_app_data = gps_crawling.get_app_data(au_url_list, 'au')

#################################
# Execution time: about 15 mins #
#################################

etl_code.collect_ko_app_and_ranking(ko_app_data)
etl_code.collect_au_app_and_ranking(au_app_data)
