# 0.0.6alpha - July 27, 2012
### Major Changes
* Added new RequireJS path verification ([see documentation](https://github.com/dbashford/mimosa#requirejs-support))

### Minor Changes
* Moved the require code around a bit in the Mimosa code base
* slightly altered the require code surrounding the client template libraries

### Breaking Changes
The `require` config has been broken up. What was previously directly under `require` is now under `require.optimize`.  A new `verify` option lives under the `require` config.

If you have not overridden any `require` configuration, then you are fine.  However, for future reference, it is suggested that you copy the new [mimosa-config.coffee](https://github.com/dbashford/mimosa/blob/master/lib/skeleton/mimosa-config.coffee) `require` block over top of yours.

If you have overridden the `require` configuration, then you'll want to adjust your current `require` object to be inside the `optimize` object, and you'll want to add the new `verify` option as it exists in the [mimosa-config.coffee](https://github.com/dbashford/mimosa/blob/master/lib/skeleton/mimosa-config.coffee).
