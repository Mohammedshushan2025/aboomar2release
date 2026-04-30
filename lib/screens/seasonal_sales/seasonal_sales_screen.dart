/*
import 'package:aboomar/screens/home/widgets/date_filter_chips.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aboomar/app_localizations.dart';
import 'package:aboomar/models/group_category_model.dart';
import 'package:aboomar/models/seasonal_sales_model.dart';
import 'package:aboomar/services/api_service.dart';
import 'package:aboomar/main.dart';
import 'dart:io';

import 'widgets/category_filter_widget.dart';
import 'widgets/sales_data_table.dart';
import 'widgets/grand_total_card.dart';
import 'pdf_generator.dart';

class SeasonalSalesScreen extends StatefulWidget {
  final DateTime initialDate;
  const SeasonalSalesScreen({super.key, required this.initialDate});

  @override
  State<SeasonalSalesScreen> createState() => _SeasonalSalesScreenState();
}

class _SeasonalSalesScreenState extends State<SeasonalSalesScreen> {
  final ApiService _apiService = ApiService();
  late DateTime _selectedDate;

  // متغيرات جديدة لإدارة الحالة
  bool _isLoadingCategories = true; // <-- لإدارة تحميل التصنيفات فقط
  bool _isTableLoading = false; // <-- لإدارة تحميل الجدول فقط
  String? _errorMessage;
  bool _hasNetworkError = false;
  bool _hasInitialized = false;

  List<GroupCategory> _categories = [];
  int? _selectedCategoryCode;
  List<SeasonalSalesData> _salesData = []; // <-- لتخزين بيانات الجدول الحالية



  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      _fetchCategories(); // <-- نحمل التصنيفات بعد اكتمال البناء
    }
  }

  // فحص الاتصال بالإنترنت
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // عرض رسالة خطأ الإنترنت
  void _showNetworkErrorSnackBar(AppLocalizations l) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l.translate('no_internet_connection') ?? 'لا يوجد اتصال بالإنترنت',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // دالة لجلب التصنيفات مع معالجة أخطاء الإنترنت
  Future<void> _fetchCategories() async {
    if (!mounted) return;

    final l = AppLocalizations.of(context)!;

    // فحص الاتصال أولاً
    final hasInternet = await _checkInternetConnection();
    if (!hasInternet) {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
          _hasNetworkError = true;
          _errorMessage = l.translate('no_internet_connection') ?? 'لا يوجد اتصال بالإنترنت';
        });
        _showNetworkErrorSnackBar(l);
      }
      return;
    }

    setState(() {
      _isLoadingCategories = true;
      _errorMessage = null;
      _hasNetworkError = false;
    });

    try {
      final categories = await _apiService.getGroupCategories();
      if (!mounted) return;

      setState(() {
        _categories = categories;
        if (categories.isNotEmpty) {
          // نحدد أول تصنيف ونحمل بياناته تلقائياً
          _onCategoryChanged(categories.first.code);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasNetworkError = true;
        _errorMessage = _getErrorMessage(e, l);
      });
      _showNetworkErrorSnackBar(l);
    } finally {
      if (mounted) setState(() => _isLoadingCategories = false);
    }
  }

  // دالة لجلب بيانات المبيعات للتصنيف والتاريخ المحددين مع معالجة أخطاء الإنترنت
  Future<void> _fetchSalesData() async {
    if (_selectedCategoryCode == null) return;
    if (!mounted) return;

    final l = AppLocalizations.of(context)!;

    // فحص الاتصال أولاً
    final hasInternet = await _checkInternetConnection();
    if (!hasInternet) {
      if (mounted) {
        setState(() {
          _isTableLoading = false;
          _hasNetworkError = true;
          _errorMessage = l.translate('no_internet_connection') ?? 'لا يوجد اتصال بالإنترنت';
        });
        _showNetworkErrorSnackBar(l);
      }
      return;
    }

    setState(() {
      _isTableLoading = true; // <-- عرض علامة التحميل على الجدول
      _errorMessage = null;
      _hasNetworkError = false;
      _salesData = []; // تفريغ البيانات القديمة
    });

    try {
      final sales = await _apiService.getSeasonalSales(
        date: _selectedDate,
        categoryCode: _selectedCategoryCode!,
      );
      if (!mounted) return;
      setState(() {
        _salesData = sales;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasNetworkError = true;
        _errorMessage = _getErrorMessage(e, l);
      });
      _showNetworkErrorSnackBar(l);
    } finally {
      if (mounted) setState(() => _isTableLoading = false);
    }
  }

  // الحصول على رسالة خطأ مناسبة
  String _getErrorMessage(dynamic error, AppLocalizations l) {
    if (error is SocketException) {
      return l.translate('no_internet_connection') ?? 'لا يوجد اتصال بالإنترنت';
    }
    return l.translate('error_fetching_data') ?? 'خطأ في جلب البيانات';
  }

  // دالة السحب للتحديث مع معالجة أخطاء الإنترنت
  Future<void> _handleRefresh() async {
    final l = AppLocalizations.of(context)!;

    // فحص الاتصال أولاً
    final hasInternet = await _checkInternetConnection();
    if (!hasInternet) {
      _showNetworkErrorSnackBar(l);
      return;
    }

    // عند التحديث، نحمل التصنيفات وبيانات التصنيف المحدد حالياً
    await _fetchCategories();
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    _fetchSalesData(); // <-- إعادة تحميل بيانات الجدول عند تغيير التاريخ
  }

  void _onCategoryChanged(int newCategoryCode) {
    setState(() {
      _selectedCategoryCode = newCategoryCode;
    });
    _fetchSalesData(); // <-- إعادة تحميل بيانات الجدول عند تغيير التصنيف
  }

  Future<void> _showDetailsDialog(SeasonalSalesData data) {
    // ... (هذه الدالة تبقى كما هي بدون تغيير)
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _SalesDetailsDialog(data: data);
      },
    );
  }

  // شاشة التحميل المخصصة
  Widget _buildCustomLoadingScreen(AppLocalizations l) {
    return Container(
      color: const Color(0xFFF4F7FC),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // شكل دائري يحتوي على رمز التحميل
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // النص على سطرين
            Text(
               'جاري تحميل الأرصدة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
               'برجاء الانتظار قليلاً',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // شاشة خطأ الإنترنت
  Widget _buildNetworkErrorScreen(AppLocalizations l) {
    return Container(
      color: const Color(0xFFF4F7FC),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              l.translate('no_internet_connection') ?? 'لا يوجد اتصال بالإنترنت',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l.translate('check_connection_and_retry') ?? 'تحقق من اتصالك بالإنترنت وأعد المحاولة',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _handleRefresh,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text(
                l.translate('retry') ?? 'إعادة المحاولة',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    // حساب الإجماليات
    final double totalQuantity = _salesData.fold(0, (sum, item) => sum + item.quantity);
    final double totalSales = _salesData.fold(0, (sum, item) => sum + item.totalCost);
    final double totalBalance = _salesData.fold(0, (sum, item) => sum + item.balance);

    return Scaffold(
      appBar: AppBar(
        // ... (كود الـ AppBar يبقى كما هو)
        title: Text(l.translate("seasonal_sales_categories"),style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined, color: Colors.white),
            onPressed: (_salesData.isNotEmpty && !_hasNetworkError)
                ? () {
              final selectedCategoryName = _categories
                  .firstWhere((c) => c.code == _selectedCategoryCode, orElse: () => GroupCategory(code: 0, name: ''))
                  .name;
              SeasonalSalesPdfGenerator.generate(
                context: context,
                salesData: _salesData,
                date: _selectedDate,
                categoryName: selectedCategoryName,
              );
            }
                : null,
            tooltip: l.translate('download_pdf'),
          ),
          IconButton(
            icon: const Icon(Icons.language_outlined, color: Colors.white),
            onPressed: () {
              final locale = Localizations.localeOf(context).languageCode;
              final newLocale = locale == 'en' ? const Locale('ar', '') : const Locale('en', '');
              MyApp.of(context)?.changeLanguage(newLocale);
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF4F7FC),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _isLoadingCategories
            ? _buildCustomLoadingScreen(l)
            : _hasNetworkError && _categories.isEmpty
            ? _buildNetworkErrorScreen(l)
            : Column( // <-- الهيكل الجديد: Column
          children: [
            // الجزء العلوي الثابت (الفلاتر)
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 8.0),
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
            const SizedBox(height: 8),

            // الجزء الأوسط القابل للسكرول (الجدول)
            Expanded( // <-- الجدول يأخذ كل المساحة المتبقية
              child: _isTableLoading
                  ? _buildCustomLoadingScreen(l)
                  : _hasNetworkError && _salesData.isEmpty
                  ? _buildNetworkErrorScreen(l)
                  : _salesData.isEmpty
                  ? Center(child: Text(l.translate("no_data_available")))
                  : SalesDataTable(
                salesData: _salesData,
                onRowTap: _showDetailsDialog,
              ),
            ),

            // الجزء السفلي الثابت (الإجماليات)
            if (_salesData.isNotEmpty && !_hasNetworkError)
              GrandTotalCard(
                totalQuantity: totalQuantity,
                totalSales: totalSales,
                totalBalance: totalBalance,
              ),
          ],
        ),
      ),
    );
  }
}

// ... كود الديلوج (_SalesDetailsDialog) يبقى كما هو في نهاية الملف
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
          mainAxisSize: MainAxisSize.min, // لجعل الديلوج يأخذ أصغر ارتفاع ممكن
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.storefront, color: Theme.of(context).primaryColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data.branchName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            // Details
            _buildDetailRow(l.translate('quantity'), formatter.format(data.quantity)),
            const SizedBox(height: 12),
            _buildDetailRow(l.translate('total_sales'), formatter.format(data.totalCost)),
            const SizedBox(height: 12),
            _buildDetailRow(l.translate('balance'), formatter.format(data.balance)),
            const SizedBox(height: 24),
            // Close Button
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
                  "إغلاق", // تم تعديلها لتكون كلمة واضحة
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }
}

 */
