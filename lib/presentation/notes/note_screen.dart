import 'package:flutter/material.dart';
import 'package:note_book/infra/extensions/media_query_extension.dart';
import '../../infra/common/common_widgets/app_bars/basic_app_bar.dart';
import '../../infra/core/core_exports.dart';

class NoteScreen extends StatelessWidget {
  NoteScreen({super.key});

  final List<Map<String, String>> notes = [
    {
      'title': 'Meeting Notes',
      'category': 'Work',
      'date': '2025-04-09',
      'content':
      'Discussed Q2 strategies and performance reviews. Next steps involve finalizing project timelines and budgets.'
    },
    {
      'title': 'Grocery List',
      'category': 'Personal',
      'date': '2025-04-08',
      'content': 'Milk, Eggs, Bread, Bananas, Chicken, Rice, Tomatoes, Spinach, Pasta.'
    },
    {
      'title': 'Flutter Ideas',
      'category': 'Development',
      'date': '2025-04-05',
      'content':
      'Implement a rich text editor, use state restoration, explore Flutter web optimizations.'
    },
    {
      'title': 'Meeting Notes',
      'category': 'Work',
      'date': '2025-04-09',
      'content':
      'Discussed Q2 strategies and performance reviews. Next steps involve finalizing project timelines and budgets.'
    },
    {
      'title': 'Grocery List',
      'category': 'Personal',
      'date': '2025-04-08',
      'content': 'Milk, Eggs, Bread, Bananas, Chicken, Rice, Tomatoes, Spinach, Pasta.'
    },
    {
      'title': 'Flutter Ideas',
      'category': 'Development',
      'date': '2025-04-05',
      'content':
      'Implement a rich text editor, use state restoration, explore Flutter web optimizations.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppBar(title: "Note Book"),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        child: Icon(Icons.add, size: 32),
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addnote);
        },
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.mediaQueryWidth * 0.09, // Make horizontal padding dynamic
        ),
        child: ListView.separated(
          padding: EdgeInsets.only(top: 20),
          itemCount: notes.length,
          separatorBuilder: (_, __) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            final note = notes[index];
            return NoteCard(
              title: note['title']!,
              category: note['category']!,
              date: note['date']!,
              content: note['content']!,
              onTap: () {
                // Handle navigation or action
                print('Tapped on: ${note['title']}');
              },
            );
          },
        ),
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  final String title;
  final String category;
  final String date;
  final String content;
  final VoidCallback onTap;

  const NoteCard({
    super.key,
    required this.title,
    required this.category,
    required this.date,
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(category,
                      style: TextStyle(color: Colors.grey.shade600)),
                  Text(date, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
