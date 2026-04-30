/*
import 'package:aboomar/widgets/home_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app_localizations.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';

// استيراد باقي الويدجتس
import 'widgets/daily_performance_widget.dart';
import 'widgets/top_branches_chart.dart';
import 'widgets/revenue_trend_chart.dart';
import 'widgets/home_action_cards.dart';
import 'widgets/date_filter_chips.dart';
import 'widgets/sales_pie_chart_widget.dart';
import 'widgets/sales_categories_chart.dart'; // إضافة جديدة

// استيراد النماذج
import '../../models/daily_summary_model.dart';
import '../../models/top_branch_model.dart';
import '../../models/revenue_day_model.dart';
import '../../models/sales_category_model.dart';

// enum لأنواع الأخطاء
enum ErrorType {
  network,
  server,
  timeout,
  unknown
}

// كلاس لمعلومات الخطأ
class ErrorInfo {
  final ErrorType type;
  final String userMessage;
  final String? technicalMessage;
  final IconData icon;
  final Color color;

  ErrorInfo({
    required this.type,
    required this.userMessage,
    this.technicalMessage,
    required this.icon,
    required this.color,
  });
}

class HomeScreen extends StatefulWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _dashboardData;
  final ApiService _apiService = ApiService();
  late DateTime _selectedDate;
  bool _isLoading = false;
  ErrorInfo? _errorInfo;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().subtract(const Duration(days: 1));
    _dashboardData = _fetchDashboardData();
  }

  // دالة لتحليل نوع الخطأ
  ErrorInfo _analyzeError(dynamic error) {
    String errorString = error.toString().toLowerCase();

    // فحص أخطاء الشبكة
    if (errorString.contains('network') ||
        errorString.contains('unreachable') ||
        errorString.contains('connection failed') ||
        errorString.contains('socketexception') ||
        errorString.contains('no internet') ||
        errorString.contains('connection refused') ||
        errorString.contains('network is unreachable')) {
      return ErrorInfo(
        type: ErrorType.network,
        userMessage: 'تعذر الاتصال بالإنترنت',
        technicalMessage: 'يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
        icon: Icons.wifi_off,
        color: Colors.orange,
      );
    }

    // فحص أخطاء انتهاء المهلة الزمنية
    if (errorString.contains('timeout') ||
        errorString.contains('timed out') ||
        errorString.contains('deadline exceeded')) {
      return ErrorInfo(
        type: ErrorType.timeout,
        userMessage: 'انتهت المهلة الزمنية للطلب',
        technicalMessage: 'استغرق الطلب وقتاً أطول من المتوقع، يرجى المحاولة مرة أخرى',
        icon: Icons.access_time,
        color: Colors.amber,
      );
    }

    // فحص أخطاء الخادم
    if (errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('server error') ||
        errorString.contains('internal server error')) {
      return ErrorInfo(
        type: ErrorType.server,
        userMessage: 'خطأ في الخادم',
        technicalMessage: 'يواجه الخادم مشكلة مؤقتة، يرجى المحاولة لاحقاً',
        icon: Icons.cloud_off,
        color: Colors.red,
      );
    }

    // خطأ غير معروف
    return ErrorInfo(
      type: ErrorType.unknown,
      userMessage: 'حدث خطأ غير متوقع',
      technicalMessage: 'يرجى المحاولة مرة أخرى أو الاتصال بالدعم الفني',
      icon: Icons.error_outline,
      color: Colors.red,
    );
  }

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    print('🔄 بدء تحميل البيانات للتاريخ: ${_formatDate(_selectedDate)}');

    setState(() {
      _isLoading = true;
      _errorInfo = null;
    });

    try {
      print('📡 استدعاء API للحصول على البيانات...');

      final results = await Future.wait([
        _apiService.getDailyPerformance(_selectedDate),
        _apiService.getTop5Branches(_selectedDate),
        _apiService.getRevenueLast7Days(),
        _apiService.getSalesCategories(_selectedDate),
        _apiService.getSalesCategoriesDetailed(_selectedDate), // إضافة جديدة
      ]);

      print('✅ تم تحميل البيانات بنجاح');
      print('📊 Daily Summary: ${results[0]}');
      print('🏪 Top Branches: ${(results[1] as List).length} branches');
      print('💰 Revenue Days: ${(results[2] as List).length} days');
      print('🥧 Sales Categories: ${(results[3] as List).length} categories');
      print('📈 Detailed Categories: ${(results[4] as List).length} categories'); // إضافة جديدة

      setState(() {
        _isLoading = false;
      });

      return {
        'dailySummary': results[0] as DailySummary,
        'topBranches': results[1] as List<TopBranch>,
        'revenue7Days': results[2] as List<RevenueDay>,
        'salesCategories': results[3] as List<SalesCategory>,
        'detailedCategories': results[4] as List<SalesCategory>, // إضافة جديدة
      };
    } catch (e) {
      print('❌ خطأ في تحميل البيانات: $e');

      final errorInfo = _analyzeError(e);

      setState(() {
        _isLoading = false;
        _errorInfo = errorInfo;
      });

      rethrow;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  void _onDateChanged(DateTime newDate) {
    print('📅 تغيير التاريخ إلى: ${_formatDate(newDate)}');
    setState(() {
      _selectedDate = newDate;
      _dashboardData = _fetchDashboardData();
    });
  }

  // دالة خاصة بمعالجة السحب للتحديث
  Future<void> _handleRefresh() async {
    print('🔄 تحديث البيانات عبر السحب...');
    setState(() {
      _dashboardData = _fetchDashboardData();
    });
    await _dashboardData;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          slivers: [
            HomeAppBar(user: widget.user),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                child: DateFilterChips(
                  selectedDate: _selectedDate,
                  onDateSelected: _onDateChanged,
                  locale: locale,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _dashboardData,
                builder: (context, snapshot) {
                  print('🔍 FutureBuilder State:');
                  print('  - ConnectionState: ${snapshot.connectionState}');
                  print('  - HasData: ${snapshot.hasData}');
                  print('  - HasError: ${snapshot.hasError}');
                  print('  - Error: ${snapshot.error}');
                  print('  - Loading: $_isLoading');

                  if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
                    print('⏳ عرض حالة التحميل');
                    return _buildLoadingState();
                  }

                  if (snapshot.hasError || _errorInfo != null) {
                    print('❌ عرض حالة الخطأ: ${snapshot.error ?? _errorInfo?.userMessage}');
                    return _buildErrorState(context, _errorInfo ?? _analyzeError(snapshot.error));
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    print('📭 عرض حالة عدم وجود بيانات');
                    return _buildNoDataState(context);
                  }

                  print('✅ عرض البيانات بنجاح');
                  return _buildSuccessState(context, snapshot.data!);
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  // ويدجت حالة التحميل
  Widget _buildLoadingState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'جاري تحميل البيانات...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'يرجى الانتظار قليلاً',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت حالة الخطأ المحسن
  Widget _buildErrorState(BuildContext context, ErrorInfo errorInfo) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: errorInfo.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              errorInfo.icon,
              color: errorInfo.color,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            errorInfo.userMessage,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: errorInfo.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            errorInfo.technicalMessage ?? 'يرجى المحاولة مرة أخرى',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    print('🔄 إعادة المحاولة...');
                    setState(() {
                      _dashboardData = _fetchDashboardData();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              if (errorInfo.type == ErrorType.network) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // يمكن إضافة دالة لفتح إعدادات الشبكة
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('يرجى التحقق من إعدادات الإنترنت في جهازك'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('الإعدادات'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ويدجت حالة عدم وجود بيانات
  Widget _buildNoDataState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.inbox_outlined,
              color: Colors.grey,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد بيانات',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لا توجد بيانات متاحة للتاريخ المحدد: ${_formatDate(_selectedDate)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now().subtract(const Duration(days: 1));
                _dashboardData = _fetchDashboardData();
              });
            },
            icon: const Icon(Icons.today),
            label: const Text('العودة لأمس'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت حالة نجاح التحميل
  Widget _buildSuccessState(BuildContext context, Map<String, dynamic> data) {
    final DailySummary dailySummary = data['dailySummary'];
    final List<TopBranch> topBranches = data['topBranches'];
    final List<RevenueDay> revenue7Days = data['revenue7Days'];
    final List<SalesCategory> salesCategories = data['salesCategories'];
    final List<SalesCategory> detailedCategories = data['detailedCategories']; // إضافة جديدة

    final bool hideRevenue = widget.user.hideRevenueFlag == 1;
    final bool hideSalesDetails = widget.user.hideSalesDetailsFlag == 1;
    final bool hideSeasonSales = widget.user.hideSeasonSalesFlag == 1;

    print("====== حالة عرض مكونات الشاشة الرئيسية للمستخدم (${widget.user.usersCode}) ======");
    print("قيمة hideRevenueFlag من الموديل: ${widget.user.hideRevenueFlag}");
    print("قيمة hideSalesDetailsFlag من الموديل: ${widget.user.hideSalesDetailsFlag}");
    print("قيمة hideSeasonSalesFlag من الموديل: ${widget.user.hideSeasonSalesFlag}");
    print("-----------------------------------------------------");
    print("- إخفاء بيانات الإيرادات (hideRevenue): $hideRevenue");
    print("- إخفاء تفاصيل المبيعات (hideSalesDetails): $hideSalesDetails");
    print("- إخفاء مبيعات الموسم الإجمالي (hideSeasonSales): $hideSeasonSales");
    print("=======================================================================");

    return Column(
      children: [
        // مؤشر الأداء اليومي
        DailyPerformanceWidget(
          summary: dailySummary,
          hideRevenue: hideRevenue,
        ),

        // أعلى 5 فروع
        if (!hideRevenue && topBranches.isNotEmpty)
          TopBranchesChart(branches: topBranches),

        // تطور الإيراد
        if (!hideRevenue && revenue7Days.isNotEmpty)
          RevenueTrendChart(revenues: revenue7Days),

        // الشكل البياني الدائري لإجمالي المبيعات
        if (!hideSalesDetails && salesCategories.isNotEmpty)
          SalesPieChartWidget(categories: salesCategories),

        // الرسم البياني الجديد لمبيعات وكميات التصنيفات - إضافة جديدة
        if (!hideSalesDetails && detailedCategories.isNotEmpty)
          SalesCategoriesChart(categories: detailedCategories),

        // كروت الإجراءات
        HomeActionCards(
          selectedDate: _selectedDate,
          hideRevenueCard: hideRevenue,
          hideSalesDetailsCard: hideSalesDetails,
          hideSeasonSalesCard: hideSeasonSales,
        ),
      ],
    );
  }
}
*/
// مسار الملف: lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app_localizations.dart';
import '../../models/user_model.dart';
import '../../services/api_exceptions.dart';
import '../../services/api_service.dart';
import '../../widgets/home_app_bar.dart';
import 'widgets/daily_performance_widget.dart';
import 'widgets/top_branches_chart.dart';
import 'widgets/revenue_trend_chart.dart';
import 'widgets/home_action_cards.dart';
import 'widgets/date_filter_chips.dart';
import 'widgets/sales_pie_chart_widget.dart';
import 'widgets/sales_categories_chart.dart';
import '../../models/daily_summary_model.dart';
import '../../models/top_branch_model.dart';
import '../../models/revenue_day_model.dart';
import '../../models/sales_category_model.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _dashboardData;
  final ApiService _apiService = ApiService();
  late DateTime _selectedDate;
  bool _isLoading = false;
  ApiException? _apiException; // <-- استخدام النوع المخصص

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    //.subtract(const Duration(days: 1))
    _dashboardData = _fetchDashboardData();
  }

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _apiException = null;
    });

    try {
      final results = await Future.wait([
        _apiService.getDailyPerformance(_selectedDate),
        _apiService.getTop5Branches(_selectedDate),
        _apiService.getRevenueLast7Days(),
        _apiService.getSalesCategories(_selectedDate),
        _apiService.getSalesCategoriesDetailed(_selectedDate),
      ]);

      setState(() => _isLoading = false);

      return {
        'dailySummary': results[0] as DailySummary,
        'topBranches': results[1] as List<TopBranch>,
        'revenue7Days': results[2] as List<RevenueDay>,
        'salesCategories': results[3] as List<SalesCategory>,
        'detailedCategories': results[4] as List<SalesCategory>,
      };
    } on ApiException catch (e) {
      setState(() {
        _isLoading = false;
        _apiException = e;
      });
      rethrow;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      _dashboardData = _fetchDashboardData();
    });
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _dashboardData = _fetchDashboardData();
    });
    await _dashboardData;
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          slivers: [
            HomeAppBar(user: widget.user),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 16.0,
                  left: 16.0,
                  right: 16.0,
                ),
                child: DateFilterChips(
                  selectedDate: _selectedDate,
                  onDateSelected: _onDateChanged,
                  locale: locale,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _dashboardData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      _isLoading) {
                    return _buildLoadingState();
                  }
                  if (snapshot.hasError || _apiException != null) {
                    final error =
                        _apiException ??
                        ApiException(snapshot.error.toString());
                    return _buildErrorState(context, error);
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return _buildNoDataState(context);
                  }
                  return _buildSuccessState(context, snapshot.data!);
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ApiException error) {
    final localizations = AppLocalizations.of(context)!;
    final isNetworkError = error is NoInternetException;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            isNetworkError ? Icons.wifi_off : Icons.cloud_off,
            color: isNetworkError ? Colors.orange : Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            localizations.translate(error.toString()),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isNetworkError ? Colors.orange : Colors.red,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleRefresh,
              icon: const Icon(Icons.refresh),
              label: Text(localizations.translate('retry')),
            ),
          ),
        ],
      ),
    );
  }

  // ... باقي الويدجتس (_buildLoadingState, _buildNoDataState, _buildSuccessState) تبقى كما هي ...
  // ويدجت حالة التحميل
  Widget _buildLoadingState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'جاري تحميل البيانات...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'يرجى الانتظار قليلاً',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت حالة عدم وجود بيانات
  Widget _buildNoDataState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.inbox_outlined,
              color: Colors.grey,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد بيانات',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لا توجد بيانات متاحة للتاريخ المحدد: ${_formatDate(_selectedDate)}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ويدجت حالة نجاح التحميل
  Widget _buildSuccessState(BuildContext context, Map<String, dynamic> data) {
    final DailySummary dailySummary = data['dailySummary'];
    final List<TopBranch> topBranches = data['topBranches'];
    final List<RevenueDay> revenue7Days = data['revenue7Days'];
    final List<SalesCategory> salesCategories = data['salesCategories'];
    final List<SalesCategory> detailedCategories =
        data['detailedCategories']; // إضافة جديدة

    final bool hideRevenue = widget.user.hideRevenueFlag == 1;
    final bool hideSalesDetails = widget.user.hideSalesDetailsFlag == 1;
    final bool hideSeasonSales = widget.user.hideSeasonSalesFlag == 1;

    print(
      "====== حالة عرض مكونات الشاشة الرئيسية للمستخدم (${widget.user.usersCode}) ======",
    );
    print("- إخفاء بيانات الإيرادات (hideRevenue): $hideRevenue");
    print("- إخفاء تفاصيل المبيعات (hideSalesDetails): $hideSalesDetails");
    print("- إخفاء مبيعات الموسم (hideSeasonSales): $hideSeasonSales");
    print(
      "=======================================================================",
    );

    return Column(
      children: [
        // مؤشر الأداء اليومي
        DailyPerformanceWidget(summary: dailySummary, hideRevenue: hideRevenue),

        // أعلى 5 فروع
        if (!hideRevenue && topBranches.isNotEmpty)
          TopBranchesChart(branches: topBranches),

        // تطور الإيراد
        if (!hideRevenue && revenue7Days.isNotEmpty)
          RevenueTrendChart(revenues: revenue7Days),

        // الشكل البياني الدائري لإجمالي المبيعات
        if (!hideSalesDetails && salesCategories.isNotEmpty)
          SalesPieChartWidget(categories: salesCategories),

        // الرسم البياني الجديد لمبيعات وكميات التصنيفات - إضافة جديدة
        if (!hideSalesDetails && detailedCategories.isNotEmpty)
          SalesCategoriesChart(categories: detailedCategories),

        // كروت الإجراءات
        HomeActionCards(
          selectedDate: _selectedDate,
          hideRevenueCard: hideRevenue,
          hideSalesDetailsCard: hideSalesDetails,
          hideSeasonSalesCard: hideSeasonSales,
        ),
      ],
    );
  }
}
