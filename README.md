#Synopsis

Ruby gem for using APIs, based on their Geekier API descriptions.

#Installation

##Gemfile

`gem "geekier_factory"`

##Standalone

`gem install geekier_factory`

#Usage

Download the API definition you want to use.

    require 'geekier_factory'
    
    # instanciate the api
    api = GeekierFactory.factorize('path/to/definition_file.json')
    
    # get a list of actions you can perform
    api.available_actions
    
    # select the action you want to perform
    action = api.available_actions[3]
    
    # check out what parameters are possible/necessary
    action.params
    
    # select an action and call it with its parameters
    action.call(:param1 => 'valueA', :param2 => 'valueB)

And that's how you do it.

#Participate

* fork && commit && send\_pull\_request
* add [more API definitions](https://github.com/geekier/geekier)
* join the [Geekier Google group](https://groups.google.com/d/forum/geekier-apis)

#TODO

(in no particular order)

* Implement support for resources
* Parameter validations
* Support for Authentication/API level configuration 
* Add more descriptions
* Setup with all the cool testing and dependency checking solutions out there