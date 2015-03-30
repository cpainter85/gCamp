class TrackerAPI
  def initialize
    @conn = Faraday.new(:url => 'https://www.pivotaltracker.com')
  end

  def projects(token)
    response = @conn.get do |request|
      request.url '/services/v5/projects'
      request.headers['Content-Type'] = 'application/json'
      request.headers['X-TrackerToken'] = token
    end
    JSON.parse(response.body, symbolize_names: true)
  end
end
