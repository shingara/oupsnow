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

## Member of project

In each project, you can choose all member.

### Add member

You can add several members to your project. A member add to this project, can 
create and update all tickets. All functions are define by global administration.
There are only 2 differents roles. An admin role and a basic role. An admin can change
all settings of this projects and create/update milestone.

### Change function to members

in list of member, you can change all functions to members. If you change the select
and click on update all, all members are updated. The limitation is only to have
just one admin in each project. If you change all member's function to have no admin
the changement is rollback.

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

