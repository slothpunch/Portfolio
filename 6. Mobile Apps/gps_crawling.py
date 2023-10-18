from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.common.by import By
from selenium import webdriver
# pip install webdriver-manager
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager

import pandas as pd
from datetime import date
import time

def get_app_data(url_list, country):

    # Install Webdriver 
    SERVICE = Service(ChromeDriverManager().install())

    DRIVER = webdriver.Chrome(service=SERVICE)
    DRIVER.set_window_size(1120, 1000)

    link_dict = {'top_grossing': [], 'top_free': [], 'top_paid': []}

    for dict, url in zip(link_dict, url_list):
        # Go to the target website
        DRIVER.get(url)
        time.sleep(3)
        
        # Scroll down to the end
        for i in range(4):    
            DRIVER.execute_script('window.scrollTo(0, document.body.scrollHeight)')
            time.sleep(2)

        try:
            # Get all tags named a
            app_content = DRIVER.find_elements(By.TAG_NAME, 'a')
            # app_content = DRIVER.find_element(By.XPATH, '//div[@class = "fUEl2e" and @jsname="O2DNWb"]')
            
            # Get all links 
            for lnk in app_content:
                link = lnk.get_attribute('href')
                if 'https://play.google.com/store/apps/details?id=' in link:
                    app_id = link.replace('https://play.google.com/store/apps/details?id=', '')
                    link_dict[dict].append(app_id)
                    # link_dict[dict].append(link)
                    
            print(f'dict: {dict}, \nurl: {url}')
        except NoSuchElementException:
            pass

    # Close webdriver
    DRIVER.close()

    # Change to dataframe and add columns
    app_id_df = pd.DataFrame(link_dict)
    app_id_df['ranking'] = range(1, 201)
    app_id_df['date_collected'] = date.today()

    # Export as a CSV file
    app_id_df.to_csv('./crawling_csv/'+country+'_'+str(date.today())+'.csv', index=False)

    return(app_id_df)