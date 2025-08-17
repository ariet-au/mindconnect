# db/seeds/k10.ru.rb

user = User.first # Replace with the quiz owner

k10_ru = Quiz.create!(
  title: "Kessler-10 (K10) — Russian version",
  description: "Оценка психологического дистресса за последние 4 недели. Выберите, как часто вы испытывали указанные состояния.",
  user: user
)

questions_texts = [
  "За последние 4 недели как часто вы чувствовали усталость без причины?",
  "За последние 4 недели как часто вы нервничали?",
  "За последние 4 недели как часто вы нервничали так сильно, что ничто не могло вас успокоить?",
  "За последние 4 недели как часто вы ощущали свою безнадежность?",
  "За последние 4 недели как часто вы были беспокойны или суетливы?",
  "За последние 4 недели как часто вы были настолько беспокойны, что не могли усидеть на месте?",
  "За последние 4 недели как часто вы ощущали, что у вас депрессия?",
  "За последние 4 недели как часто вы чувствовали, что всё требует усилий?",
  "За последние 4 недели как часто вы чувствовали себя так грустно, что ничто не могло вас развеселить?",
  "За последние 4 недели как часто вы ощущали, что вы никчемны?"
]

# Option labels (1–5 scale)
option_labels = [
  "Никогда",
  "Редко",
  "Иногда",
  "Часто",
  "Почти всегда"
]

questions_texts.each do |text|
  question = k10_ru.questions.create!(text: text, input_type: "likert")
  option_labels.each_with_index do |label, idx|
    question.question_options.create!(label: label, score: idx + 1)
  end
end

k10_ru.quiz_scoring_rules.create!([
  { min_score: 10, max_score: 15, label: "Низкий уровень стресса" },
  { min_score: 16, max_score: 21, label: "Умеренный уровень стресса" },
  { min_score: 22, max_score: 29, label: "Высокий уровень стресса" },
  { min_score: 30, max_score: 50, label: "Очень высокий уровень стресса" }
])

puts "Kessler-10 Russian quiz seeded successfully!"
