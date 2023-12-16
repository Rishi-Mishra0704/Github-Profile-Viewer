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
    puts "Created at: #{format_date(user_data['created_at'])}"
  end
  def format_date(date_string)
    date_time = DateTime.parse(date_string)

    date_time.strftime("%d-%m-%Y")
  end
end

puts "Please Enter Your GitHub Username:"
username = gets.chomp


if username.empty?
  puts "Username cannot be empty. Exiting."
  exit 1
end

viewer = GitHubProfileViewer.new(username)
viewer.fetch_profile