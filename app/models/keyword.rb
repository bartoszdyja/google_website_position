class Keyword < ActiveRecord::Base
  belongs_to :website
  has_many :positions, dependent: :destroy

  after_save :check_position

  # private

  def check_position
    positions.create(rank: hit_google(website.url, phrase))
  end

  def hit_google(website, keyword)
    conn = Faraday.get("https://www.googleapis.com/customsearch/v1?q=#{keyword}&cx=#{ENV['secret_google_cx']}&key=#{ENV['secret_google_key']}")
    p conn.status
    if conn.status == 200
      response = JSON.parse(conn.body)['items']
      return 'Error! Nothing found' if response.blank?
      p links = response.map {|item| URI.parse(item['link']).host}
      links.find_index(URI.parse(website).host) || 'Not in the first 10'
    else
      'Please try again later'
    end
  end
end
