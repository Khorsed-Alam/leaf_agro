import 'package:flutter/material.dart';

/// Screen 28 – Help Guide Model
class HelpGuide {
  final String id;
  final String titleEn;
  final String titleBn;
  final String descriptionEn;
  final String descriptionBn;
  final String readingTimeEn;
  final String readingTimeBn;
  final IconData icon;
  final List<String> stepsEn;
  final List<String> stepsBn;
  final List<String> visualSequenceEn;
  final List<String> visualSequenceBn;
  final List<String> keyNotesEn;
  final List<String> keyNotesBn;
  final List<String>? goodTipsEn;
  final List<String>? goodTipsBn;
  final List<String>? poorTipsEn;
  final List<String>? poorTipsBn;

  const HelpGuide({
    required this.id,
    required this.titleEn,
    required this.titleBn,
    required this.descriptionEn,
    required this.descriptionBn,
    required this.readingTimeEn,
    required this.readingTimeBn,
    required this.icon,
    required this.stepsEn,
    required this.stepsBn,
    required this.visualSequenceEn,
    required this.visualSequenceBn,
    required this.keyNotesEn,
    required this.keyNotesBn,
    this.goodTipsEn,
    this.goodTipsBn,
    this.poorTipsEn,
    this.poorTipsBn,
  });

  String title(bool isBn) => isBn ? titleBn : titleEn;
  String description(bool isBn) => isBn ? descriptionBn : descriptionEn;
  String readingTime(bool isBn) => isBn ? readingTimeBn : readingTimeEn;
  List<String> steps(bool isBn) => isBn ? stepsBn : stepsEn;
  List<String> visualSequence(bool isBn) =>
      isBn ? visualSequenceBn : visualSequenceEn;
  List<String> keyNotes(bool isBn) => isBn ? keyNotesBn : keyNotesEn;
  List<String>? goodTips(bool isBn) => isBn ? goodTipsBn : goodTipsEn;
  List<String>? poorTips(bool isBn) => isBn ? poorTipsBn : poorTipsEn;

  bool matchesQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return titleEn.toLowerCase().contains(q) ||
        titleBn.toLowerCase().contains(q) ||
        descriptionEn.toLowerCase().contains(q) ||
        descriptionBn.toLowerCase().contains(q) ||
        stepsEn.any((s) => s.toLowerCase().contains(q)) ||
        stepsBn.any((s) => s.toLowerCase().contains(q)) ||
        keyNotesEn.any((k) => k.toLowerCase().contains(q)) ||
        keyNotesBn.any((k) => k.toLowerCase().contains(q));
  }
}

/// Screen 28 – FAQ Item Model
class FaqItem {
  final String id;
  final String questionEn;
  final String questionBn;
  final String answerEn;
  final String answerBn;
  final String category;
  final List<String> tags;

  const FaqItem({
    required this.id,
    required this.questionEn,
    required this.questionBn,
    required this.answerEn,
    required this.answerBn,
    required this.category,
    this.tags = const [],
  });

  String question(bool isBn) => isBn ? questionBn : questionEn;
  String answer(bool isBn) => isBn ? answerBn : answerEn;

  bool matchesQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return questionEn.toLowerCase().contains(q) ||
        questionBn.toLowerCase().contains(q) ||
        answerEn.toLowerCase().contains(q) ||
        answerBn.toLowerCase().contains(q) ||
        tags.any((t) => t.toLowerCase().contains(q));
  }
}
