class CalculateExamResultService
  Result = Struct.new(:success?, :exam, :error_message)

  def self.call(exam:)
    return Result.new(false, exam, "Exam is already finished") if exam.finished?

    # All unanswered questions are considered incorrect when finalizing
    correct = exam.exam_questions.where(is_correct: true).count

    exam.update!(
      correct_count: correct,
      status: :finished
    )

    question_ids = exam.exam_questions.pluck(:question_id)
    Question.where(id: question_ids).update_all(
      "times_answered = times_answered + 1, last_answered_at = CURRENT_TIMESTAMP"
    )

    Result.new(true, exam, nil)
  rescue StandardError => e
    Result.new(false, exam, e.message)
  end
end
