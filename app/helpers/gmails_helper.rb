module GmailsHelper
  def get_messages(token, query)
    uri = URI.parse("https://www.googleapis.com/gmail/v1/users/me/messages?q=#{query}")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{token}"
    req_options = { use_ssl: uri.scheme == "https" }
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    JSON.parse(response.body)
  end
end
