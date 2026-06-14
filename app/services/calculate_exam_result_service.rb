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

    Result.new(true, exam, nil)
  rescue StandardError => e
    Result.new(false, exam, e.message)
  end
end
