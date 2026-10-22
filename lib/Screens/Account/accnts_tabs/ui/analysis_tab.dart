import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:century_cqg/Helper/nerve_base.dart';
import 'package:century_cqg/Screens/Account/model/account_model.dart';
import 'package:century_cqg/Screens/Account/accnts_tabs/model/analysis_model.dart';
import 'package:century_cqg/Screens/Account/accnts_tabs/service/accnts_tab_service.dart';
import 'package:century_cqg/Screens/Dashboard/service/dasboard_service.dart';

class AnalysisTab extends StatelessWidget {
  const AnalysisTab({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<DashboardService>();
    final isDarkMode = NerveBase().isDarkMode;

    return Consumer<AccntsTabService>(
      builder: (context, analysisService, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            performanceChartView(isDarkMode, analysisService),
            const SizedBox(height: 12),

            performanceStatsView(isDarkMode, context, analysisService),
            const SizedBox(height: 12),
            tradesCalendarView(context, isDarkMode, analysisService),
          ],
        );
      },
    );
  }

  Future<void> selectMonthAndYear(
    BuildContext context,
    bool isDarkMode,
    AccntsTabService analysisService,
  ) async {
    analysisService.initDialogMonthYear();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final dialogColor = isDarkMode ? const Color(0xFF141A16) : Colors.white;
        final textColor = isDarkMode ? Colors.white : const Color(0xFF454A54);

        return Consumer<AccntsTabService>(
          builder: (context, service, _) {
            return AlertDialog(
              backgroundColor: dialogColor,
              title: Text(
                'Select month and year',
                style: TextStyle(color: textColor, fontSize: 18),
              ),
              content: Row(
                children: [
                  Expanded(
                    child: DropdownButton<int>(
                      value: service.dialogSelectedMonth,
                      isExpanded: true,
                      dropdownColor: dialogColor,
                      style: TextStyle(color: textColor),
                      items: List.generate(
                        12,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text(service.monthName(index + 1)),
                        ),
                      ),
                      onChanged: (month) {
                        if (month != null) {
                          service.setDialogSelectedMonth(month);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButton<int>(
                      value: service.dialogSelectedYear,
                      isExpanded: true,
                      dropdownColor: dialogColor,
                      style: TextStyle(color: textColor),
                      items: [
                        for (
                          var year = AccntsTabService.firstCalendarMonth.year;
                          year <= AccntsTabService.lastCalendarMonth.year;
                          year++
                        )
                          DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          ),
                      ],
                      onChanged: (year) {
                        if (year != null) {
                          service.setDialogSelectedYear(year);
                        }
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    service.applyDialogMonthYear();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> showPerformanceFilterBottomSheet(
    BuildContext context,
    bool isDarkMode,
  ) async {
    final marketImpactOptions = AccntsTabService.marketImpactOptions;
    final timeOptions = AccntsTabService.timeOptions;
    const int customTimeIndex = 5;
    final customRangeController = TextEditingController();
    final customRangeFocusNode = FocusNode();
    final customFieldKey = GlobalKey();

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          final panelColor =
              isDarkMode ? const Color(0xFF0D110F) : Colors.white;
          final titleColor =
              isDarkMode ? Colors.white : const Color(0xFF454A54);
          final subtitleColor =
              isDarkMode ? const Color(0xFF9AA3B2) : const Color(0xFF6D726F);
          final chipBackground =
              isDarkMode ? const Color(0xFF1D2321) : const Color(0xFFF5F6F8);

          return Consumer<AccntsTabService>(
            builder: (context, service, _) {
              final selectedMarketImpact = service.selectedMarketImpact;
              final selectedTime = service.selectedTime;

              return SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 12, 15, 16),
                      decoration: BoxDecoration(
                        color: panelColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 40,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5D636F),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Filters',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w500,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Market Impact',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: subtitleColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: List.generate(
                                marketImpactOptions.length,
                                (index) {
                                  final isSelected =
                                      selectedMarketImpact == index;
                                  return filterChip(
                                    label: marketImpactOptions[index],
                                    isSelected: isSelected,
                                    isDarkMode: isDarkMode,
                                    chipBackground: chipBackground,
                                    onTap: () {
                                      service.setSelectedMarketImpact(index);
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Time',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: subtitleColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: List.generate(timeOptions.length, (
                                index,
                              ) {
                                final isSelected = selectedTime == index;
                                return filterChip(
                                  label: timeOptions[index],
                                  isSelected: isSelected,
                                  isDarkMode: isDarkMode,
                                  chipBackground: chipBackground,
                                  onTap: () {
                                    service.setSelectedTime(index);

                                    if (index == customTimeIndex) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            customRangeFocusNode.requestFocus();
                                            final fieldContext =
                                                customFieldKey.currentContext;
                                            if (fieldContext != null) {
                                              Scrollable.ensureVisible(
                                                fieldContext,
                                                duration: const Duration(
                                                  milliseconds: 180,
                                                ),
                                                curve: Curves.easeOut,
                                                alignment: 0.2,
                                              );
                                            }
                                          });
                                    }
                                  },
                                );
                              }),
                            ),
                            if (selectedTime == customTimeIndex) ...[
                              const SizedBox(height: 12),
                              Container(
                                key: customFieldKey,
                                child: TextField(
                                  controller: customRangeController,
                                  focusNode: customRangeFocusNode,
                                  autofocus: true,
                                  textInputAction: TextInputAction.done,
                                  scrollPadding: const EdgeInsets.only(
                                    bottom: 120,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Enter custom range',
                                    filled: true,
                                    fillColor: chipBackground,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: titleColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } finally {
      customRangeFocusNode.dispose();
      customRangeController.dispose();
    }
  }

  Widget filterChip({
    required String label,
    required bool isSelected,
    required bool isDarkMode,
    required Color chipBackground,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFC600) : chipBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color:
                isSelected
                    ? const Color(0xFF2A2A2A)
                    : (isDarkMode
                        ? const Color(0xFFD9DDE4)
                        : const Color(0xFF454A54)),
          ),
        ),
      ),
    );
  }

  Widget tradesCalendarView(
    BuildContext context,
    bool isDarkMode,
    AccntsTabService analysisService,
  ) {
    final weekDays = AccntsTabService.weekDays;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0D110F) : Colors.white,
        border: Border(
          top: BorderSide(
            color:
                isDarkMode ? const Color(0xFF202220) : const Color(0xFFF2F2F2),
            width: 1,
          ),
          bottom: BorderSide(
            color:
                isDarkMode ? const Color(0xFF202220) : const Color(0xFFF2F2F2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trades Calendar',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  height: 1,
                  letterSpacing: 0,
                  color: isDarkMode ? Colors.white : const Color(0xFF454A54),
                ),
              ),
              Row(
                children: [
                  calendarNavButton(
                    icon: Icons.chevron_left_rounded,
                    isDarkMode: isDarkMode,
                    isEnabled: analysisService.focusedDay.isAfter(
                      AccntsTabService.firstCalendarMonth,
                    ),
                    onTap: () => analysisService.previousMonth(),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap:
                        () => selectMonthAndYear(
                          context,
                          isDarkMode,
                          analysisService,
                        ),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                      child: Text(
                        '${analysisService.monthName(analysisService.focusedDay.month)} ${analysisService.focusedDay.year}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1,
                          letterSpacing: 0,
                          color:
                              isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF454A54),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  calendarNavButton(
                    icon: Icons.chevron_right_rounded,
                    isDarkMode: isDarkMode,
                    isEnabled: analysisService.focusedDay.isBefore(
                      AccntsTabService.lastCalendarMonth,
                    ),
                    onTap: () => analysisService.nextMonth(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children:
                weekDays
                    .map(
                      (day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              height: 1,
                              letterSpacing: 0,
                              color:
                                  isDarkMode
                                      ? const Color(0xFF9AA3B2)
                                      : const Color(0xFF8A93A3),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 12),
          TableCalendar<void>(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030, 12, 31),
            focusedDay: analysisService.focusedDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerVisible: false,
            daysOfWeekVisible: false,
            sixWeekMonthsEnforced: true,
            rowHeight: 58,
            calendarStyle: const CalendarStyle(
              cellMargin: EdgeInsets.zero,
              cellPadding: EdgeInsets.zero,
              outsideDaysVisible: true,
            ),
            calendarBuilders: CalendarBuilders<void>(
              defaultBuilder:
                  (context, day, focusedDay) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 3,
                    ),
                    child: calendarDayCell(
                      day: day,
                      status: analysisService.statusForDay(day),
                      isDarkMode: isDarkMode,
                    ),
                  ),
              todayBuilder:
                  (context, day, focusedDay) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 3,
                    ),
                    child: calendarDayCell(
                      day: day,
                      status: analysisService.statusForDay(day),
                      isDarkMode: isDarkMode,
                      isToday: true,
                    ),
                  ),
              outsideBuilder:
                  (context, day, focusedDay) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 3,
                    ),
                    child: calendarDayCell(
                      day: day,
                      status: null,
                      isDarkMode: isDarkMode,
                      isOutside: true,
                    ),
                  ),
            ),
            onPageChanged: (focusedDayParam) {
              analysisService.setFocusedDay(focusedDayParam);
            },
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 10,
            children: const [
              CalendarLegendDot(color: Color(0xFF20A16F), label: 'Winning day'),
              CalendarLegendDot(color: Color(0xFFF6465D), label: 'Losing day'),
              CalendarLegendDot(color: Color(0xFFE8EAF0), label: 'No trades'),
            ],
          ),
        ],
      ),
    );
  }

  Widget calendarNavButton({
    required IconData icon,
    required bool isDarkMode,
    required bool isEnabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isEnabled
                    ? (isDarkMode
                        ? const Color(0xFF303630)
                        : const Color(0xFFE5EAF0))
                    : (isDarkMode
                        ? const Color(0xFF202520)
                        : const Color(0xFFF2F3F5)),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color:
              isEnabled
                  ? (isDarkMode
                      ? const Color(0xFF9AA3B2)
                      : const Color(0xFF8A93A3))
                  : (isDarkMode
                      ? const Color(0xFF505850)
                      : const Color(0xFFB8BEC7)),
        ),
      ),
    );
  }

  Widget calendarDayCell({
    required DateTime day,
    required TradeDayStatus? status,
    required bool isDarkMode,
    bool isOutside = false,
    bool isToday = false,
  }) {
    final isWin = status == TradeDayStatus.win;
    final isLoss = status == TradeDayStatus.loss;
    final isNoTrade = status == TradeDayStatus.none;
    final isFuture = status == TradeDayStatus.future;

    final backgroundColor =
        isToday
            ? const Color(0xFFFFC600)
            : isFuture
            ? (isDarkMode ? const Color(0xFF252A33) : const Color(0xFFE8EAF0))
            : isWin
            ? const Color(0xFF20A16F)
            : isLoss
            ? const Color(0xFFF6465D)
            : (isDarkMode ? const Color(0xFF252A33) : const Color(0xFFE8EAF0));

    final dayTextColor =
        isWin || isLoss
            ? Colors.white
            : (isOutside
                ? const Color(0xFFC9CFDA)
                : (isDarkMode
                    ? const Color(0xFF9AA3B2)
                    : const Color(0xFF7D8798)));

    return Container(
      decoration: BoxDecoration(
        color: isOutside ? Colors.transparent : backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border:
            isOutside
                ? Border.all(
                  color:
                      isDarkMode
                          ? const Color(0xFF303630)
                          : const Color(0xFFDDE3EC),
                  width: 1,
                )
                : null,
      ),
      alignment: Alignment.center,
      child: Text(
        day.day.toString(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          fontSize: 16,
          height: 1,
          letterSpacing: 0,
          color:
              isToday
                  ? const Color(0xFF2A2A2A)
                  : isFuture
                  ? (isDarkMode
                      ? const Color(0xFF69727E)
                      : const Color(0xFF9CA3AF))
                  : (isNoTrade ? const Color(0xFF7D8798) : dayTextColor),
        ),
      ),
    );
  }

  Widget performanceStatsView(
    bool isDarkMode,
    BuildContext context,
    AccntsTabService analysisService,
  ) {
    final summaryCards = analysisService.getSummaryCards();
    final stats = analysisService.getPerformanceStats();

    return Container(
      width: double.infinity,
      color: isDarkMode ? const Color(0xFF0D110F) : Colors.white,
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    'Performance Stats',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          isDarkMode ? Colors.white : const Color(0xFF454A54),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '23/09/25 - 03/01/26',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color:
                          isDarkMode
                              ? const Color(0xFF9AA3B2)
                              : const Color(0xFF8D98A7),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  showPerformanceFilterBottomSheet(context, isDarkMode);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isDarkMode
                              ? const Color(0xFF303630)
                              : const Color(0xFFE5EAF0),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color:
                        isDarkMode
                            ? const Color(0xFF9AA3B2)
                            : const Color(0xFF8D98A7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(summaryCards.length, (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: (index == summaryCards.length - 1) ? 0 : 8,
                  ),
                  child: summaryCard(
                    item: summaryCards[index],
                    isDarkMode: isDarkMode,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.65,
              mainAxisSpacing: 10,
              crossAxisSpacing: 20,
            ),
            itemBuilder: (context, index) {
              final item = stats[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color:
                          isDarkMode
                              ? const Color(0xFF9AA3B2)
                              : const Color(0xFF7E828B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.value,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color:
                          item.valueColor ??
                          (isDarkMode ? Colors.white : const Color(0xFF3E4148)),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget performanceChartView(
    bool isDarkMode,
    AccntsTabService analysisService,
  ) {
    final chartData = analysisService.getPerformanceChartData();

    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
        width: 390,
        height: 298,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF0D110F) : Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Performance Chart',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : const Color(0xFF454A54),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode
                            ? const Color(0xFF141A16)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color:
                          isDarkMode
                              ? const Color(0xFF303630)
                              : const Color(0xFFE4E7EC),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Daily',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color:
                              isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF454A54),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color:
                            isDarkMode ? Colors.white : const Color(0xFF6A7280),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: BarChart(
                        BarChartData(
                          minY: 0,
                          maxY: 18,
                          barTouchData: BarTouchData(enabled: false),
                          alignment: BarChartAlignment.spaceAround,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 3,
                            getDrawingHorizontalLine:
                                (_) => FlLine(
                                  color:
                                      isDarkMode
                                          ? const Color(0xFF243029)
                                          : const Color(0xFFEFF2F6),
                                  strokeWidth: 1,
                                ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
                              bottom: BorderSide(
                                color:
                                    isDarkMode
                                        ? const Color(0xFF243029)
                                        : const Color(0xFFEEF1F5),
                                width: 1,
                              ),
                              left: const BorderSide(color: Colors.transparent),
                              right: const BorderSide(
                                color: Colors.transparent,
                              ),
                              top: const BorderSide(color: Colors.transparent),
                            ),
                          ),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 3,
                                reservedSize: 24,
                                getTitlesWidget:
                                    (value, meta) => Text(
                                      value.toInt().toString(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            isDarkMode
                                                ? const Color(0xFF9AA3B2)
                                                : const Color(0xFF8A93A3),
                                      ),
                                    ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < 0 || index >= chartData.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      chartData[index].day,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color:
                                            isDarkMode
                                                ? const Color(0xFF9AA3B2)
                                                : const Color(0xFF8A93A3),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: List.generate(chartData.length, (index) {
                            final point = chartData[index];
                            return BarChartGroupData(
                              x: index,
                              barsSpace: 6,
                              barRods: [
                                BarChartRodData(
                                  toY: point.winningTrades,
                                  width: 12,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                  color: const Color(0xFF2EBD85),
                                ),
                                BarChartRodData(
                                  toY: point.losingTrades,
                                  width: 12,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                  color: const Color(0xFFF6465D),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _chartLegendItem(
                        label: 'Winning Trades',
                        color: const Color(0xFF2EBD85),
                        isDarkMode: isDarkMode,
                      ),
                      const SizedBox(width: 20),
                      _chartLegendItem(
                        label: 'Losing Trades',
                        color: const Color(0xFFF6465D),
                        isDarkMode: isDarkMode,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget summaryCard({
    required SummaryCardData item,
    required bool isDarkMode,
  }) {
    return Container(
      width: double.infinity,
      height: 71,
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? item.darkBackground : item.lightBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w400,
              height: 1,
              letterSpacing: 0,
              color: item.valueColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1,
              letterSpacing: 0,
              color: item.valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _chartLegendItem({
  required String label,
  required Color color,
  required bool isDarkMode,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: isDarkMode ? const Color(0xFFB7C0CF) : const Color(0xFF7F8CA1),
        ),
      ),
    ],
  );
}

class CalendarLegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const CalendarLegendDot({
    super.key,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF7D8798),
          ),
        ),
      ],
    );
  }
}
