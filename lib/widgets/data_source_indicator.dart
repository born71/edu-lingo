import 'package:flutter/material.dart';

/// Widget to show data source indicator in the UI
class DataSourceIndicator extends StatelessWidget {
  final String source;
  final bool isLoading;

  const DataSourceIndicator({
    super.key,
    required this.source,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade600),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Loading...',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    IconData icon;
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    String displayText;

    switch (source.toLowerCase()) {
      case 'api':
      case 'microservice':
        icon = Icons.cloud_done;
        backgroundColor = Colors.deepPurple.shade900;
        borderColor = Colors.deepPurple.shade400;
        textColor = Colors.purpleAccent.shade100;
        displayText = '🌐 Live API';
        break;
      case 'cache':
      case 'cached':
        icon = Icons.storage;
        backgroundColor = Colors.indigo.shade900;
        borderColor = Colors.indigo.shade400;
        textColor = Colors.indigoAccent.shade100;
        displayText = '💾 Cached';
        break;
      case 'local':
      case 'default':
      case 'offline':
        icon = Icons.folder;
        backgroundColor = Colors.grey.shade800;
        borderColor = Colors.grey.shade600;
        textColor = Colors.grey.shade300;
        displayText = '📄 Local';
        break;
      default:
        icon = Icons.help_outline;
        backgroundColor = Colors.amber.shade900;
        borderColor = Colors.amber.shade600;
        textColor = Colors.amber.shade200;
        displayText = '❓ $source';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            displayText,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}