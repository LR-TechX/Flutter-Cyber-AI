class QAEntry {
  final String question;
  final String answer;

  const QAEntry({required this.question, required this.answer});

  factory QAEntry.fromJson(Map<String, dynamic> json) => QAEntry(
        question: json['question'] as String,
        answer: json['answer'] as String,
      );

  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
      };
}
