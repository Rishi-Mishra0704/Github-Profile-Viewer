require "httparty"

class GitHubProfileViewer
  include HTTParty
  base_uri "https://api.github.com"

  def initialize(username)
    @username = username
  end

  def fetch_profile
    response = self.class.get("/users/#{@username}")
    parse_response(response)
  end

  private

  def parse_response(response)
    if response.success?
      user_data = JSON.parse(response.body)
      display_profile(user_data)
    else
      puts "Error fetching GitHub profile: #{response.code} - #{response.message}"
    end
  end

  def display_profile(user_data)
    puts "GitHub Profile for #{@username}"
    puts "Name: #{user_data['name'] || 'Not provided'}"
    puts "Bio: #{user_data['bio'] || 'Not provided'}"
    puts "Location: #{user_data['location'] || 'Not provided'}"
    puts "Public Repositories: #{user_data['public_repos']}"
    puts "Followers: #{user_data['followers']}"
    puts "Following: #{user_data['following']}"
    puts "Created at: #{user_data['created_at']}"
  end
end

# Accept GitHub username from the command line
username = ARGV[0]

# Check if the username is provided
if username.nil?
  puts "Usage: ruby github_profile_viewer.rb <github_username>"
  exit 1
end

# Create GitHubProfileViewer instance and fetch the profile
viewer = GitHubProfileViewer.new(username)
viewer.fetch_profile
