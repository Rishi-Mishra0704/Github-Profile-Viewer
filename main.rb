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

   def fetch_profile_and_repositories
    fetch_profile
    fetch_repositories
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
  def fetch_repositories
    response = self.class.get("/users/#{@username}/repos")
    parse_repositories(response)
  end
  
  private
  
  def parse_repositories(response)
    if response.success?
      repositories = JSON.parse(response.body)
      display_repositories(repositories)
    else
      puts "Error fetching repositories: #{response.code} - #{response.message}"
    end
  end
  

  def display_repositories(repositories)
    puts "Latest 3 Repositories for #{@username}:"
  
    languages_to_display = ['python', 'typescript', 'ipynb', 'ruby', 'javascript', 'c++']
  
    languages_to_display.each do |language|
      puts "----- #{language.capitalize} -----"
      
      # Filter repositories by language
      language_repositories = repositories.select { |repo| repo['language'].to_s.downcase == language }
  
      # Sort repositories by created_at in descending order
      sorted_repositories = language_repositories.sort_by { |repo| DateTime.parse(repo['created_at']) }.reverse
  
      # Display latest 3 repositories or all if less than 3
      latest_3_repositories = sorted_repositories.take(3)
  
      if latest_3_repositories.empty?
        puts "No repositories for #{language.capitalize}"
      else
        latest_3_repositories.each do |repo|
          puts "Name: #{repo['name']}"
          puts "Description: #{repo['description'] || 'Not provided'}"
          puts "Created at: #{format_date(repo['created_at'])}"
          puts "--------------------------"
        end
      end
    end
  end
  

end

puts "Please Enter Your GitHub Username:"
username = gets.chomp


if username.empty?
  puts "Username cannot be empty. Exiting."
  exit 1
end

viewer = GitHubProfileViewer.new(username)
viewer.fetch_profile_and_repositories