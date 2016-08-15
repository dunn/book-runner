// Copyright 2016 Alex Dunn <dunn.alex@gmail.com>
//
// This file is part of read-thing.
//
// read-thing is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
//
// read-thing is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with read-thing.  If not, see <http://www.gnu.org/licenses/>.

'use strict';

const fs = require('fs');
const async = require('async');
const Twit = require('twit');

// The number of milliseconds between each tweet in a batch
const TWEET_PAUSE = 10000;

const log = {
  err: function (message) {
    const t = new Date();
    console.error('[ERROR] ' + t + ': ' + message);
  },
  info: function (message) {
    const t = new Date();
    console.error(t + ': ' + message);
  }};

module.exports = function(options) {
  const secrets = require('../config/secrets.js');
  const T = options.dryRun ? '' : new Twit(secrets.twitter);

  let line;
  try {
    line = parseInt(fs.readFileSync(options.dbfile));
  } catch (e) {
    line = 0;
    fs.writeFile(options.dbfile, '0', (err) => {
      if (err)
        return err;
      return log.info(`Created ${options.dbfile}`);
    });
  }

  const text = require(`${options.book}/text.js`);
  if ( !text[line] )
    return log.info('End of text!');

  // A given 'line' might be a series, since we want to at least
  // finish a complete sentence per tweet session.
  const batch = text[line];

  // console.log(batch);

  let n = 0;
  async.until(
    function(){ return n === batch.length; },
    function(callback){
      const post = { status: batch[n] };
      n++;
      if (!options.dryRun){
        T.post('statuses/update',post, function(err, _data, _response) {
          // ignore duplicate tweet errors
          if(err && err.code !== 187) {
            console.error('Error posting: ' + post.status +
                          ' (' + post.status.length + ' characters)');
            return callback(err);
          }
          console.log(`line ${line}: ${text[line]}`);
          return setTimeout(callback, TWEET_PAUSE);
        });
      }
      else {
        console.log(post);
        return setTimeout(callback, TWEET_PAUSE);
      }
    },
    function(err){
      if (err)
        return console.error(err);

      const updateLine = line + 1;
      fs.writeFile(`${options.dbfile}`, updateLine, (err) => {
        if (err)
          return err;
        return log.info(`${options.dbfile}: ${updateLine}`);
      });
    }
  );
};
