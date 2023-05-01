# README

## Introduction
Stage clear videos aggerator for Arknights
## Dependencies
- Ruby 3.1.3
- Rails 7.0.4.3
- Postgresql 14.6
## Setup
- Run `bundle`
- Run `bin/rails db:setup`
## Development
- Start up vite server `bin/vite dev`
- Start up rails service `bin/rails s`
- Or 2-in-1 command `bin/dev`
### Hotwire
- New stimulus controllers created in `app/javascript/controllers` and `app/components` are auto-registered, controller name will be `path__to__folder__file-name`
### ViewComponent
- Use `bin/rails g component X` to create a component and associated files, see [here](https://viewcomponent.org/guide/generators.html) for more details
## Testing
- Run `bin/rspec path/to/test/files/or/folder`

