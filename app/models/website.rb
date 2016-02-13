class Website < ActiveRecord::Base
  belongs_to :account
  has_many :keywords
  validates :name, :url, presence: true
  validate :check_url

  def check_url
    errors.add(:url, "I cannot connect to this URL") unless check_status
  end

  def check_status
    unless self.url[/\Ahttp:\/\//] || self.url[/\Ahttps:\/\//]
      self.url = "http://#{self.url}"
    end
    begin
      Faraday.head(self.url).status < 400
    rescue Faraday::Error::ConnectionFailed
    false
    end
  end
end