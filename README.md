What do you get when you combine footage of ultimate frisbee games with the data from the UltiAnalytics apps?

# It's a Plastic Disco, Baby!

This app was built to help you capture every moment of every game, and then give you the ability to actually go find those moments in the footage. Having lots of footage is really great, until you have to comb through hours to figure out when everything happened. If you use the [UltiAnalytics](http://ultianalytics.com) app to track each game, then we can sync that data into the app and line it up with your videos. [Bam.](http://plasticdisco.com/events)


### Quick overview
First, we import all of the "event" data from UltiAnalytics using their API. (Ideally, this would be configurable on a per-user basis, it's hard-coded right now.) This creates a bunch of `Event` objects in our database with timestamps and titles (which are just strings that describe the event, like someone catching a goal).

Then, the user simply uploads their videos onto youtube, then adds them to a playlist. We bulk-import the videos of that playlist, and save them as `Video`s on our end. Then, the user hops into the app, and manually syncs up each video's timestamps (`starts_at` and `ends_at`) with the `Event` data (you only need to sync a single event for each video, because if you have the time correct on that, the rest will also be correct).


### A note on timestamps
The original intention was to use the timestamps from video files in order to automatically sync up the video to the timestamps from UltiAnalytics. However, this doesn't seem to work too well (clocks can be off), and so I ended up manually syncing each video anyways. Because of that, I think that this app will be much easier to maintain and use in the long run if all videos are just manually synced (it only takes about 30 seconds per video to do it, so just take long videos).


## Requirements

- Ruby 2.1.6
- Rails 4.2.4
- Postgres (I suggest [Postgres.app](http://postgresapp.com/))
- Bundler

### Setup

```
git clone https://github.com/kyletns/classy-highlights.git
cd classy-highlights
bundle install
```

If that all goes smoothly, then you'll want to get some data to play around with:

```
rake db:create
rake db:migrate
rake db:seed
```

This should load you up with one user (classyultimate@gmail.com), and a bunch of events and videos. Boot up your console:

```
rails server
```

And have a look at [localhost:3000](http://localhost:3000)!

If you want the Google Oauth to work, you'll need to create a file called `.env` in the root directory which looks like this:

```
OMNIAUTH_PROVIDER_KEY=xxxxx
OMNIAUTH_PROVIDER_SECRET=xxxxx
GOOGLE_API_KEY=xxxxx
```

The live values for these keys on the server come from the [Google API Console](https://console.developers.google.com/apis/credentials?project=classy-highlights-1322), just log in as `classyfootage@gmail.com` on Google and you can find the credentials there. Copy the "Key" value next to "Server key", under "API Keys", and use that as the Google API key in `.env`. Then click "Oauth Key" under "OAuth 2.0 client IDs", and use the "Client ID" as our omniauth provider key, and the "Client secret" as our omniauth provider secret. Once you have those three values in your `.env` file, restart your Rails server and you should be able to login (bottom right corner of any page).

If you don't have access to the Classy Gmail account, you'll need to setup your own API keys. There's a great guide to that in the Yt gem documentation [here](https://github.com/Fullscreen/yt#configuring-your-app).


### Importing data

I was originally hoping that timestamps from the video files would be accurate enough to automatically sync everything up. While this is technically possible, it doesn't seem to be working too great so far. So I've been using a shortcut which ignores the timestamps, which I'll explain below.

#### If you don't mind manually syncing each video

It's really easy! Just upload your videos to youtube, then put them into a playlist called "All videos". The importer class in `lib/importer.rb` can then import your videos! Right now, this is hard-coded to only import videos from Classy's user account (see the `youtube_channel_id` in the `import_youtube_videos` method). You can manually change the channel_id to your accounts channel_id as needed. 

Make sure you create a playlist called "All videos" and put your videos in that. youtube's API is funky, and you don't seem to get consistent results unless you ask for videos *within a playlist* (no idea why).

Then, just run this code to import the videos:

```
rails console
importer = Importer.new(User.first) # or whatever user you'd like
importer.import_events # if you need to import Ultianalytics events
importer.import_youtube_videos
```

This will create a bunch of Video objects. You can then find the videos on the "Video archive" section of the app, and manually sync each one by watching the play, and then searching for that play in the stream of events from UltiAnalytics (just use the app, it should be pretty self-explanatory).

You're done!


#### If you want to preserve the timestamps from video files

This method is not recommended right now, because the timestamp data doesn't seem to be very consisten in my experience anyways. Also, it's much more of a hassle, and involves using both Google Photos and Google Drive.

Ok, so uploading directly to youtube loses the timestamp data. So instead, use [Google Photos](https://photos.google.com) with your Google account, and upload the videos through there. Then, turn on the Google Photos + Google Drive integration (follow instructions [here](https://support.google.com/photos/answer/6156103?hl=en) under "Organize photos & videos using Google Drive"). 

Then, we can use the Google Drive API to pull in file data (including timestamps) about your videos! To do that, run this code from the `lib/importer.rb` class:

```
rails console
importer = Importer.new(User.first) # or whatever user you'd like
importer.import_events # if you need to import Ultianalytics events
importer.import_videos_from_google_drive
```

This should create a whole bunch of videos in the database. It will also automatically try to sync up each video with any Event object from the same time period. 

The app will then let you stream videos directly from Google Drive. However, streaming from Drive kind of sucks. It has bandwidth limits, and you can't change the video quality (important for low-bandwidth streaming and large files). 

So then what you can do is: Head to youtube.com, and "Upload" some videos, and click the button along the lines of "Import videos from Google Photos". Once you import all the videos from Google Photos over to youtube, add those videos to a playlist called "All videos". Make sure that each file you import keeps the same file name! The name of the file is the only way we can tell which video in Google Drive corresponds to which video on youtube. It's not great, I know (part of the reason I don't do this anymore). 

Once youtube has imported your videos, you can import the youtube video ids into your existing Videos with this (assuming you still have that console open):

```
importer.import_youtube_video_ids
```

And then you'll be able to stream the videos through youtube instead of Drive! Yay! However, your timestamps probably won't be perfect, and will need to be tweaked anyways, which is why you should really just upload directly to youtube and manually sync each video. It's really not that hard.


### License

This project is licensed under the [MIT License](LICENSE.txt).

### Contributing

Contributors welcome! "Watch" this repo to keep an eye on new Issues as they pop up, and I definitely hope that more coders from the Ultimate community help make this a super-bomb and usable app.

I would suggest starting with a Github Issue to talk about what you want to add or help out with, or commenting on an existing one you want to work on, before you make a Pull Request.
