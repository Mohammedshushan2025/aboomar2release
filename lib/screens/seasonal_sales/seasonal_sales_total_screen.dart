import 'package:aboomar2release/screens/home/widgets/date_filter_chips.dart';
import 'package:aboomar2release/services/api_exceptions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aboomar2release/app_localizations.dart';
import 'package:aboomar2release/models/group_category_model.dart';
import 'package:aboomar2release/models/seasonal_sales_model.dart';
import 'package:aboomar2release/services/api_service.dart';
import 'package:aboomar2release/main.dart';
import '../seasonal_sales/widgets/category_filter_widget.dart';
import '../seasonal_sales/widgets/sales_data_table.dart';
import '../seasonal_sales/widgets/grand_total_card.dart';
import '../seasonal_sales/pdf_generator.dart';

class SeasonalSalesTotalScreen extends StatefulWidget {
  final DateTime initialDate;
  const SeasonalSalesTotalScreen({super.key, required this.initialDate});

  @override
  State<SeasonalSalesTotalScreen> createState() => _SeasonalSalesTotalScreenState();
}

class _SeasonalSalesTotalScreenState extends State<SeasonalSalesTotalScreen> {
  final ApiService _apiService = ApiService();
  late DateTime _selectedDate;

  bool _isLoadingCategories = true;
  bool _isTableLoading = false;
  ApiException? _apiException;

  List<GroupCategory> _categories = [];
  int? _selectedCategoryCode;
  List<SeasonalSalesData> _salesData = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _apiException = null;
    });
    try {
      final categories = await _apiService.getGroupCategories2();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        if (categories.isNotEmpty) {
          _onCategoryChanged(categories.first.code);
        }
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _apiException = e);
    } finally {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _fetchSalesData() async {
    if (_selectedCategoryCode == null) return;
    setState(() {
      _isTableLoading = true;
      _apiException = null;
      _salesData = [];
    });
    try {
      final sales = await _apiService.getSeasonalSalesTotal(
        date: _selectedDate,
        kindCode: _selectedCategoryCode!,
      );
      if (!mounted) return;
      setState(() => _salesData = sales);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _apiException = e);
    } finally {
      if (mounted) setState(() => _isTableLoading = false);
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchCategories();
  }

  void _onDateChanged(DateTime newDate) {
    setState(() => _selectedDate = newDate);
    _fetchSalesData();
  }

  void _onCategoryChanged(int newCategoryCode) {
    setState(() => _selectedCategoryCode = newCategoryCode);
    _fetchSalesData();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.translate("seasonal_sales_total"),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined, color: Colors.white),
            onPressed: (_salesData.isNotEmpty && _apiException == null)
                ? () {
              final selectedCategoryName = _categories
                  .firstWhere(
                    (c) => c.code == _selectedCategoryCode,
                    orElse: () => GroupCategory(code: 0, name: ''),
                  )
                  .name;
              SeasonalSalesPdfGenerator.generate(
                context: context,
                salesData: _salesData,
                date: _selectedDate,
                categoryName: selectedCategoryName,
              );
            }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.language_outlined, color: Colors.white),
            onPressed: () {
              final locale = Localizations.localeOf(context).languageCode;
              final newLocale = locale == 'en'
                  ? const Locale('ar', '')
                  : const Locale('en', '');
              MyApp.of(context)?.changeLanguage(newLocale);
            },
          ),
        ],
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoadingCategories) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_apiException != null && _categories.isEmpty) {
      return _buildErrorWidget(context, _apiException!);
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: DateFilterChips(
            selectedDate: _selectedDate,
            onDateSelected: _onDateChanged,
            locale: Localizations.localeOf(context).languageCode,
          ),
        ),
        CategoryFilterWidget(
          categories: _categories,
          selectedCategoryCode: _selectedCategoryCode,
          onCategorySelected: _onCategoryChanged,
        ),
        Expanded(child: _buildTableArea(context)),
        if (_salesData.isNotEmpty && _apiException == null)
          GrandTotalCard(
            totalQuantity: _salesData.fold(0, (sum, item) => sum + item.quantity),
            totalSales: _salesData.fold(0, (sum, item) => sum + item.totalCost),
            totalBalance: _salesData.fold(0, (sum, item) => sum + item.balance),
          ),
      ],
    );
  }

  Widget _buildTableArea(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (_isTableLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_apiException != null && _salesData.isEmpty) {
      return _buildErrorWidget(context, _apiException!);
    }
    if (_salesData.isEmpty) {
      return Center(
        child: Text(
          l.translate("no_data_available"),
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return SalesDataTable(
      salesData: _salesData,
      onRowTap: _showDetailsDialog,
    );
  }

  Widget _buildErrorWidget(BuildContext context, ApiException error) {
    final localizations = AppLocalizations.of(context)!;
    final isNetworkError = error is NoInternetException;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isNetworkError ? Icons.wifi_off : Icons.cloud_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            localizations.translate(error.toString()),
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: _handleRefresh,
            icon: const Icon(Icons.refresh),
            label: Text(
              localizations.translate('retry'),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDetailsDialog(SeasonalSalesData data) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _SalesDetailsDialog(data: data);
      },
    );
  }
}

class _SalesDetailsDialog extends StatelessWidget {
  final SeasonalSalesData data;
  const _SalesDetailsDialog({required this.data});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final formatter = NumberFormat("#,##0.00", "en_US");

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.storefront,
                    color: Theme.of(context).primaryColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data.branchName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            _buildDetailRow(l.translate('quantity'), formatter.format(data.quantity)),
            const SizedBox(height: 12),
            _buildDetailRow(
                l.translate('total_sales'), formatter.format(data.totalCost)),
            const SizedBox(height: 12),
            _buildDetailRow(
                l.translate('balance'), formatter.format(data.balance)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  "إغلاق",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }
}
