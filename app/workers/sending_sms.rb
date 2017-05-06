module SendingSms
  def deliver_sms(url)
    require "net/http"
    require "net/https"
    require "uri"
    require "json"
    
    #uri = URI.parse("https://www.google.com")
    #uri = URI('https://api.github.com/repos/swapnilp/etherpadlite/commits')
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE  
    request = Net::HTTP::Get.new(uri.request_uri)
    
    response = http.request(request)
    return response.body
  end
  
end
