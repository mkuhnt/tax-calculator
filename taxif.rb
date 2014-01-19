require 'net/http'
require 'openssl'
require 'nokogiri'

def get_data(salary, tax_class)
  uri = URI.parse("https://www.bmf-steuerrechner.de/interface/2014.jsp?LZZ=1&RE4=#{salary}&STKL=#{tax_class}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  response.body
end

def extract_information(data, key)
  doc = Nokogiri::HTML(data)
  node = doc.xpath("//ausgabe[@name='#{key}']")
  node.attr("value").value.to_i
end

def fto(value)
  (value / 100).to_s.gsub(/(\d)(?=(\d\d\d)+(?!\d))/, '\1.')
end

gehalt = ARGV[0] || "80000"

# add the cents
gehalt = gehalt.to_i * 100

data = get_data(gehalt, 1)
lohnsteuer = extract_information(data, "LSTLZZ")
soli       = extract_information(data, "SOLZLZZ")

puts "Gehalt pro Jahr:         #{fto(gehalt)}"
puts "       pro Monat:        #{fto(gehalt/12)}"
puts ""
puts "Lohnsteuer pro Jahr:     #{fto(lohnsteuer)}"
puts "Solidaritätsbeitrag:     #{fto(soli)}"
puts ""
netto_gehalt = gehalt - lohnsteuer - soli
puts "Gehalt netto pro Jahr:   #{fto(netto_gehalt)}"
puts "Gehalt netto pro Monat:  #{fto(netto_gehalt / 12)}"
