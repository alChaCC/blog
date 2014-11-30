rake "new_post[XXX]"
rake generate
cp -r AS3 public/
cp -r GA_ABtest public/google-analytics/
cp Resume_Aloha.pdf public/About/
git add .
git commit -m 
git push heroku master
