import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nubmed/utils/Color_codes.dart';

class AdminMedicinePage extends StatefulWidget {
  const AdminMedicinePage({super.key});
  static String name = '/admin-medicine-page';

  @override
  State<AdminMedicinePage> createState() => _AdminMedicinePageState();
}

class _AdminMedicinePageState extends State<AdminMedicinePage> {
  String _searchTerm = '';
  final TextEditingController _searchController = TextEditingController();
  String _filterType = 'All';
  bool _showLowStockOnly = false;
  Future<List<QueryDocumentSnapshot>>? _medicinesFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() {
    setState(() {
      _medicinesFuture = FirebaseFirestore.instance
          .collection('medicines')
          .orderBy('name')
          .get()
          .then((snapshot) => snapshot.docs);
    });
    return _medicinesFuture!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medicine Inventory"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addOrEditMedicine(),
          ),
        ],
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _medicinesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No medicines available"));
          }

          final medicines = snapshot.data!;
          final filteredData = medicines.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data['name']?.toString().toLowerCase() ?? '';
            final type = data['type']?.toString() ?? '';
            final stock = (data['stock'] ?? 0) as int;
            final minStock = (data['minStock'] ?? 10) as int;

            final searchMatch = _searchTerm.isEmpty ||
                name.contains(_searchTerm.toLowerCase());
            final typeMatch = _filterType == 'All' ||
                type == _filterType;
            final stockMatch = !_showLowStockOnly || stock <= minStock;

            return searchMatch && typeMatch && stockMatch;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search medicines...",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchTerm = '');
                          },
                        )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) => setState(() => _searchTerm = value),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _filterType,
                            items: ['All', 'Tablet', 'Syrup', 'Injection', 'Capsule', 'Drops']
                                .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                                .toList(),
                            onChanged: (value) => setState(() => _filterType = value!),
                            decoration: InputDecoration(
                              labelText: 'Filter by Type',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilterChip(
                          label: const Text("Low Stock"),
                          selected: _showLowStockOnly,
                          onSelected: (selected) => setState(() => _showLowStockOnly = selected),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredData.isEmpty
                    ? const Center(child: Text("No matching medicines found"))
                    : ListView.builder(
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    final doc = filteredData[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final stock = (data['stock'] ?? 0) as int;
                    final minStock = (data['minStock'] ?? 10) as int;
                    final price = data['price']?.toString() ?? 'N/A';
                    final expiry = data['expiry'] is Timestamp
                        ? data['expiry'].toDate().toString().substring(0, 10)
                        : data['expiry']?.toString() ?? 'N/A';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        title: Text(
                          data['name'] ?? 'Unknown Medicine',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text("${data['type']} • ${data['manufacturer']}"),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text("Stock: $stock"),
                                if (stock <= minStock)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Icon(Icons.warning,
                                        color: Colors.orange, size: 16),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow("Generic Name:", data['genericName']),
                                _buildDetailRow("Price:", "\$$price"),
                                _buildDetailRow("Uses:", data['uses']),
                                _buildDetailRow("Dosage:", data['dosage']),
                                _buildDetailRow("Side Effects:",
                                    data['side_effects'] ?? data['sideEffects']),
                                _buildDetailRow("Expiry Date:", expiry),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton(
                                      onPressed: () => _addOrEditMedicine(document: doc),
                                      child: const Text("Edit"),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      onPressed: () => _deleteMedicine(doc.id),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value ?? 'N/A')),
        ],
      ),
    );
  }

  void _addOrEditMedicine({DocumentSnapshot? document}) {
    final isEditing = document != null;
    final data = document?.data() as Map<String, dynamic>? ?? {};

    final nameController = TextEditingController(text: data['name'] ?? '');
    final genericNameController = TextEditingController(text: data['genericName'] ?? '');
    final typeController = TextEditingController(text: data['type'] ?? '');
    final manufacturerController = TextEditingController(text: data['manufacturer'] ?? '');
    final stockController = TextEditingController(text: data['stock']?.toString() ?? '0');
    final minStockController = TextEditingController(text: data['minStock']?.toString() ?? '10');
    final priceController = TextEditingController(text: data['price']?.toString() ?? '');
    final usesController = TextEditingController(text: data['uses'] ?? '');
    final dosageController = TextEditingController(text: data['dosage'] ?? '');
    final sideEffectsController = TextEditingController(
        text: data['side_effects'] ?? data['sideEffects'] ?? ''
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEditing ? "Edit Medicine" : "Add New Medicine"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFormField("Medicine Name*", nameController),
              _buildFormField("Generic Name", genericNameController),
              _buildFormField("Type (Tablet/Syrup/etc)*", typeController),
              _buildFormField("Manufacturer*", manufacturerController),
              _buildNumberField("Current Stock*", stockController),
              _buildNumberField("Minimum Stock", minStockController),
              _buildNumberField("Price", priceController, isCurrency: true),
              _buildFormField("Uses/Indications", usesController),
              _buildFormField("Dosage Instructions", dosageController),
              _buildFormField("Side Effects", sideEffectsController),
            ],
          ),
        ),
        actions: [
          Column(
            children: [
              FilledButton(
                onPressed: () async {
                  if (nameController.text.isEmpty ||
                      typeController.text.isEmpty ||
                      manufacturerController.text.isEmpty ||
                      stockController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all required fields (*)')),
                    );
                    return;
                  }

                  final medicineData = {
                    'name': nameController.text.trim(),
                    'genericName': genericNameController.text.trim(),
                    'type': typeController.text.trim(),
                    'manufacturer': manufacturerController.text.trim(),
                    'stock': int.tryParse(stockController.text) ?? 0,
                    'minStock': int.tryParse(minStockController.text) ?? 10,
                    'price': priceController.text.trim(),
                    'uses': usesController.text.trim(),
                    'dosage': dosageController.text.trim(),
                    'side_effects': sideEffectsController.text.trim(),
                    'updatedAt': FieldValue.serverTimestamp(),
                  };

                  try {
                    final collection = FirebaseFirestore.instance.collection('medicines');
                    if (isEditing) {
                      await collection.doc(document.id).update(medicineData);
                    } else {
                      await collection.add(medicineData);
                    }
                    Navigator.pop(context);
                    _refreshData();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                },
                child: Text(isEditing ? "Update" : "Add"),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color_codes.meddle),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildNumberField(String label, TextEditingController controller,
      {bool isCurrency = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color_codes.meddle),
          border: const OutlineInputBorder(),
          prefix: isCurrency ? const Text('\$') : null,
        ),
      ),
    );
  }

  Future<void> _deleteMedicine(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this medicine?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance.collection('medicines').doc(id).delete();
      _refreshData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicine deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}