import pandas as pd
import regex as re

def find_countries(app_df):
    country_names = ['Albania', 'Algeria', 'Andorra', 'Angola', 'Antigua and Barbuda', 'Argentina', 'Armenia', 'Australia', 'Austria', 'Azerbaijan', 'Bahamas', 'Bahrain', 'Bangladesh', 'Barbados', 'Belarus', 'Belgium', 'Belize', 'Benin', 'Bhutan', 'Bolivia', 'Bosnia and Herzegovina', 'Botswana', 'Brazil', 'Brunei', 'Bulgaria', 'Burkina Faso', 'Burundi', 'Cabo Verde', 'Cambodia', 'Cameroon', 'Canada', 'Central African Republic', 'Chad', 'Chile', 'China', 'Colombia', 'Comoros', 'Congo', 'Costa Rica', 'Croatia', 'Cuba', 'Cyprus', 'Czechia', 'Democratic Republic of the Congo', 'Denmark', 'Djibouti', 'Dominica', 'Dominican Republic', 'Ecuador', 'Egypt', 'El Salvador', 'Equatorial Guinea', 'Eritrea', 'Estonia', 'Eswatini', 'Ethiopia', 'Fiji', 'Finland', 'France', 'Gabon', 'Gambia', 'Georgia', 'Germany', 'Ghana', 'Greece', 'Grenada', 'Guatemala', 'Guinea', 'Guinea-Bissau', 'Guyana', 'Haiti', 'Holy See', 'Honduras', 'Hungary', 'Iceland', 'India', 'Indonesia', 'Iran', 'Iraq', 'Ireland', 'Israel', 'Italy', 'Jamaica', 'Japan', 'Jordan', 'Kazakhstan', 'Kenya', 'Kiribati', 'Kuwait', 'Kyrgyzstan', 'Laos', 'Latvia', 'Lebanon', 'Lesotho', 'Liberia', 'Libya', 'Liechtenstein', 'Lithuania', 'Luxembourg', 'Madagascar', 'Malawi', 'Malaysia', 'Maldives', 'Mali', 'Malta', 'Marshall Islands', 'Mauritania', 'Mauritius', 'Mexico', 'Micronesia', 'Moldova', 'Monaco', 'Mongolia', 'Montenegro', 'Morocco', 'Mozambique', 'Myanmar', 'Namibia', 'Nauru', 'Nepal', 'Netherlands', 'New Zealand', 'Nicaragua', 'Niger', 'Nigeria', 'North Korea', 'North Macedonia', 'Norway', 'Oman', 'Pakistan', 'Palau', 'Palestine State', 'Panama', 'Papua New Guinea', 'Paraguay', 'Peru', 'Philippines', 'Poland', 'Portugal', 'Qatar', 'Romania', 'Russia', 'Rwanda', 'Saint Kitts and Nevis', 'Saint Lucia', 'Saint Vincent and the Grenadines', 'Samoa', 'San Marino', 'Sao Tome and Principe', 'Saudi Arabia', 'Senegal', 'Serbia', 'Seychelles', 'Sierra Leone', 'Singapore', 'Slovakia', 'Slovenia', 'Solomon Islands', 'Somalia', 'South Africa', 'Korea', 'South Sudan', 'Spain', 'Sri Lanka', 'Sudan', 'Suriname', 'Sweden', 'Switzerland', 'Syria', 'Tajikistan', 'Tanzania', 'Thailand', 'Timor-Leste', 'Togo', 'Tonga', 'Trinidad and Tobago', 'Tunisia', 'Turkey', 'Turkmenistan', 'Tuvalu', 'Uganda', 'Ukraine', 'United Arab Emirates', 'United Kingdom', 'United States', 'Uruguay', 'Uzbekistan', 'Vanuatu', 'Venezuela', 'Vietnam', 'Yemen', 'Zambia', 'Zimbabwe']
    country_name_variations = ['USA', 'UK', 'Czech Republic', 'United Arab Emirates', 'U.A.E.', 'Hong Kong', 'HongKong', 'viet nam']

    combined_country_names = country_names + country_name_variations
    combined_country_names = [i.lower() for i in combined_country_names]

    app_df['country'] = 0

    for i in range(len(app_df['address'])):
        for name in combined_country_names:
            if name in app_df.loc[i, 'address']:
                app_df.loc[i, 'country'] = name

    usa_df = pd.read_html('https://en.wikipedia.org/wiki/List_of_United_States_cities_by_population')
    usa_df = pd.DataFrame(usa_df[4])
    # Drop the first row as it is NaN
    usa_df = usa_df.drop(usa_df.index[0])
    
    usa_df = usa_df[['City', 'ST']] # - Added on 2023.01.11
    usa_df.columns = usa_df.columns.droplevel(0) # - Added on 2023.01.11
    
    usa_df['City'] = usa_df['City'].apply(lambda x: re.sub(r'\[.*?\]', '', x))
    usa_df['ST'] = usa_df['ST'].apply(lambda x: re.sub(r'\[.*?\]', '', x)) # - Added on 2023.12.23
    # usa_df['State[c]'] = usa_df['State[c]'].apply(lambda x: re.sub(r'\[.*?\]', '', x))
    # Drop the first row as it is NaN - Added on 2023.12.23
    usa_df = usa_df.drop(usa_df.index[0])
    
    usa_cities = usa_df['City'].str.lower().to_list()
    # usa_states = usa_df['ST'].str.lower().to_list()

    usa_cities = set(usa_cities)
    # usa_states = set(usa_states)

    # USA cities
    for i in range(len(app_df['address'])):
        for name in usa_cities:
            if name in app_df.loc[i, 'address']:
                app_df.loc[i, 'country'] = 'usa'

    # USA states - Commented on 2023.12.23
    # for i in range(len(app_df['address'])):
    #     for name in usa_states:
    #         if name in app_df.loc[i, 'address']:
    #             app_df.loc[i, 'country'] = 'usa'
                
    # USA states two-letter abbreviation
    usa_states_abb = pd.read_html('https://www.faa.gov/air_traffic/publications/atpubs/cnt_html/appendix_a.html')[0]
    abb1 = usa_states_abb['STATE(TERRITORY).1'].str.lower().to_list()
    abb2 = usa_states_abb['STATE(TERRITORY).3'].str.lower().to_list()
    abb3 = usa_states_abb['STATE(TERRITORY).5'].str.lower().to_list()
    
    # State full name - Added on 2023.12.23
    st1 = usa_states_abb['STATE(TERRITORY)'].str.lower().to_list()
    st2 = usa_states_abb['STATE(TERRITORY).2'].str.lower().to_list()
    st3 = usa_states_abb['STATE(TERRITORY).4'].str.lower().to_list()
    
    st_list = st1 + st2 + st3 # - Added on 2023.12.23
    
    # USA states - Added on 2023.12.23
    for i in range(len(app_df['address'])):
        for name in st_list:
            if name in app_df.loc[i, 'address']:
                app_df.loc[i, 'country'] = 'usa'

    abb_list = abb1 + abb2 + abb3

    pattern = r'\s[a-zA-Z]{2}(\s|\.?\,?\s?)\d{5}'

    for i in range(len(app_df['address'])):
        for state in abb_list:
            abb = re.search(pattern, app_df.loc[i, 'address'])
            # if (abb != None) & (abb[0][1:3] in abb_list): # error... why? 
            #  In Python, & is a bitwise AND operator, not a logical AND operator
            #  It performs bitwise AND operations on integers, but it doesn't work for combining boolean conditions like and does
            if abb is not None and abb[0][1:3] in abb_list:
                    app_df.loc[i, 'country'] = 'usa'

    for i in range(len(app_df)):
        if 'google' in app_df.loc[i, 'developer'].lower():
            app_df.loc[i, 'country'] = 'usa'
        if 'microsoft' in app_df.loc[i, 'developer'].lower():
            app_df.loc[i, 'country'] = 'usa'

    # Paris
    for i in range(len(app_df['address'])):
        if 'paris' in app_df.loc[i, 'address']:
            app_df.loc[i, 'country'] = 'france'
    app_df['country'].value_counts().head()

    # Australia
    au_states = ['act', 'nsw', 'nt', 'qld', 'sa', 'vic', 'tas', 'wa']

    pattern = r'\s[a-zA-Z]{3}(\s|\.?\,?\s?)\d{4}' # e.g. nsw 2000

    for i in range(len(app_df['address'])):
        for state in au_states:
            address = app_df.loc[i, 'address'][-12:]
            abb = re.search(pattern, address)
            # if (abb != None) & (abb[0][1:3] in abb_list):
            if abb is not None and abb[0][1:4] in au_states:
                app_df.loc[i, 'country'] = 'australia'

    au_cities = ['sydney', 'parramatta']
    
    for i in range(len(app_df['address'])):
        for name in au_cities:
            if name in app_df.loc[i, 'address']:
                app_df.loc[i, 'country'] = 'australia'

    # Korea

    # if kr_filltering:
    pattern = '[ㄱ-ㅎ가-힣]+'
    
    # Address contains Korea
    for i in range(len(app_df)):
        if re.search(pattern, app_df.loc[i, 'address']) is not None:
            app_df.loc[i, 'country'] = 'korea'

    # Developer name is Korea
    for i in range(len(app_df)):
        if re.search(pattern, app_df.loc[i, 'developer']) is not None:
            app_df.loc[i, 'country'] = 'korea'

    # Title is Korean 
    ko_title_ls = ['하나로', '카톡', '카카오', '현대', '삼성', 'samsung', '엘지', 'lg', '롯데', 'lotte']
    for i in range(len(app_df)):
        for title in ko_title_ls:
            if title in app_df.loc[i, 'title']:
                app_df.loc[i, 'country'] = 'korea'

    # Address
    ko_ls = ['seoul', 'korea', '.go.kr', 'gyeonggi', '-ro', '-gil', '-gu']
    for i in range(len(app_df)):
        for ko in ko_ls:
            if ko in app_df.loc[i, 'address']:
                app_df.loc[i, 'country'] = 'korea'
                
    
    # China
    ch_ls = ['中国广']
    for i in range(len(app_df['address'])):
        for name in ch_ls:
            if name in app_df.loc[i, 'address']:
                app_df.loc[i, 'country'] = 'china'
    
    # Japan
    jp_ls = ['東京都', '京都府', '神奈川', '福岡県']
    for i in range(len(app_df['address'])):
        for name in jp_ls:
            if name in app_df.loc[i, 'address']:
                app_df.loc[i, 'country'] = 'japan'

    # Netherlands
    neth_ls = ['amsterdam']
    for i in range(len(app_df['address'])):
        for name in neth_ls:
            if name in app_df.loc[i, 'address']:
                app_df.loc[i, 'country'] = 'netherlands'
                
    # UK
    uk_ls = ['london', 'leamington spa', 'england']
    for i in range(len(app_df['address'])):
        for name in uk_ls:
            if name in app_df.loc[i, 'address']:
                app_df.loc[i, 'country'] = 'uk'
                
    # Russia
    rs_ls = ['moscow', '.ru', 'yelets']
    for i in range(len(app_df['address'])):
        for name in rs_ls:
            if name in app_df.loc[i, 'address']:
                app_df.loc[i, 'country'] = 'russia'
                
                
    # Hong Kong
    hk_ls = ['香港', 'hk', 'hone kong']
    for i in range(len(app_df['address'])):
        for name in hk_ls:
            if name in app_df.loc[i, 'address']:
                app_df.loc[i, 'country'] = 'hong kong'

    # Vietnam
    vn_ls = ['ha noi']
    for i in range(len(app_df['address'])):
        for name in vn_ls:
            if name in app_df.loc[i, 'address']:
                app_df.loc[i, 'country'] = 'viet nam'

    # Germany
    gm_ls = ['kastellaun']
    for i in range(len(app_df['address'])):
        for name in gm_ls:
            if name in app_df.loc[i, 'address']:
                app_df.loc[i, 'country'] = 'germany'

    # Romania
    rm_ls = ['mihai eminescu']
    for i in range(len(app_df['address'])):
        for name in rm_ls:
            if name in app_df.loc[i, 'address']:
                app_df.loc[i, 'country'] = 'romania'

    # Turkey
    tk_ls = ['i̇stanbul']
    for i in range(len(app_df['address'])):
        for name in tk_ls:
            if name in app_df.loc[i, 'address']:
                app_df.loc[i, 'country'] = 'turkey'

    # Israel
    isr_ls = ['tel aviv']
    for i in range(len(app_df['address'])):
        for name in isr_ls:
            if name in app_df.loc[i, 'address']:
                app_df.loc[i, 'country'] = 'israerl'

    # Canada
    ca_ls = ['south saskatoon']
    for i in range(len(app_df['address'])):
        for name in ca_ls:
            if name in app_df.loc[i, 'address']:
                app_df.loc[i, 'country'] = 'canada'

    # India
    id_ls = ['gujarat']
    for i in range(len(app_df['address'])):
        for name in id_ls:
            if name in app_df.loc[i, 'address']:
                app_df.loc[i, 'country'] = 'India'

    # Indonesia
    idn_ls = ['jawa barat']
    for i in range(len(app_df['address'])):
        for name in idn_ls:
            if name in app_df.loc[i, 'address']:
                app_df.loc[i, 'country'] = 'Indonesia'

    # Capitalise the first letter of each word 
    app_df['country'] = app_df['country'].apply(lambda x: str(x).title())
    
    # Make country names consistent
    app_df['country'] = app_df['country'].apply(lambda x: 'Vietnam' if x == 'Viet Nam' else x)
    app_df['country'] = app_df['country'].apply(lambda x: 'Hong Kong' if x == 'Hongkong' else x)
    app_df['country'] = app_df['country'].apply(lambda x: 'USA' if x == 'Usa' else 'UK' if x == 'Uk' or x == 'United Kingdom' else x)

    return app_df