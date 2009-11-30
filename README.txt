h1. Oupsnow

A Bug tracker multi project, simply, but completed like bug tracking.

It's written in Merb

h2. Features

 * Manage Several project
 * Manage ticket project by project

h2. Requirements

Currently you need all of those things to get Oupsnow to run:

 * Ruby of 1.8.6 or greater
 * Rails 2.3.5
 * MongoMapper 0.6.4
 * A MongoDB 1.0.1 or greater

h2. Installing

With the tar.gz or any other archive:

 * Extract sources to a folder
 * Create a database.yml file in the config directory. You can copy database file from config/database.yml.sample
 * Add first data in your database: <kbd>RAILS_ENV="production" rake db:seed</kbd>
 * Start the server in production mode : <kbd>ruby script/server -e production</kbd>

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

A "oupsnow development platform":http://dev.shingara.fr/projects/5/overview is
used. Feel free to post your feature requests and defects report.

h2. Upgrading

All version before 0.4.0 of oupsnow use a Sql database. Now with using MongoDB, the schema has big changement. There are no currently tool to convert your old oupsnow instance.

h2. License

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.fsf.org/licensing/licenses/agpl-3.0.html>.

