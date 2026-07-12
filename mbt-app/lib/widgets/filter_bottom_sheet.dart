import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({Key? key}) : super(key: key);

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String _selectedCategory = 'All Categories';
  String _selectedLevel = 'All Levels';
  String _selectedDuration = 'Any Duration';
  String _selectedSort = 'Most Popular';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filter Courses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textLight),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 24),
          _buildDropdown('Category', _selectedCategory, ['All Categories', 'Hardware Repair', 'Software Mastery', 'Micro-Soldering'], (val) {
            setState(() => _selectedCategory = val!);
          }),
          const SizedBox(height: 16),
          _buildDropdown('Skill Level', _selectedLevel, ['All Levels', 'Beginner', 'Intermediate', 'Advanced'], (val) {
            setState(() => _selectedLevel = val!);
          }),
          const SizedBox(height: 16),
          _buildDropdown('Duration', _selectedDuration, ['Any Duration', 'Under 5 hours', '5 - 10 hours', 'Over 10 hours'], (val) {
            setState(() => _selectedDuration = val!);
          }),
          const SizedBox(height: 16),
          _buildDropdown('Sort By', _selectedSort, ['Most Popular', 'Newest', 'Highest Rated', 'Lowest Price'], (val) {
            setState(() => _selectedSort = val!);
          }),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = 'All Categories';
                      _selectedLevel = 'All Levels';
                      _selectedDuration = 'Any Duration';
                      _selectedSort = 'Most Popular';
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Reset', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textDark)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textLight),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: const TextStyle(color: AppColors.textDark)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
