require 'rest_client'
require 'json'

class Agilezen
  PROJECTS_URL = 'https://agilezen.com/api/v1/projects/'

  def initialize(project_id, api_key)
    @api_key = api_key
    @project_id = project_id
  end

  def overflows
    {overflows: overflows_items}
  end

  def overflows_items
    phases_items.map do |p|
      coerce_id(p) if !p['limit'].nil? && phase_overflow?(p['id'], p['limit'])
    end.compact
  end

  def phases_items
    @phases_items ||= JSON.parse(RestClient.get(phases_url))['items']
  end

  def phases_url
    "#{PROJECTS_URL}#{@project_id}/phases.json?apikey=#{@api_key}"
  end

  def phase_overflow?(phase_id, limit)
    return false if limit == 0
    phase_stories(phase_id)['totalItems'] > limit
  end

  def phase_stories(phase_id)
    @phase_stories ||= {}
    @phase_stories[phase_id] ||= JSON.parse(RestClient.get(stories_url(phase_id)))
  end

  def stories_url(phase_id)
    "#{PROJECTS_URL}#{@project_id}/stories.json?apikey=#{@api_key}&where=phase:#{phase_id}"
  end

  def coerce_id(phase) # a little hack to deal with zapier deduplication https://zapier.com/developer/documentation/reference/#deduplication
    phase.dup.tap { |p| p['id'] = "#{last_story_id(p['id'])}#{p['id']}".to_i }
  end

  def last_story_id(phase_id)
    phase_stories(phase_id)['items'].last['id']
  end

  class << self
    def overflows(project_id, api_key)
      Agilezen.new(project_id, api_key).overflows
    end
  end
end
