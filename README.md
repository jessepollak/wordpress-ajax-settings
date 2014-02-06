Ajax Settings for WordPress plugins
===================================

This library allows you to make your plugin's settings page work entirely over AJAX if you use the WordPress Settings API and follow standard protocols.

# Installation

1. Download the `dist`, rename it 'ajax-settings', and place it in your project tree.
2. Include the `ajax-settings.php` file and initialize appropriately

```php

add_action('admin_init', 'initialize_ajax_settings');
function initialize_ajax_settings() {
  require_once(PATH_TO_ajax_settings.php);
  new AjaxSettings(array(
    "options_name" => YOUR_SETTINGS_API_OPTION_NAME,
    "base_url" => URL_TO_THE_ajax-settings_FOLDER
}
```

### Constructor options

* `options_name` (string) - the name of your Settings API option name  
* `base_url` (string) - the URL to the base folder for this library. TODO: make this unecessary ([tweet](http://twitter.com/jessepollak) at me if you know how)  
* `initialize` (boolean) - whether you want the client side javascript that handles the settings page to be initialized. Set this to false if you want to inherit from these objects and add in additional functionality.

# Development

```bash
$ git clone git@github.com:jessepollak/wordpress-ajax-settings.git
$ cd ajax-settings
$ npm install
$ grunt && grunt watch
```



