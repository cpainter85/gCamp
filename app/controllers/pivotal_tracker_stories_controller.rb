class PivotalTrackerStoriesController < PrivateController
  def show
    tracker_api = TrackerAPI.new
    @tracker_project = params[:format]
    @tracker_stories = tracker_api.stories(current_user.pivotal_tracker_token, params[:id])
  end
end
