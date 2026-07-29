import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class TimeSetting {
  String hour;
  String minute;
  String ampm;

  TimeSetting(this.hour, this.minute, this.ampm);
}

class DaySetting {
  String name;
  bool isOpen;
  TimeSetting openTime;
  TimeSetting closeTime;

  bool hasLunch;
  TimeSetting lunchStart;
  TimeSetting lunchEnd;

  bool hasBreak;
  TimeSetting breakStart;
  TimeSetting breakEnd;
  String? holidayReason;

  DaySetting({
    required this.name,
    this.isOpen = true,
    required this.openTime,
    required this.closeTime,
    this.hasLunch = false,
    required this.lunchStart,
    required this.lunchEnd,
    this.hasBreak = false,
    required this.breakStart,
    required this.breakEnd,
    this.holidayReason,
  });

  DaySetting clone() {
    return DaySetting(
      name: name,
      isOpen: isOpen,
      openTime: TimeSetting(openTime.hour, openTime.minute, openTime.ampm),
      closeTime: TimeSetting(closeTime.hour, closeTime.minute, closeTime.ampm),
      hasLunch: hasLunch,
      lunchStart: TimeSetting(
        lunchStart.hour,
        lunchStart.minute,
        lunchStart.ampm,
      ),
      lunchEnd: TimeSetting(lunchEnd.hour, lunchEnd.minute, lunchEnd.ampm),
      hasBreak: hasBreak,
      breakStart: TimeSetting(
        breakStart.hour,
        breakStart.minute,
        breakStart.ampm,
      ),
      breakEnd: TimeSetting(breakEnd.hour, breakEnd.minute, breakEnd.ampm),
      holidayReason: holidayReason,
    );
  }
}

class StoreOpeningHoursWidget extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onSave;

  const StoreOpeningHoursWidget({
    Key? key,
    required this.onBack,
    required this.onSave,
  }) : super(key: key);

  @override
  State<StoreOpeningHoursWidget> createState() =>
      _StoreOpeningHoursWidgetState();
}

class _StoreOpeningHoursWidgetState extends State<StoreOpeningHoursWidget> {
  bool _useSameHours = true;
  String? _lastSavedTime;

  late DaySetting _commonSetting;
  late List<DaySetting> _days;

  final List<String> _hours = List.generate(
    12,
    (index) => (index + 1).toString().padLeft(2, '0'),
  );
  final List<String> _minutes = List.generate(
    60,
    (index) => index.toString().padLeft(2, '0'),
  );
  final List<String> _ampm = ['AM', 'PM'];

  @override
  void initState() {
    super.initState();
    _commonSetting = _createDefaultDay('Common');
    _days = [
      _createDefaultDay('Mon'),
      _createDefaultDay('Tue'),
      _createDefaultDay('Wed'),
      _createDefaultDay('Thu'),
      _createDefaultDay('Fri'),
      _createDefaultDay('Sat'),
      _createDefaultDay('Sun'),
    ];
  }

  DaySetting _createDefaultDay(String name) {
    return DaySetting(
      name: name,
      openTime: TimeSetting('09', '00', 'AM'),
      closeTime: TimeSetting('09', '00', 'PM'),
      lunchStart: TimeSetting('01', '00', 'PM'),
      lunchEnd: TimeSetting('02', '00', 'PM'),
      breakStart: TimeSetting('04', '00', 'PM'),
      breakEnd: TimeSetting('04', '30', 'PM'),
    );
  }

  int get _openDaysCount => _days.where((day) => day.isOpen).length;

  String _formatTime(TimeSetting t) {
    int h = int.parse(t.hour);
    if (t.ampm == 'PM' && h != 12) h += 12;
    if (t.ampm == 'AM' && h == 12) h = 0;
    final hh = h.toString().padLeft(2, '0');
    return '$hh:${t.minute}:00';
  }

