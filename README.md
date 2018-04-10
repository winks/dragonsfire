# dragonsfire

A shitty version of [dragonfly](https://github.com/markevans/dragonfly), but for [crystal](http://crystal-lang.org)

Currently supported data stores:

  * File
  * (S3)

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  dragonsfire:
    github: winks/dragonsfire
```

## Usage

```crystal
require "dragonsfire"

# save to file
df = Dragonsfire::Dragonsfire.new

# from string
o1 = Dragonsfire::Content.new
o1.name = "test1.txt"
o1.set "wheee1"
saved = df.store o1
puts o1.to_s

# fetch from url
o2 = df.fetch_url "http://example.org/example.jpg"
puts o2.to_s

# save to s3 (minio)
df2 = Dragonsfire::Dragonsfire.new(:s3)
puts df2.to_s

df2.datastore.configure :bucket_name, "my_bucket"
df2.datastore.configure :endpoint, "http://127.0.0.1:9000"
df2.datastore.configure :access_key_id, "something"
df2.datastore.configure :secret_access_key, "very_secret"
df2.datastore.init

o3 = Dragonsfire::Content.new "test2.txt"
o3.set "wheee2"
saved = df2.store o3
puts o3.to_s

```

## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/winks/dragonsfire/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[winks]](https://github.com/winks) @winks - creator, maintainer

## Why the name?

Misheard lyrics.
```
Dreams of war
Dreams of liars
Dreams of dragonflies
```
