# Theses scripts are making some assumptions about your environment.

- plugins **need** to be in `./tmp`
- bin/mass_effect don't run under jruby, I am slowly migrating it to jruby.

# Commands that I usually do.

## Fetch all the plugins

```
bin/mass_effect clone_all --target tmp
```

## Remove empty github directories

Theses directory are waiting for the initial commit and will make the others scripts fails

```
ruby scripts/delete_empty_plugins.rb
```

## Update dependencies and minor bump

Edit this scripts make the appropriate changes

```
ruby scripts/logstash-core-plugin-api-1.0.rb
```

## Update changelog

Edit scripts to the correct message it will go through all the plugins read the current
version in the gemspec and update the changelog.

```
ruby scripts/changelog_api.rb
```

## Commit & Pushes your changes

I usually do a PR with one of the plugin to get review and then pushes all the changes when the changes are approved.

```
bin/mass_effect run_all "git add .; git commit -am 'dependency logstash-core > 2.0.0 < 6.0.0.alpha1'" --target tmp
bin/mass_effect run_all "git push origin master" --target tmp
```


## Mass publishing

This script need more baby care and it still a shell scripts, I usually push all the changes to jenkins and monitor the build to see if
anything is obviously failing.

**Make sure you are under JRUBY and start a TMUX session**

```
sh scripts/publish_all_file > logs/20162101_14h00.log
```

Let it run, read the logs check for 1, which mean the shell script returned an error
