#Game footage + UltiAnalytics = ?!?!

This app was built to help you capture every moment of every game, and then give you the ability to actually go find those moments in the footage. Having lots of footage is really great, until you have to comb through hours to figure out when everything happened. If you use the [UltiAnalytics](http://ultianalytics.com) app to track each game, then we can sync that data into the app and line it up with your videos. Bam.

### A note on timestamps
The original intention was to use the timestamps from video files in order to automatically sync up the video to the timestamps from UltiAnalytics. However, this doesn't seem to work too well (clocks can be off), and so I ended up manually syncing each video anyways. Because of that, I think that this app will be much easier to maintain and use in the long run if all videos are just manually synced (it only takes about 30 seconds per video to do it, so just take long videos).


### How it works
First, we import all of the "event" data from UltiAnalytics using their API. (Ideally, this would be configurable on a per-user basis, it's hard-coded right now.) This creates a bunch of `Event` objects in our database with timestamps and titles (which are just strings that describe the event, like someone catching a goal).

Then, the user simply uploads their videos onto YouTube, then adds them to a playlist. We bulk-import the videos of that playlist, and save them as `Video`s on our end. Then, the user hops into the app, and manually syncs up each video's timestamps (`starts_at` and `ends_at`) with the `Event` data (you only need to sync a single event for each video, because if you have the time correct on that, the rest will also be correct).



## Requirements

- Ruby 2.1.6
- Rails 4.2.4
- Bundler

### Setup

```
git clone https://github.com/kyletns/classy-highlights.git
cd classy-highlights
bundle install
```



Since the app only uses Google Oauth, you'll need to 

Clone and bundle, then create a file called `.env` which looks like this:

```
OMNIAUTH_PROVIDER_KEY=xxxxx
OMNIAUTH_PROVIDER_SECRET=xxxxx
GOOGLE_API_KEY=xxxxx
```

The live values for these keys on the server come from the [Google API Console](https://console.developers.google.com/apis/credentials?project=classy-highlights-1322&authuser=2), just log in as ClassyFootage on Google and you can find the credentials there. Omniauth is our "Server Key" and the Google API Key is our "OAuth Key".

Once you have those working, you'll want to:

```
rake db:create
rake db:migrate
```

Then run the server with `rails server`, and head to `localhost:3000` to see it! You should be able to log in using Google Oauth, which will create a User in your database. You're up and running!

## Where is all the data coming from?

Ok, so it's kind of crazy. My apologies. But it works, and it's free :D

### Huh?

First, we import event data directly from Ultianalytics. We save a copy of everything into our Event model, where the `kind` column can be one of `["Game", "Point", "Play"]`. We get timestamps for each one, which go into the `starts_at` and `ends_at` columns (plays don't have end times, though, they just happen at a specific moment).

Then, we make sure our videos are all uploaded to Google Photos under the `classyfootage@gmail.com` account. We can then access them through the Google Drive API. We import the video metadata, including the name of the file (`title`) and also the start time / end time (`starts_at` & `ends_at`).

THEN, we head to Youtube.com (still logged in as `classyfootage@gmail.com`), and go to "Upload". From there, it's easy to import all of our Google Photos videos into Youtube videos. When importing, make sure you preserve the name of the file! Don't rename the Youtube videos, because the name is our best way to match up the files between Drive and Youtube. 

Once the videos are all imported, we just have to add them all to the "All videos" playlist on Youtube. Then, we can use the Youtube API to grab all of those videos, figure out which video is which, and save a `video_id` for each one. This is the best of all worlds. Google Drive gives us the timestamps, and Youtube gives us a great HTML5 video player we can embed anywhere and use infinitely for free.



## Ok let's actually import the datas!

(0) Boot up a console and use the `lib/importer.rb` class:

```
rails console
importer = Importer.new(User.first) # or whatever user you'd like
```

(1) Ultianalytics: `importer.import_events`

(2) Videos stored in Google Drive: `importer.import_videos_from_google_drive`

(3) Youtube video IDs for youtube playback: `importer.import_youtube_video_ids`
