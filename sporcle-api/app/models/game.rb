class Game < ApplicationRecord
  belongs_to :song
  has_many :guesses

  @@key = '1a3856t83e01b171' #this needs to change for production
  @@iv = '1s3b5bu83602s11t'

  def self.generate_hint(word)
    if word.length < 3
      hint = "Very short word"
    else
      i = 1
      hint = word[0]
      until i == (word.length - 1) do
          hint += "*"
          i += 1
      end
      hint += word[-1]
    end
  end
  
  def find_guesses(word)    #return indices where it is found - array of numbers - or possibly object with word and indices
    lyrics = self.lower_case_lyrics
    word = word.gsub(/[!@#$%^&*()-=_+|;:",.<>?\s]/, '').downcase
    array = []
    lyrics.each_with_index {|value, index| value == word ? array.push(index) : nil}
    return {guess: word.upcase, indices: array}
  end

  def update_score(score)
    self.update(total: self.total + score)
    return self.total
  end

  def self.encrypt(plain_data)
    cipher = OpenSSL::Cipher::AES128.new(:CBC)
    cipher.encrypt            
    cipher.key = @@key
    cipher.iv = @@iv
    encrypted = cipher.update(plain_data) + cipher.final
    encoded = Base64.encode64(encrypted).encode('utf-8')
  end

  def self.decrypt(encoded_data)
    encoded = encoded_data;
    decoded = Base64.decode64 encoded.encode('ascii-8bit')
    decipher = OpenSSL::Cipher::AES.new(128, :CBC)
    decipher.decrypt
    decipher.key = @@key
    decipher.iv = @@iv       
    plain = decipher.update(decoded) + decipher.final      
  end

  def calculate_time
    time_in_seconds = (self.updated_at - self.created_at).round
    time_in_seconds = 300 - time_in_seconds
    if time_in_seconds < 0
      return "0:00"
    else
      minutes = time_in_seconds / 60
      seconds = time_in_seconds % 60
      seconds = seconds < 10 ? "0" + seconds.to_s : seconds
      return "#{minutes}:#{seconds}"
    end

  end

  def lower_case_lyrics
   lyricsArr = self.song.lyric
   lyricsArr.gsub(/[!@#$%^&*()-=_+|;:",.<>?]/, '').downcase.split(" ")
  end

end