  Future<void> _saveToApi() async {
    FocusScope.of(context).unfocus();
    
    final Map<String, String> dayNames = {
      'Mon': 'Monday',
      'Tue': 'Tuesday',
      'Wed': 'Wednesday',
      'Thu': 'Thursday',
      'Fri': 'Friday',
      'Sat': 'Saturday',
      'Sun': 'Sunday',
    };

    final payload = {
      "user_main_id": null,
      "configuration_mode": _useSameHours ? "common" : "individual",
      "break": {
        "enabled": _commonSetting.hasBreak,
        "start": _commonSetting.hasBreak
            ? _formatTime(_commonSetting.breakStart)
            : null,
        "end": _commonSetting.hasBreak
            ? _formatTime(_commonSetting.breakEnd)
            : null,
      },
      "business_hours": {
        "opening_time": _formatTime(_commonSetting.openTime),
        "closing_time": _formatTime(_commonSetting.closeTime),
      },
      "days": _days.map((d) {
        final map = <String, dynamic>{
          "day_name": dayNames[d.name] ?? d.name,
          "is_open": d.isOpen,
          "holiday_reason": d.isOpen ? null : d.holidayReason,
        };
        if (!_useSameHours) {
          map["opening_time"] = _formatTime(d.openTime);
          map["closing_time"] = _formatTime(d.closeTime);
          map["lunch"] = {
            "enabled": d.hasLunch,
            "start": d.hasLunch ? _formatTime(d.lunchStart) : null,
            "end": d.hasLunch ? _formatTime(d.lunchEnd) : null,
          };
          map["break"] = {
            "enabled": d.hasBreak,
            "start": d.hasBreak ? _formatTime(d.breakStart) : null,
            "end": d.hasBreak ? _formatTime(d.breakEnd) : null,
          };
        }
        return map;
      }).toList(),
      "lunch": {
        "enabled": _commonSetting.hasLunch,
        "start": _commonSetting.hasLunch
            ? _formatTime(_commonSetting.lunchStart)
            : null,
        "end": _commonSetting.hasLunch
            ? _formatTime(_commonSetting.lunchEnd)
            : null,
      },
    };

    final success = await ApiService().saveStoreOpeningClosingTime(payload);
    if (success) {
      if (mounted) {
        setState(() {
          final now = DateTime.now();
          final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
          final m = now.minute.toString().padLeft(2, '0');
          final s = now.second.toString().padLeft(2, '0');
          final p = now.hour >= 12 ? 'PM' : 'AM';
          _lastSavedTime = 'Saved at $h:$m:$s $p';
        });
      }
      widget.onSave();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save opening hours')),
        );
      }
    }
  }

  Widget _buildDropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged, {
    double width = 60,
  }) {
    return Container(
      height: 36,
      width: width,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector(TimeSetting start, TimeSetting end) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDropdown(
              start.hour,
              _hours,
              (val) => setState(() => start.hour = val!),
              width: 55,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(":", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            _buildDropdown(
              start.minute,
              _minutes,
              (val) => setState(() => start.minute = val!),
              width: 55,
            ),
            const SizedBox(width: 8),
            _buildDropdown(
              start.ampm,
              _ampm,
              (val) => setState(() => start.ampm = val!),
              width: 60,
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text("to", style: TextStyle(color: Colors.grey, fontSize: 13)),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDropdown(
              end.hour,
              _hours,
              (val) => setState(() => end.hour = val!),
              width: 55,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(":", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            _buildDropdown(
              end.minute,
              _minutes,
              (val) => setState(() => end.minute = val!),
              width: 55,
            ),
            const SizedBox(width: 8),
            _buildDropdown(
              end.ampm,
              _ampm,
              (val) => setState(() => end.ampm = val!),
              width: 60,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommonTimingSet() {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Common Timing Set",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Configure default hours to apply across all active open days",
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          const Text(
            "Business Hours:",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          _buildTimeRangeSelector(
            _commonSetting.openTime,
            _commonSetting.closeTime,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _commonSetting.hasLunch,
                      activeColor: const Color(0xFF6366F1),
                      onChanged: (val) =>
                          setState(() => _commonSetting.hasLunch = val!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Lunch Time",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _commonSetting.hasBreak,
                      activeColor: const Color(0xFF6366F1),
                      onChanged: (val) =>
                          setState(() => _commonSetting.hasBreak = val!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Break Time",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_commonSetting.hasLunch)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Lunch Time Range",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTimeRangeSelector(
                    _commonSetting.lunchStart,
                    _commonSetting.lunchEnd,
                  ),
                ],
              ),
            ),
          if (_commonSetting.hasBreak)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Break Time Range",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTimeRangeSelector(
                    _commonSetting.breakStart,
                    _commonSetting.breakEnd,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIndividualDay(DaySetting day, int index) {
    if (_useSameHours) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Switch(
              value: day.isOpen,
              activeColor: const Color(0xFF6366F1),
              onChanged: (val) => setState(() => day.isOpen = val),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 50,
              child: Text(
                day.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (day.isOpen)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "Open",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "Closed",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 12),
            if (day.isOpen)
              const Expanded(
                child: Text(
                  "Uses common timings defined above",
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
              )
            else
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextFormField(
                    initialValue: day.holidayReason,
                    onChanged: (val) => day.holidayReason = val,
                    decoration: InputDecoration(
                      hintText: "Reason for closure/leave (e.g. Weekly Holiday)",
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF6366F1)),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Switch(
                value: day.isOpen,
                activeColor: const Color(0xFF6366F1),
                onChanged: (val) => setState(() => day.isOpen = val),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 50,
                child: Text(
                  day.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              if (!day.isOpen)
                const Padding(
                  padding: EdgeInsets.only(left: 12, top: 8, bottom: 8),
                  child: Text(
                    "Closed",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const Spacer(),
              if (day.isOpen &&
                  index ==
                      0) // Only show "Apply to all" on Mon for example, or all? Screenshot shows it on multiple days. Let's show on all.
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (var d in _days) {
                        if (d.name != day.name && d.isOpen) {
                          d.openTime = TimeSetting(
                            day.openTime.hour,
                            day.openTime.minute,
                            day.openTime.ampm,
                          );
                          d.closeTime = TimeSetting(
                            day.closeTime.hour,
                            day.closeTime.minute,
                            day.closeTime.ampm,
                          );
                          d.hasLunch = day.hasLunch;
                          d.lunchStart = TimeSetting(
                            day.lunchStart.hour,
                            day.lunchStart.minute,
                            day.lunchStart.ampm,
                          );
                          d.lunchEnd = TimeSetting(
                            day.lunchEnd.hour,
                            day.lunchEnd.minute,
                            day.lunchEnd.ampm,
                          );
                          d.hasBreak = day.hasBreak;
                          d.breakStart = TimeSetting(
                            day.breakStart.hour,
                            day.breakStart.minute,
                            day.breakStart.ampm,
                          );
                          d.breakEnd = TimeSetting(
                            day.breakEnd.hour,
                            day.breakEnd.minute,
                            day.breakEnd.ampm,
                          );
                        }
                      }
                    });
                  },
                  child: const Text(
                    "Apply to all",
                    style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (day.isOpen)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimeRangeSelector(day.openTime, day.closeTime),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: day.hasLunch,
                          activeColor: const Color(0xFF6366F1),
                          onChanged: (val) =>
                              setState(() => day.hasLunch = val!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Lunch Time",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                  if (day.hasLunch)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: _buildTimeRangeSelector(
                        day.lunchStart,
                        day.lunchEnd,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: day.hasBreak,
                          activeColor: const Color(0xFF6366F1),
                          onChanged: (val) =>
                              setState(() => day.hasBreak = val!),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Break Time",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                  if (day.hasBreak)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: _buildTimeRangeSelector(
                        day.breakStart,
                        day.breakEnd,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: widget.onBack,
                ),
                const Expanded(
                  child: Text(
                    "Store Configuration > Opening & Closing Time",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.access_time_filled,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Opening & Closing Time",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Open $_openDaysCount of 7 days a week",
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _useSameHours,
                      activeColor: const Color(0xFF6366F1),
                      onChanged: (val) => setState(() => _useSameHours = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Use same hours for all days",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6366F1),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_useSameHours) _buildCommonTimingSet(),
            const SizedBox(height: 16),
            ..._days
                .asMap()
                .entries
                .map((e) => _buildIndividualDay(e.value, e.key))
                .toList(),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: _lastSavedTime != null
                        ? Row(
                            children: [
                              const Icon(
                                Icons.check,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _lastSavedTime!,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            "Changes save automatically as you edit",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _saveToApi,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Save & Continue",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
