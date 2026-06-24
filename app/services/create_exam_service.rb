class CreateExamService
  Result = Struct.new(:success?, :exam, :error_message)

  def self.call(user:, subject_id:, questions_count:)
    subject = user.subjects.find_by(id: subject_id)
    return Result.new(false, nil, "Matéria não encontrada") unless subject

    count = questions_count.to_i
    return Result.new(false, nil, "A quantidade de questões deve ser maior que zero") if count <= 0

    available_questions = subject.questions
    if available_questions.count < count
      return Result.new(false, nil, "Não há questões suficientes nesta matéria. Solicitado #{count}, mas apenas #{available_questions.count} disponíveis.")
    end

    exam = nil
    Exam.transaction do
      exam = Exam.create!(
        user: user,
        subject: subject,
        questions_count: count,
        correct_count: 0,
        status: :in_progress
      )

      # Seleciona N perguntas priorizando as menos respondidas e as respondidas há mais tempo
      selected_questions = available_questions
                             .order("times_answered ASC, last_answered_at ASC NULLS FIRST, RANDOM()")
                             .limit(count)
      
      exam_questions = selected_questions.map do |q|
        { exam_id: exam.id, question_id: q.id, created_at: Time.current, updated_at: Time.current }
      end

      ExamQuestion.insert_all(exam_questions)
    end

    Result.new(true, exam, nil)
  rescue StandardError => e
    Result.new(false, nil, e.message)
  end
end
