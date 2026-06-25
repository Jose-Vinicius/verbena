class CreateGroupQuizService
  Result = Struct.new(:success?, :group_quiz, :error_message)

  def self.call(user:, subject_id:, questions_count:, title:)
    subject = user.subjects.find_by(id: subject_id)
    return Result.new(false, nil, "Matéria não encontrada") unless subject

    count = questions_count.to_i
    return Result.new(false, nil, "A quantidade de questões deve ser maior que zero") if count <= 0

    available_questions = subject.questions.active
    if available_questions.count < count
      return Result.new(false, nil, "Não há questões suficientes. Solicitado #{count}, mas apenas #{available_questions.count} disponíveis.")
    end

    group_quiz = nil
    GroupQuiz.transaction do
      group_quiz = GroupQuiz.create!(
        user: user,
        subject: subject,
        title: title.presence || "Simulado de #{subject.name}",
        questions_count: count
      )

      selected_questions = available_questions
                             .order("times_answered ASC, last_answered_at ASC NULLS FIRST, RANDOM()")
                             .limit(count)

      quiz_questions = selected_questions.each_with_index.map do |q, idx|
        { group_quiz_id: group_quiz.id, question_id: q.id, position: idx + 1, created_at: Time.current, updated_at: Time.current }
      end

      GroupQuizQuestion.insert_all(quiz_questions)
    end

    Result.new(true, group_quiz, nil)
  rescue StandardError => e
    Result.new(false, nil, e.message)
  end
end
