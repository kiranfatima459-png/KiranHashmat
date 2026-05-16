import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/plant.dart';
import '../services/supabase_service.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SupabaseService supabaseService = SupabaseService();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            const Color(0xFFE8F5E9).withOpacity(0.5),
          ],
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Garden Analytics",
                      style: GoogleFonts.philosopher(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B5E20),
                      ),
                    ),
                    Text(
                      "Tracking your magic forest's health",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: FutureBuilder<List<Plant>>(
                future: supabaseService.fetchPlants(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final plants = snapshot.data ?? [];
                  final needsWater = plants.where((p) {
                    final next = p.lastWatered.add(Duration(days: p.wateringFrequency));
                    return DateTime.now().isAfter(next);
                  }).length;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        _buildGlowStatCard(
                          context,
                          "Alive Plants",
                          "${plants.length}",
                          Icons.eco,
                          const Color(0xFF00C853),
                        ),
                        const SizedBox(height: 16),
                        _buildGlowStatCard(
                          context,
                          "Thirsty Souls",
                          "$needsWater",
                          Icons.water_drop,
                          Colors.redAccent,
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          "Recent Activity",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              ),
            ),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: supabaseService.fetchRecentHistory(),
              builder: (context, snapshot) {
                final history = snapshot.data ?? [];
                if (history.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Text("No magic events yet...")),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildHistoryItem(history[index]),
                    childCount: history.length,
                  ),
                );
              },
            ),
            
            const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowStatCard(BuildContext context, String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Text(
            val,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final plantName = item['plants']?['name'] ?? 'Unknown Seed';
    final date = DateTime.parse(item['watered_at']);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.withOpacity(0.1)),
      ),
      child: ListTile(
        dense: true,
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE8F5E9),
          child: Icon(Icons.check_circle_rounded, color: Color(0xFF00C853), size: 20),
        ),
        title: Text(plantName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${date.day}/${date.month} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}"),
      ),
    );
  }
}
