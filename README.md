# book-runner

A motley collection of scripts for creating and running a
[@SortingSong](https://twitter.com/SortingSong)-style Twitter bot,
where the characters of a text are replaced with Twitter usernames (or
anything really) as the text is tweeted out incrementally.

## requirements

- any version of [Node](https://nodejs.org) that supports string
  interpolation (probably version 3 or higher)

- GNU sed; `brew install gnu-sed` on macOS

- a Twitter account with an [application](https://apps.twitter.com/)
  that has read-write permissions and OAuth access tokens.

## step 1: get a book

[Project Gutenberg](https://www.gutenberg.org/) is a great source for
public-domain texts.  If you want to use something still under
copyright, you’re on your own.  (My sort-of informed guess is that
it’s probably fair use to run this with copyrighted texts, but don’t
blame me if you get sued.)

Get the book in plain text (i.e., `.txt`, no RDF or Word or fuckin’
LaTeX).

## step 2: replace the names (or whatever) with variables

I haven’t tried automating this step because there’s human judgement
involved.  For @SortingSong I decided that I would replace the names
of some non-persons (the Sorting Hat, the Fat Lady) but not others
(the Forbidden Forest).

Whatever names, entities, etc. that you want to replace; swap them out
for properties of the `cast` object.  In other words, the first
sentence of Mansfield Park would look like this:

```
About thirty years ago Miss cast.mrsbetram___, of Huntingdon, with
only seven thousand pounds, had the good luck to captivate Sir
cast.thomasbetram, of Mansfield Park, in the county of Northampton,
and to be thereby raised to the rank of a baronet's lady, with all the
comforts and consequences of an handsome house and large income.
```

I added three underscores to the end of ’mrsbetram’ so that the number
of characters in the variable, `cast.mrsbetram___`, would be 17—the
maximum number of characters in a Twitter username (including the
`@`).  That will make it easier to see when a string is at risk of
running over the 140-character tweet length.

## step 3: break up the text into tweet-sized bites

This is the longest and most tedious part.  You could probably write a
script to break up the text into 140-character segments, but some of
the resulting tweets would surely be worse than if you manually choose
where to add a break.

You add a break by creating a line with only asterisks in it:

```
I am some text that will be in a tweet.

****

I will be in a different tweet.
```

When you run the storyteller with `bin/run`, the current line will be
tweeted, then the program exits.  If you want to send several lines in
a batch, include them on separate lines without the asterisks
separating them.

```
I am some text that will be in a tweet.

****

I will be in a different tweet.

I will also be my own tweet, but sent in the same batch.
```

By default each tweet in a batch is sent 10 seconds after the last.
You can adjust this by changing the `TWEET_PAUSE` constant in
`lib/storyteller.js`.

## step 4: build the text into a machine-readable set of files

Once you’ve prepared your text, run `bin/build` to convert it into a
set of JavaScript files that are used by `bin/run`:

```
bin/build <path/to/text.txt> <path/to/output/directory>
```

The `text.txt` is your prepared test, and the output directory is
preferably empty.

This should create three files in the output directory:

- `text.js`: This contains the prepared text, with the tweet-sized
  chunks represented as elements of a JavaScript array.

- `cast.js`: This is where the `cast` object (mentioned above) is
  defined.  All the values of its members will be empty; it’s your job
  to fill them with the values you want to replace your variables.

- `freq.csv` This is a CSV file showing how many appearances each
  variable has in the text; it might come in handy for figuring out
  how many mentions each character will have.

## step 5: cast the roles

This is the fun part; see which of your friends want to take part, and
add their names to the appropriate line of `cast.js`.  Obviously,
don’t include them without asking first.

## step 6: flight checks

Once you’ve filled out your `cast.js` MadLibs, there are a few ways to
make sure everything is good to go before flipping the switch on your
bot.

- `bin/length <path/to/text.js>` can tell you if any of your lines are
  longer than 140 characters.

- `bin/line <path/to/text.js> <number>` will show you what the
  tweet(s) at a given line will look like.

- `bin/run --dry=true <path/to/text.js>` will simulate the behavior of
  your bot, without actually tweeting.

## step 7: go go goooo

If you haven’t yet, install the project dependencies with `npm i`.

Now all that’s left is to make sure your Twitter app’s information is
in `config/secrets.js`, and turn on your bot!  I usually set a cron
job to run `bin/run` every 15 minutes:

```cron
*/15 * * * * bin/run path/to/text.js >> /var/log/bork.log 2>&1
```
