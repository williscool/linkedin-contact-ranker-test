require "csv"

namespace :contact_ranker do
  desc "Rank your contacts"
  
  task generate_csvs: :environment do

    if ENV["LINKEDIN_API_KEY"].blank? or ENV["LINKEDIN_API_SECRET"].blank?
      raise "Please enter your linked-in credentials. The task will not work without them."
    end

    STDOUT.puts "Connecting to Linked-In API... \n"

    client = LinkedIn::Client.new(ENV['LINKEDIN_API_KEY'], ENV['LINKEDIN_API_SECRET'])

    if ENV["LINKEDIN_API_USER_ACCESS_TOKEN"].blank? or ENV["LINKEDIN_API_USER_ACCESS_KEY"].blank?

      STDOUT.puts "Generating User API Access Credentials \n"
      request_token = client.request_token({})
      rtoken = request_token.token
      rsecret = request_token.secret

      # to test from your desktop, open the following url in your browser
      # # and record the pin it gives you
      # request_token.authorize_url
      # => "https://api.linkedin.com/uas/oauth/authorize?oauth_token=<generated_token>"
      #
      user_auth_url = request_token.authorize_url.gsub("<generated_token>", rtoken)

      STDOUT.puts "Please visit the following url. Follow the instructions and when linked-in gives you a key enter it here"
      STDOUT.puts user_auth_url
      print "Your pin: "
      pin = STDIN.gets.chomp

      user_key,user_auth_token = client.authorize_from_request(rtoken, rsecret, pin)

      STDOUT.puts "\n If you wish to skip this step in the future. Run the following command \n"
      STDOUT.puts "export LINKEDIN_API_USER_ACCESS_KEY=#{user_key} && export LINKEDIN_API_USER_ACCESS_TOKEN=#{user_auth_token} \n"
    end


    if ENV["LINKEDIN_API_USER_ACCESS_TOKEN"].present? and ENV["LINKEDIN_API_USER_ACCESS_KEY"].present?
      STDOUT.puts "Authorizing on the Linked-In API \n"
      client.authorize_from_access(ENV["LINKEDIN_API_USER_ACCESS_KEY"], ENV["LINKEDIN_API_USER_ACCESS_TOKEN"])
    end

    STDOUT.puts "Gathering Data for Contact Ranking.. "

    fields = %w(id first-name last-name public-profile-url picture-url num-connections num-connections-capped positions api-standard-profile-request distance location industry relation-to-viewer specialties)
    connections_resp = client.connections(fields: fields, start: 0, count: 500)
    connects = connections_resp["all"]
    connects.reject{|c| c.num_connections.blank? }.sort_by{|c| -c.num_connections }
    most_val = connects.reject{|c| c.num_connections.blank? }.sort_by{|c| -c.num_connections }.first(25)
    least_val = connects.reject{|c| c.num_connections.blank? }.sort_by{|c| -c.num_connections }.last(25)


    STDOUT.puts "Genrating CSVs.. \n"
    CSV.open("./most_valuable_contacts.csv", "wb") do |csv|
      csv << ["Name", "Location (Country Code - Area)", "Profile Url"]
        
      most_val.each do |contact|
        csv << [contact.first_name + " " + contact.last_name , contact.location.country.code.upcase + " - " + contact.location.name , contact.public_profile_url]
      end
    end

    CSV.open("./least_valuable_contacts.csv", "wb") do |csv|
      csv << ["Name", "Location (Country Code - Area)", "Profile Url"]
        
      least_val.each do |contact|
        csv << [contact.first_name + " " + contact.last_name , contact.location.country.code.upcase + " - " + contact.location.name , contact.public_profile_url]
      end
    end

    STDOUT.puts "Done! Check out most_valuable_contacts.csv and least_valuable_contacts.csv in the current directory."

  end

end
