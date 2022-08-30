from google_play_scraper import app
import pandas as pd
import numpy as np

from google_play_scraper import Sort, reviews_all
reviews = reviews_all(
    'com.btpn.dc',
    sleep_milliseconds=0, 
    lang=‘id’, 
    country=‘id’, 
    sort=Sort.NEWEST, 
)

df = pd.DataFrame(np.array(reviews),columns=['review'])
df = df.join(pd.DataFrame(df.pop('review').tolist()))
df.head()
