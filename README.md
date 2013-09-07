Dashing Pivotal Tracker Widget
=
Description
-

A [Dashing](http://shopify.github.com/dashing) widget to display your unstarted, started, and finished stories on [Pivotal Tracker](http://www.pivotaltracker.com) using the Ruby [Pivotal Tracker gem](https://github.com/jsmestad/pivotal-tracker).

Preview
-
![Screen Shot](http://i.imgur.com/FRDsQo1.png)

Useage
-
To use this widget, copy `pivotal.coffee`, `pivotal.html`, and `pivotal.scss` into the `/widgets/pivotal` directory of your Dashing app.  This directory does not exist in new Dashing apps, so you may have to create it.  Copy the `pivotal.rb` file into your `/jobs` folder, and include the Pivotal Tracker gem in your `Gemfile`.  Edit the `pivotal.rb` file to include your Pivotal Tracker username, password, and full name as it appears on Pivotal Tracker.

To include the widget in a dashboard, add the following to your dashboard layout file:

#####dashboards/sample.erb

```HTML+ERB
...
  <li data-row="1" data-col="1" data-sizex="1" data-sizey="2">
    <div data-id="pivotal" data-view="Pivotal" data-title="Pivotal Tracker"></div>
  </li>
...
```

Requirements
-
* [Pivotal Tracker](http://www.pivotaltracker.com) account
* The Ruby [Pivotal Tracker gem](https://github.com/jsmestad/pivotal-tracker)

Code
-
#####widgets/pivotal/pivotal.coffee

```coffee

class Dashing.Pivotal extends Dashing.Widget

  ready: ->

  onData: (data) ->
```

#####widgets/pivotal/pivotal.html

```HTML
<h1 class="title" data-bind="title"></h1>
<table class="table">
  <th>Unstarted</th>
  <tr data-class="pivotal" data-foreach-story="unstarted">
    <td data-bind="story | raw"></td>
  </tr>
</table>

<table>
  <th>Started</th>
  <tr data-class="pivotal" data-foreach-story="started">
    <td data-bind="story | raw"></td>
  </tr>
</table>

<table>
  <th>Finished</th>
  <tr data-class="pivotal" data-foreach-story="finished">
    <td data-bind="story | raw"></td>
  </tr>
</table>

<p class="more-info">Powered by PivotalLabs</p>
<p class="updated-at" data-bind="updatedAtMessage"></p>
```

#####widgets/pivotal/pivotal.scss

```SCSS
$background-color:  #9c4274;
$full-color:  rgba(255, 255, 255, 1);
$light-color: rgba(255, 255, 255, 0.4);

.widget-pivotal {
  background-color: $background-color;
  .title {
    color: $light-color;
  }
  table {
    margin: 30px 0px;
    tr {
      &:nth-child(even) {
        background-color: $light-color;
      }
    }
  }
  .updated-at {
    color: rgba(0, 0, 0, 0.3);
  }
}
```

#####jobs/pivotal.rb

```rb
require 'pivotal-tracker'

SCHEDULER.every '30m', first_in: 0 do |job|
  username  = '' # <-- Your PivotalTracker username goes here
  password  = '' # <-- Your PivotalTracker password goes here
  full_name = '' # <-- Your name as it appears in PivotalTracker

  PivotalTracker::Client.token(username, password)

  statuses = [:unstarted, :started, :finished]
  stories  = Hash.new { |hash, key| hash[key] = [] }
  projects = PivotalTracker::Project.all

  projects.each do |project|
    statuses.each do |status|
      my_stories = project.stories.all(owner: full_name, state: status.to_s)
      stories[status] << my_stories.map{ |story| story.name[0..20] + '...' }
      stories[status].flatten!
    end
  end

  send_event('pivotal', stories )
end
```
