require 'pivotal-tracker'

SCHEDULER.every '30m', first_in: 0 do |job|
  api_token = '' # <-- Your PivotalTracker API token goes here
  full_name = '' # <-- Your name as it appears in PivotalTracker

  PivotalTracker::Client.token = api_token

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
