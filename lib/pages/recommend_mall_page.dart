import 'package:flutter/material.dart';

// ==================== 宠物友好商场推荐表单 ====================
class RecommendMallPage extends StatefulWidget {
  const RecommendMallPage({super.key});
  @override
  State<RecommendMallPage> createState() => _RecommendMallPageState();
}

class _RecommendMallPageState extends State<RecommendMallPage> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _reasonController = TextEditingController();
  String _selectedCity = '杭州';
  
  void _submit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('推荐成功，感谢您的贡献！')),
    );
    Navigator.pop(context);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('推荐商场', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text('发布', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('基本信息', [
            _buildTextField('商场名称', _nameController, '请输入商场名称'),
            _buildTextField('详细地址', _addressController, '请输入详细地址'),
            _buildTextField('联系电话', _phoneController, '请输入联系电话'),
          ]),
          const SizedBox(height: 20),
          _buildSection('推荐理由', [
            _buildTextField('推荐理由', _reasonController, '请描述为什么推荐这个商场', maxLines: 4),
          ]),
          const SizedBox(height: 20),
          _buildSection('所在城市', [
            Wrap(
              spacing: 12,
              children: [
                _buildCityChip('杭州'),
                _buildCityChip('南京'),
              ],
            ),
          ]),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: 12),
                Expanded(
                  child: Text('提交后需要10人投票支持，达到5人支持后将展示在商场列表中', style: TextStyle(color: Colors.orange, fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
  
  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
  
  Widget _buildCityChip(String city) {
    final selected = _selectedCity == city;
    return GestureDetector(
      onTap: () => setState(() => _selectedCity = city),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE91E63) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(city, style: TextStyle(color: selected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
