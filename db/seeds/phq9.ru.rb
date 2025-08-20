# db/seeds/phq9.ru.rb

user =  User.find_by(id: 1) || User.find_by(id: 10) || User.first || raise("You need at least one user in the DB to assign the quiz.")

phq9 = Quiz.create!(
  user: user,
  title: "PHQ-9 — Опросник для оценки депрессии",
  description: "Пациентский опросник здоровья (9 пунктов). Используется для скрининга и оценки тяжести депрессивных симптомов."
)

# PHQ-9 questions in Russian
questions_texts = [
  "Небольшой интерес или удовольствие от выполнения каких-либо действий",
  "Чувство подавленности, депрессии или безнадежности",
  "Проблемы с засыпанием или слишком долгий сон",
  "Чувство усталости или недостатка энергии",
  "Плохой аппетит или переедание",
  "Плохое самочувствие — чувство неудачи или разочарования в себе или своей семье",
  "Проблемы с концентрацией внимания, например, на чтении газеты или просмотре телевизора",
  "Двигаетесь или говорите очень медленно, что могли бы заметить другие, или наоборот — настолько суетливы или беспокойны, что двигаетесь больше, чем обычно",
  "Мысли о том, что лучше умереть или причинить себе вред каким-либо образом"
]

# Likert scale options
likert_options = [
  { label: "Совсем нет", score: 0 },
  { label: "Несколько дней в неделю", score: 1 },
  { label: "Более половины дней", score: 2 },
  { label: "Почти каждый день", score: 3 }
]

# Create questions + options
questions_texts.each do |q_text|
  q = phq9.questions.create!(text: q_text, input_type: "likert")
  likert_options.each_with_index do |opt, i|
    q.question_options.create!(label: opt[:label], score: opt[:score], position: i + 1)
  end
end

# Add scoring rules
phq9.quiz_scoring_rules.create!([
  { min_score: 0,  max_score: 4,  label: "Минимальные или отсутствующие симптомы депрессии" },
  { min_score: 5,  max_score: 9,  label: "Лёгкая депрессия" },
  { min_score: 10, max_score: 14, label: "Умеренная депрессия" },
  { min_score: 15, max_score: 19, label: "Умеренно выраженная депрессия" },
  { min_score: 20, max_score: 27, label: "Тяжёлая депрессия" }
])

puts "Seeded PHQ-9 in Russian with #{phq9.questions.count} questions and #{phq9.quiz_scoring_rules.count} scoring rules."
