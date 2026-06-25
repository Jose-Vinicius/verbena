class FinishGroupParticipantService
  Result = Struct.new(:success?, :participant, :error_message)

  def self.call(participant:)
    return Result.new(false, participant, "Participante já finalizou") if participant.finished?

    correct = participant.group_answers.where(is_correct: true).count

    participant.update!(
      correct_count: correct,
      status: :finished
    )

    Result.new(true, participant, nil)
  rescue StandardError => e
    Result.new(false, participant, e.message)
  end
end
