h1. Oupsnow

A Bug tracker multi project, simply, but completed like bug tracking.

It's written in Merb

h2. Features

 * Manage Several project
 * Manage ticket project by project

h2. Requirements

Currently you need all of those things to get Oupsnow to run:

 * Merb 1.0.8
 * DataMapper 0.9.9
 * Ruby of 1.8.6 or greater
 * A database supported by DataMapper (MySQL, SQLite3, PostgreSQL ...)

h2. Installing

With the tar.gz or any other archive:

 * Extract sources to a folder
 * Create a database.yml file in the config directory. Generate by example by <kbd>rake db:database_yaml</kbd>. 
 * Create your database with tool on your database
 * Generate the good schema in your database: <kbd>MERB_ENV="production" rake db:automigrate</kbd>
 * Add first data in your database: <kbd>MERB_ENV="production" thor oups_now:bootstrap:first_value </kbd>
 * Start the server in production mode : <kbd>merb -e production</kbd>

h2. Demo Website

A demo website of Oupsnow is available to the "demo of oupsnow":http://oupsnow.shingara.fr

An account of admin is accessible with login/pass : admin/oupsnow

h2. Information about this project

Oupsnow is actually consider like an Beta version, and is under development.

All contributions are welcome. 

I suck in design, I know it and I am sorry but I will really be happy if anyone could
help me.

If you want to contribute, all work is made under a git repository. You can clone the 
source with the following command :

<kbd>git clone git://github.com/shingara/oupsnow.git</kbd>

After a clone you need update the submodule :

<kbd>git submodule init && git submodule update</kbd>

A "redmine development platform":http://dev.shingara.fr/projects/show/oupsnow is
used. Feel free to post your feature requests and defects report. I use
Oupsnow soon as possible after create a converter Redmine -> Oupsnow

h2. License

This code is free to use under the terms of the MIT license (provided with sources).
