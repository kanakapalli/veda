/// Models for the Course Creation feature
library;

enum ChatMode { create, test }

enum MessageSender { user, ai }

class KnowledgeFile {
  final String id;
  final String name;
  final String size;
  final String type;

  KnowledgeFile({
    required this.id,
    required this.name,
    required this.size,
    required this.type,
  });
}

class ChatMessage {
  final String id;
  final MessageSender sender;
  final String text;
  final bool isLoading;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    this.isLoading = false,
  });

  ChatMessage copyWith({
    String? id,
    MessageSender? sender,
    String? text,
    bool? isLoading,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CourseModule {
  final String id;
  final String title;
  final bool expanded;
  final List<Lesson> lessons;

  CourseModule({
    required this.id,
    required this.title,
    required this.expanded,
    required this.lessons,
  });

  CourseModule copyWith({
    String? id,
    String? title,
    bool? expanded,
    List<Lesson>? lessons,
  }) {
    return CourseModule(
      id: id ?? this.id,
      title: title ?? this.title,
      expanded: expanded ?? this.expanded,
      lessons: lessons ?? this.lessons,
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final String duration;

  Lesson({
    required this.id,
    required this.title,
    required this.duration,
  });
}
