import tweepy
import pandas as pd
import config

consumer_key = config.C_KEY
consumer_secret = config.C_SECRET
access_token = config.A_TOKEN
access_secret = config.A_SECRET

auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_secret)
api = tweepy.API(auth)

limit = 4000
time = []
tweets = []
likes = []
retweets = []

for i in tweepy.Cursor(api.user_timeline, id="bankneocommerce",tweet_mode=“extended”).items(limit):
  time.append(i.created_at)
  tweets.append(i.full_text)
  likes.append(i.favorite_count)
  retweets.append(i.retweet_count)

df = pd.DataFrame({'tweets':tweets,'likes':likes,'retweets':retweets})
df.head()
