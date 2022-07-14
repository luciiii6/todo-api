
FactoryBot.define do
  factory :todo do
    title { Faker::Quote.famous_last_words }
    completed { false }
    order { Faker::Number.number(digits:2) }
    url { Faker::CryptoCoin.url_logo }
  end
end