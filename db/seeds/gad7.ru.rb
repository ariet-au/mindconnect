# db/seeds/gad7.ru.rb

user =  User.find_by(id: 1) || User.find_by(id: 10) || User.first || raise("You need at least one user in the DB to assign the quiz.")

gad7_ru = Quiz.create!(
  title: "GAD-7 (Общая тревожность, 7 вопросов)",
  description: "Инструмент для скрининга генерализованного тревожного расстройства.",
  user: user
)

# Questions in Russian
questions_texts = [
  "Чувство нервозности, тревоги или напряжения",
  "Неспособность остановить или контролировать беспокойство",
  "Слишком много беспокойства о разных вещах",
  "Проблемы с расслаблением",
  "Быть настолько беспокойным, что трудно усидеть на месте",
  "Легко раздражаться или становиться раздражительным",
  "Чувство страха, как будто может произойти что-то ужасное"
]

questions_texts.each do |text|
  question = gad7_ru.questions.create!(text: text, input_type: "likert")
  question.question_options.create!([
    { label: "Совсем нет", score: 0 },
    { label: "Несколько дней в неделю", score: 1 },
    { label: "Более половины дней", score: 2 },
    { label: "Почти каждый день", score: 3 }
  ])
end

# Scoring rules in Russian
gad7_ru.quiz_scoring_rules.create!([
  { min_score: 0, max_score: 4, label: "Минимальная тревожность" },
  { min_score: 5, max_score: 9, label: "Лёгкая тревожность" },
  { min_score: 10, max_score: 14, label: "Умеренная тревожность" },
  { min_score: 15, max_score: 21, label: "Тяжёлая тревожность" }
])

puts "GAD-7 Russian quiz seeded successfully!"
