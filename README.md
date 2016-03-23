# Theses scripts are making some assumptions about your environment.

- plugins **need** to be in `./tmp`
- bin/mass_effect don't run under jruby, I am slowly migrating it to jruby.
- All the others scripts in `scripts/` **requires jruby**

## Fetch all the plugins

```
bin/mass_effect clone_all --target tmp
```


## Remove empty github directories
Theses directory are waiting for the initial commit and will make the others scripts fails