// مسار الملف: lib/screens/seasonal_sales/seasonal_sales_screen.dart
import 'package:aboomar2release/screens/home/widgets/date_filter_chips.dart';
import 'package:aboomar2release/services/api_exceptions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aboomar2release/app_localizations.dart';
import 'package:aboomar2release/models/group_category_model.dart';
import 'package:aboomar2release/models/seasonal_sales_model.dart';
import 'package:aboomar2release/services/api_service.dart';
import 'package:aboomar2release/main.dart';
import 'widgets/category_filter_widget.dart';
import 'widgets/sales_data_table.dart';
import 'widgets/grand_total_card.dart';
import 'pdf_generator.dart';

class SeasonalSalesScreen extends StatefulWidget {
  final DateTime initialDate;
  const SeasonalSalesScreen({super.key, required this.initialDate});

  @override
  State<SeasonalSalesScreen> createState() => _SeasonalSalesScreenState();
}

class _SeasonalSalesScreenState extends State<SeasonalSalesScreen> {
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
      final categories = await _apiService.getGroupCategories();
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
      final sales = await _apiService.getSeasonalSales(
        date: _selectedDate,
        categoryCode: _selectedCategoryCode!,
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
        title: Text(l.translate("seasonal_sales_categories"),style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined,color: Colors.white),
            onPressed: (_salesData.isNotEmpty && _apiException == null)
                ? () {
              final selectedCategoryName = _categories
                  .firstWhere((c) => c.code == _selectedCategoryCode, orElse: () => GroupCategory(code: 0, name: ''))
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
              final newLocale = locale == 'en' ? const Locale('ar', '') : const Locale('en', '');
              MyApp.of(context)?.changeLanguage(newLocale);
            },
          ),
          // ... other actions
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
      return Center(child: Text(l.translate("no_data_available")));
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
            onPressed: _handleRefresh,
            icon: const Icon(Icons.refresh),
            label: Text(localizations.translate('retry')),
          ),
        ],
      ),
    );
  }

  // ... باقي الكود الخاص بـ _showDetailsDialog والدوال المساعدة الأخرى يبقى كما هو ...
  Future<void> _showDetailsDialog(SeasonalSalesData data) {
    // ... (هذه الدالة تبقى كما هي بدون تغيير)
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _SalesDetailsDialog(data: data);
      },
    );
  }
}

// ... كود الديلوج (_SalesDetailsDialog) يبقى كما هو في نهاية الملف
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
          mainAxisSize: MainAxisSize.min, // لجعل الديلوج يأخذ أصغر ارتفاع ممكن
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.storefront, color: Theme.of(context).primaryColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data.branchName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            // Details
            _buildDetailRow(l.translate('quantity'), formatter.format(data.quantity)),
            const SizedBox(height: 12),
            _buildDetailRow(l.translate('total_sales'), formatter.format(data.totalCost)),
            const SizedBox(height: 12),
            _buildDetailRow(l.translate('balance'), formatter.format(data.balance)),
            const SizedBox(height: 24),
            // Close Button
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
                  "إغلاق", // تم تعديلها لتكون كلمة واضحة
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }
}