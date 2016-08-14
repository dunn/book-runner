//
'use strict';
const Twit = require('twit');
const secrets = require('./secret.js');
const T = new Twit(secrets.twitter);

const async = require('async');
const fs = require('fs');

const log = {
  err: function (message) {
    const t = new Date();
    console.log('[ERROR] ' + t + ': ' + message);
  },
  info: function (message) {
    const t = new Date();
    console.log(t + ': ' + message);
  }};

module.exports = function(book, mode) {
  let line;
  try {
    line = parseInt(fs.readFileSync(`${__dirname}/status_${book}`));
  } catch (e) {
    line = 0;
    fs.writeFile(`${__dirname}/status_${book}`, '0', (err) => {
      if (err)
        return err;
      return log.info(`Created ${__dirname}/status_${book}`);
    });
  }

  const text = require(`${__dirname}/book${book}/text.js`);
  if ( !text[line] )
    return log.info('End of text!');

  // A given 'line' might be a series, since we want to at least
  // finish a complete sentence per tweet session.
  const batch = text[line];

  console.log(batch);

  let n = 0;
  async.until(
    function(){ return n === batch.length; },
    function(callback){
      const post = { status: batch[n] };
      n++;
      if (mode !== 'dry'){
        T.post('statuses/update',post, function(err, _data, _response) {
          // ignore duplicate tweet errors
          if(err && err.code !== 187) {
            console.error('Error posting: ' + post.status +
                          ' (' + post.status.length + ' characters)');
            return callback(err);
          }
          console.log(`line ${line}: ${text[line]}`);
          return setTimeout(callback,10000);
        });
      }
      else {
        console.log(post);
        return setTimeout(callback,10000);
      }
    },
    function(err){
      if (err)
        return console.error(err);

      const updateLine = line + 1;
      fs.writeFile(`${__dirname}/status_${book}`, updateLine, (err) => {
        if (err)
          return err;
        return log.info(`${__dirname}/status_${book}: ${updateLine}`);
      });
    }
  );
};
