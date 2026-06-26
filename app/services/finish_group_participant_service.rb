class FinishGroupParticipantService
  Result = Struct.new(:success?, :participant, :error_message)

  def self.call(participant:)
    return Result.new(false, participant, "Participante já finalizou") if participant.finished?

    correct = participant.group_answers.where(is_correct: true).count

    participant.update!(
      correct_count: correct,
      status: :finished
    )

    question_ids = participant.group_answers.pluck(:question_id)
    Question.where(id: question_ids).update_all(
      "times_answered = times_answered + 1, last_answered_at = CURRENT_TIMESTAMP"
    )

    Result.new(true, participant, nil)
  rescue StandardError => e
    Result.new(false, participant, e.message)
  end
end
