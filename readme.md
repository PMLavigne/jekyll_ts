Jekyll plugin to compile Typescript
====

## Setup

1. Add *jekyll_ts.rb* to `_plugins` folder
2. Add plugin configs to your `_config.yml` file (see [Configuration Options](#configuration-options), below)
3. Javascript files will write to `js_dest` location on build

## Configuration Options

The following options can be specified in your `_config.yml`:

#### `tsc`
*Default: `tsc`*

Command to use as the typescript compiler. The default is usually enough if you can run "tsc" on the command line already.

#### `js_dest`
*Default: `/`*

Location to write compiled .js files to. Relative to your site output directory (usually `_site`)

#### `environment`
*Default: `production`*

Build environment to use. Per Jekyll's specs, this can be set to `production` or `development`. If unset, we default to
assuming it is `production` for backwards-compatibility. 

You can also specify this value in the environment variable `JEKYLL_ENV`, which will override the value in the config.

#### `tsc_opts`
*Default: `-t ES5`*

Arguments to be passed to the `tsc` command in addition to the file to process and the `--out` destination. Arguments
here will always be used regardless of the `environment`.

#### `tsc_dev_opts`
*Default: unset*

Arguments to be passed to the `tsc` command only when the `environment` is set to `development`. They will be appended
to any arguments in `tsc_opts`

#### `tsc_prod_opts`
*Default: unset*

Arguments to be passed to the `tsc` command only when the `environment` is set to `production`. They will be appended
to any arguments in `tsc_opts`

## Original Author
[Matt Sheehan](https://github.com/sheehamj13)

## Contributors
* [Patrick Lavigne](https://github.com/PMLavigne)
