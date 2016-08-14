'use strict';
const cast = {
  mrsbetram___: '',
  thomasbetram: '',
};

if (!!process.env.DECONSTRUCT) {
  for (let k in cast)
    cast[k] = `cast.${k}`;
}
module.exports = cast;
