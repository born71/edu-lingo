import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LeaderboardScreenContent();
  }
}

class LeaderboardScreenContent extends StatefulWidget {
  const LeaderboardScreenContent({super.key});

  @override
  State<LeaderboardScreenContent> createState() => _LeaderboardScreenContentState();
}

class _LeaderboardScreenContentState extends State<LeaderboardScreenContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock leaderboard data - In production, this would come from an API
  final List<LeaderboardEntry> _weeklyLeaderboard = [
    LeaderboardEntry(rank: 1, name: 'Alex Chen', xp: 2450, avatarColor: Colors.red, isCurrentUser: false),
    LeaderboardEntry(rank: 2, name: 'Maria Garcia', xp: 2180, avatarColor: Colors.blue, isCurrentUser: false),
    LeaderboardEntry(rank: 3, name: 'John Smith', xp: 1950, avatarColor: Colors.green, isCurrentUser: false),
    LeaderboardEntry(rank: 4, name: 'Sarah Johnson', xp: 1820, avatarColor: Colors.purple, isCurrentUser: false),
    LeaderboardEntry(rank: 5, name: 'You', xp: 1650, avatarColor: Colors.deepPurple, isCurrentUser: true),
    LeaderboardEntry(rank: 6, name: 'Mike Wilson', xp: 1540, avatarColor: Colors.orange, isCurrentUser: false),
    LeaderboardEntry(rank: 7, name: 'Emma Davis', xp: 1380, avatarColor: Colors.teal, isCurrentUser: false),
    LeaderboardEntry(rank: 8, name: 'David Lee', xp: 1220, avatarColor: Colors.pink, isCurrentUser: false),
    LeaderboardEntry(rank: 9, name: 'Lisa Brown', xp: 1100, avatarColor: Colors.indigo, isCurrentUser: false),
    LeaderboardEntry(rank: 10, name: 'Tom Anderson', xp: 980, avatarColor: Colors.cyan, isCurrentUser: false),
  ];

  final List<LeaderboardEntry> _allTimeLeaderboard = [
    LeaderboardEntry(rank: 1, name: 'Maria Garcia', xp: 45200, avatarColor: Colors.blue, isCurrentUser: false),
    LeaderboardEntry(rank: 2, name: 'Alex Chen', xp: 42800, avatarColor: Colors.red, isCurrentUser: false),
    LeaderboardEntry(rank: 3, name: 'Sarah Johnson', xp: 38500, avatarColor: Colors.purple, isCurrentUser: false),
    LeaderboardEntry(rank: 4, name: 'John Smith', xp: 35200, avatarColor: Colors.green, isCurrentUser: false),
    LeaderboardEntry(rank: 5, name: 'Emma Davis', xp: 32100, avatarColor: Colors.teal, isCurrentUser: false),
    LeaderboardEntry(rank: 6, name: 'Mike Wilson', xp: 28900, avatarColor: Colors.orange, isCurrentUser: false),
    LeaderboardEntry(rank: 7, name: 'David Lee', xp: 25600, avatarColor: Colors.pink, isCurrentUser: false),
    LeaderboardEntry(rank: 8, name: 'You', xp: 22400, avatarColor: Colors.deepPurple, isCurrentUser: true),
    LeaderboardEntry(rank: 9, name: 'Lisa Brown', xp: 19800, avatarColor: Colors.indigo, isCurrentUser: false),
    LeaderboardEntry(rank: 10, name: 'Tom Anderson', xp: 17500, avatarColor: Colors.cyan, isCurrentUser: false),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (context, progressProvider, child) {
        // Update current user's XP in the leaderboard
        final userXP = progressProvider.userProgress.totalXP;
        
        return Column(
          children: [
            // Header with user's current rank
            _buildUserRankHeader(userXP),
            
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.deepPurple.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade500,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, size: 18),
                        SizedBox(width: 8),
                        Text('This Week'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events, size: 18),
                        SizedBox(width: 8),
                        Text('All Time'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Leaderboard Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLeaderboardList(_weeklyLeaderboard, userXP),
                  _buildLeaderboardList(_allTimeLeaderboard, userXP),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserRankHeader(int userXP) {
    // Find user's rank in weekly leaderboard
    int userRank = _weeklyLeaderboard.indexWhere((e) => e.isCurrentUser) + 1;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.leaderboard, color: Colors.white, size: 24),
                Text(
                  '#$userRank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Weekly Rank',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.stars, color: Colors.amber.shade300, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '$userXP XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getMotivationalMessage(userRank),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage(int rank) {
    if (rank == 1) return '🏆 You\'re the champion!';
    if (rank <= 3) return '🔥 Amazing! Keep it up!';
    if (rank <= 5) return '💪 Almost there! Push harder!';
    if (rank <= 10) return '📈 Great progress this week!';
    return '🚀 Keep learning to climb up!';
  }

  Widget _buildLeaderboardList(List<LeaderboardEntry> leaderboard, int userXP) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: leaderboard.length,
      itemBuilder: (context, index) {
        final entry = leaderboard[index];
        return _buildLeaderboardItem(entry, index);
      },
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry, int index) {
    final isTopThree = entry.rank <= 3;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: entry.isCurrentUser 
              ? Colors.deepPurple.shade900.withOpacity(0.5)
              : const Color(0xFF1E1E2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: entry.isCurrentUser 
                ? Colors.deepPurple.shade400
                : isTopThree 
                    ? _getRankColor(entry.rank).withOpacity(0.5)
                    : Colors.transparent,
            width: entry.isCurrentUser ? 2 : 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rank
              SizedBox(
                width: 35,
                child: isTopThree
                    ? _buildRankBadge(entry.rank)
                    : Text(
                        '#${entry.rank}',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              // Avatar
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: entry.avatarColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: entry.avatarColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    entry.name[0].toUpperCase(),
                    style: TextStyle(
                      color: entry.avatarColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  entry.name,
                  style: TextStyle(
                    color: entry.isCurrentUser ? Colors.white : Colors.white,
                    fontWeight: entry.isCurrentUser ? FontWeight.bold : FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
              if (entry.isCurrentUser)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'YOU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.stars, color: Colors.amber.shade400, size: 20),
              const SizedBox(width: 4),
              Text(
                _formatXP(entry.xp),
                style: TextStyle(
                  color: Colors.amber.shade400,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    IconData icon;
    Color color;
    
    switch (rank) {
      case 1:
        icon = Icons.emoji_events;
        color = Colors.amber;
        break;
      case 2:
        icon = Icons.emoji_events;
        color = Colors.grey.shade400;
        break;
      case 3:
        icon = Icons.emoji_events;
        color = Colors.brown.shade400;
        break;
      default:
        icon = Icons.circle;
        color = Colors.grey;
    }
    
    return Icon(icon, color: color, size: 28);
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown.shade400;
      default:
        return Colors.transparent;
    }
  }

  String _formatXP(int xp) {
    if (xp >= 1000) {
      return '${(xp / 1000).toStringAsFixed(1)}k';
    }
    return xp.toString();
  }
}

class LeaderboardEntry {
  final int rank;
  final String name;
  final int xp;
  final Color avatarColor;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.xp,
    required this.avatarColor,
    required this.isCurrentUser,
  });
}
