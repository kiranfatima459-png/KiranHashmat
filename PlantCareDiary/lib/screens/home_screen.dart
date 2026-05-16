import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/plant.dart';
import '../services/supabase_service.dart';
import '../widgets/plant_card.dart';
import '../widgets/plant_dialog.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<Plant>> _plantsFuture;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _refreshPlants();
  }

  void _refreshPlants() {
    setState(() {
      _plantsFuture = _supabaseService.fetchPlants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF5F9F5),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildGardenView(),
          const StatsScreen(),
        ],
      ),
      bottomNavigationBar: _buildFloatingNavBar(),
      floatingActionButton: _currentIndex == 0 ? _buildAddButton() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildGardenView() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 120.0,
          floating: false,
          pinned: true,
          elevation: 0,
          backgroundColor: const Color(0xFF1B5E20),
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Text(
              "My Magic Garden",
              style: GoogleFonts.philosopher(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                ),
              ),
              child: Center(
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(Icons.eco, size: 150, color: Colors.white),
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: _refreshPlants,
            ),
          ],
        ),
        
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          sliver: FutureBuilder<List<Plant>>(
            future: _plantsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) return _buildSliverError(snapshot.error.toString());
              
              final plants = snapshot.data ?? [];
              if (plants.isEmpty) return _buildSliverEmpty();

              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final plant = plants[index];
                    return PlantCard(
                      plant: plant,
                      onWater: () => _handleAction(() => _supabaseService.waterPlant(plant), "${plant.name} refreshed!"),
                      onEdit: () => _handleEdit(plant),
                      onDelete: () => _handleDelete(plant),
                    );
                  },
                  childCount: plants.length,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingNavBar() {
    return Container(
      height: 60,
      margin: const EdgeInsets.fromLTRB(30, 0, 30, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.eco_rounded, "Garden"),
          const SizedBox(width: 40),
          _buildNavItem(1, Icons.bar_chart_rounded, "Stats"),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white54,
            size: isSelected ? 24 : 20,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? Colors.white : Colors.white54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return FloatingActionButton(
      onPressed: _handleAdd,
      backgroundColor: const Color(0xFF00C853),
      child: const Icon(Icons.add, color: Colors.white, size: 30),
    );
  }

  // Action Handlers
  Future<void> _handleAction(Future Function() action, String message) async {
    try {
      await action();
      _refreshPlants();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _handleAdd() async {
    final result = await showDialog<Plant>(
      context: context,
      builder: (context) => const PlantDialog(),
    );
    if (result != null) _handleAction(() => _supabaseService.addPlant(result), "Added to garden! ✨");
  }

  Future<void> _handleEdit(Plant plant) async {
    final result = await showDialog<Plant>(
      context: context,
      builder: (context) => PlantDialog(plant: plant),
    );
    if (result != null) _handleAction(() => _supabaseService.updatePlant(result), "Updated! 🌿");
  }

  Future<void> _handleDelete(Plant plant) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Plant?"),
        content: Text("Are you sure you want to remove ${plant.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) _handleAction(() => _supabaseService.deletePlant(plant.id), "Removed. ✅");
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  Widget _buildSliverEmpty() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.spa_outlined, size: 60, color: Colors.green[200]),
            const SizedBox(height: 16),
            const Text("Your garden is empty...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverError(String err) {
    return SliverFillRemaining(
      child: Center(child: Text("Error: $err", textAlign: TextAlign.center)),
    );
  }
}
