# Several roles

## Global Admin

A global admin is like big brother. He can access to Oupsnow's administration
panel. He also has all the rights of a Project admin.

## Project admin

A project admin is a user with admin powers on a particular project. He can view
and change the settings of the project. He also has all the rights of a basic
user.

## User

An user can only browse projects, create tickets or update them.

## Anonymous

An anonymous user is an unregistered user. He can see all information about
projects and tickets but can't update them.

# Project settings

## Delete project

Since Oupsnow-0.4.0, you can delete a project. If you delete a project all
information about this project is deleted too.
Project information include:

* Tickets
* Ticket updates
* Members
* Events (timeline)
* Milestones

There is no way to revert the deletion of a project.

Only a global admin can delete projects, simple users or project admins can't.

# Ticket searching

Project by project, you can list all tickets on this project. To see all tickets 
you can go to "Tickets" tab. On this page, all tickets are see by default. A 
pagination is active. So you can see only 20 tickets per page. It's order by default 
with last ticket created in first.

## Ordering

You can order the Ticket list by 2 parameters :
* Id (the ticket id)
* Name (the ticket title)

## Searching

You can limit the number of ticket view with the ticket searching. If you want find 
some ticket by restriction, you can. All filter describe after can be use in same 
search. All are combinate. The possibility of search is :

### Searching by ticket name

If you want search a ticket by this name or with some information on is description, 
you can just fill some word. If you separate by space several word. All words are 
needed in ticket title or description. The search is not made in ticket comment. It's
just on ticket title and description

### Searching by tag

All tickets in Oupsnow can have some tag. You can filtering by this tag. If you want 
search the tag "feature" by example you need fill search by :

 * "tagged:feature"

If you want filtering by several tickets, you need add several tagged:xxx pattern. By 
example if you want search all ticket with tag "feature" and "admin", you can fill by

 * "tagged:feature tagged:admin"

### Searching by state

A ticket need a state. You can't create some ticket without a state. So you can filtering
by this state. If you want filtering use, the fill by :

 * "state:new"

IN case of state, a ticket can't be have several state. So if you fill by several state 
statement, only the last is use in filtering. By example :

 * "state:new state:assigned" return only ticket with state assigned

