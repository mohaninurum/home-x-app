import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../theme_provider.dart';
import '../../domain/clock_customization.dart';
import '../widgets/custom_analog_clock_widget.dart';
import '../../animated_analog_clock/animated_analog_clock.dart';

class ClockCustomizationScreen extends ConsumerStatefulWidget {
  const ClockCustomizationScreen({super.key});

  @override
  ConsumerState<ClockCustomizationScreen> createState() => _ClockCustomizationScreenState();
}

class _ClockCustomizationScreenState extends ConsumerState<ClockCustomizationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> presets = [
    {
      'name': 'Classic',
      'customization': const ClockCustomization(
        dialType: DialType.dashes,
        showSecondHand: true,
      ),
    },
    {
      'name': 'Neon',
      'customization': ClockCustomization(
        dialType: DialType.numbers,
        backgroundColorValue: Colors.black.value,
        hourHandColorValue: Colors.cyanAccent.value,
        minuteHandColorValue: Colors.pinkAccent.value,
        secondHandColorValue: Colors.yellowAccent.value,
        numberColorValue: Colors.white.value,
        centerDotColorValue: Colors.cyanAccent.value,
      ),
    },
    {
      'name': 'Minimal',
      'customization': const ClockCustomization(
        dialType: DialType.dashes,
        showSecondHand: false,
        extendHourHand: true,
        extendMinuteHand: true,
      ),
    },
    {
      'name': 'Dark Mode',
      'customization': ClockCustomization(
        dialType: DialType.numbers,
        backgroundColorValue: const Color(0xFF1E1E1E).value,
        hourHandColorValue: Colors.white.value,
        minuteHandColorValue: Colors.white70.value,
        secondHandColorValue: Colors.redAccent.value,
        numberColorValue: Colors.white.value,
        hourDashColorValue: Colors.white.value,
        minuteDashColorValue: Colors.white38.value,
        centerDotColorValue: Colors.white.value,
      ),
    },
    {
      'name': 'Invisible Panic',
      'customization': ClockCustomization(
        dialType: DialType.none,
        backgroundColorValue: const Color(0xFF111111).value,
        hourHandColorValue: const Color(0xFF1a1a1a).value,
        minuteHandColorValue: const Color(0xFF1a1a1a).value,
        secondHandColorValue: const Color(0xFF222222).value,
        centerDotColorValue: const Color(0xFF1a1a1a).value,
        borderWidth: 0.0,
      ),
    },
    {
      'name': 'Spaghetti Arms',
      'customization': ClockCustomization(
        dialType: DialType.romanNumerals,
        backgroundColorValue: Colors.deepPurple.value,
        extendHourHand: true,
        extendMinuteHand: true,
        extendSecondHand: true,
        hourHandColorValue: Colors.orangeAccent.value,
        minuteHandColorValue: Colors.greenAccent.value,
        secondHandColorValue: Colors.pinkAccent.value,
        numberColorValue: Colors.cyanAccent.value,
        centerDotColorValue: Colors.yellowAccent.value,
      ),
    },
    {
      'name': 'Oops, All Seconds',
      'customization': ClockCustomization(
        dialType: DialType.none,
        backgroundColorValue: Colors.white.value,
        hourHandColorValue: Colors.transparent.value,
        minuteHandColorValue: Colors.transparent.value,
        secondHandColorValue: Colors.red.value,
        extendSecondHand: true,
      ),
    },
    {
      'name': 'Watermelon',
      'customization': ClockCustomization(
        dialType: DialType.dashes,
        backgroundColorValue: Colors.green.value,
        hourHandColorValue: Colors.black.value,
        minuteHandColorValue: Colors.black.value,
        secondHandColorValue: Colors.black.value,
        hourDashColorValue: Colors.red.value,
        minuteDashColorValue: Colors.red.value,
        centerDotColorValue: Colors.black.value,
        borderColorValue: Colors.greenAccent.value,
        borderWidth: 10.0,
      ),
    },
  ];

  void _showColorPicker(BuildContext context, String title, int? currentColor, Function(int?) onColorChanged) {
    int pickerColor = currentColor ?? 0xFFFFFFFF;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: Color(pickerColor),
            onColorChanged: (color) {
              pickerColor = color.value;
            },
            pickerAreaHeightPercent: 0.8,
            enableAlpha: true,
            displayThumbColor: true,
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Clear'),
            onPressed: () {
              onColorChanged(null);
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () {
              onColorChanged(pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeMoodProvider);
    final currentCustomization = ref.watch(clockCustomizationProvider).value ?? const ClockCustomization();

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: const Text('Clock Style'),
        backgroundColor: theme.backgroundColor,
        foregroundColor: theme.primaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.secondaryColor,
          unselectedLabelColor: theme.primaryColor.withOpacity(0.5),
          indicatorColor: theme.secondaryColor,
          tabs: const [
            Tab(text: 'Presets'),
            Tab(text: 'Customize'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Presets Tab
          GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: presets.length,
            itemBuilder: (context, index) {
              final preset = presets[index];
              final customization = preset['customization'] as ClockCustomization;
              final isSelected = currentCustomization.toMap().toString() == customization.toMap().toString();

              return GestureDetector(
                onTap: () {
                  ref.read(clockCustomizationProvider.notifier).updateCustomization(customization);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? theme.secondaryColor : theme.primaryColor.withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          preset['name'],
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: IgnorePointer(
                          child: CustomAnalogClockWidget(
                            size: 100,
                            customizationOverride: customization,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Customization Tab
          Column(
            children: [
              // Real-time Preview
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomAnalogClockWidget(
                    size: 180,
                    customizationOverride: currentCustomization,
                  ),
                ),
              ),
              
              // Scrollable Customization Settings
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('DIAL TYPE', style: TextStyle(color: theme.primaryColor.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold)),
                    DropdownButton<DialType>(
                      value: currentCustomization.dialType,
                      dropdownColor: theme.backgroundColor,
                      isExpanded: true,
                      onChanged: (DialType? newValue) {
                        if (newValue != null) {
                          ref.read(clockCustomizationProvider.notifier).updateCustomization(
                            currentCustomization.copyWith(dialType: newValue)
                          );
                        }
                      },
                      items: DialType.values.map<DropdownMenuItem<DialType>>((DialType value) {
                        return DropdownMenuItem<DialType>(
                          value: value,
                          child: Text(value.toString().split('.').last, style: TextStyle(color: theme.primaryColor)),
                        );
                      }).toList(),
                    ),
      
                    const SizedBox(height: 16),
                    Text('TOGGLES', style: TextStyle(color: theme.primaryColor.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold)),
                    SwitchListTile(
                      title: Text('Show Second Hand', style: TextStyle(color: theme.primaryColor)),
                      value: currentCustomization.showSecondHand,
                      onChanged: (val) => ref.read(clockCustomizationProvider.notifier).updateCustomization(currentCustomization.copyWith(showSecondHand: val)),
                    ),
                    SwitchListTile(
                      title: Text('Extend Hour Hand', style: TextStyle(color: theme.primaryColor)),
                      value: currentCustomization.extendHourHand,
                      onChanged: (val) => ref.read(clockCustomizationProvider.notifier).updateCustomization(currentCustomization.copyWith(extendHourHand: val)),
                    ),
                    SwitchListTile(
                      title: Text('Extend Minute Hand', style: TextStyle(color: theme.primaryColor)),
                      value: currentCustomization.extendMinuteHand,
                      onChanged: (val) => ref.read(clockCustomizationProvider.notifier).updateCustomization(currentCustomization.copyWith(extendMinuteHand: val)),
                    ),
                    SwitchListTile(
                      title: Text('Extend Second Hand', style: TextStyle(color: theme.primaryColor)),
                      value: currentCustomization.extendSecondHand,
                      onChanged: (val) => ref.read(clockCustomizationProvider.notifier).updateCustomization(currentCustomization.copyWith(extendSecondHand: val)),
                    ),
                    SwitchListTile(
                      title: Text('Speaks the Time', style: TextStyle(color: theme.primaryColor)),
                      value: currentCustomization.hourlyChimeEnabled,
                      onChanged: (val) => ref.read(clockCustomizationProvider.notifier).updateCustomization(currentCustomization.copyWith(hourlyChimeEnabled: val)),
                    ),
                    if (currentCustomization.hourlyChimeEnabled)
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0, right: 16.0),
                      child: Column(
                        children: [
                          RadioListTile<SpeakType>(
                            title: Text('Hindi', style: TextStyle(color: theme.primaryColor, fontSize: 14)),
                            value: SpeakType.hindi,
                            groupValue: currentCustomization.speakType,
                            activeColor: theme.secondaryColor,
                            onChanged: (val) {
                              if (val != null) {
                                ref.read(clockCustomizationProvider.notifier).updateCustomization(
                                  currentCustomization.copyWith(speakType: val)
                                );
                              }
                            },
                            controlAffinity: ListTileControlAffinity.trailing,
                            dense: true,
                          ),
                          RadioListTile<SpeakType>(
                            title: Text('Rathvi', style: TextStyle(color: theme.primaryColor, fontSize: 14)),
                            value: SpeakType.rathvi,
                            groupValue: currentCustomization.speakType,
                            activeColor: theme.secondaryColor,
                            onChanged: (val) {
                              if (val != null) {
                                ref.read(clockCustomizationProvider.notifier).updateCustomization(
                                  currentCustomization.copyWith(speakType: val)
                                );
                              }
                            },
                            controlAffinity: ListTileControlAffinity.trailing,
                            dense: true,
                          ),
                        ],
                      ),
                    ),
      
                    const SizedBox(height: 16),
                    Text('COLORS', style: TextStyle(color: theme.primaryColor.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold)),
                    
                    ListTile(
                      title: Text('Background Image', style: TextStyle(color: theme.primaryColor)),
                      subtitle: currentCustomization.backgroundImagePath != null ? const Text('Image selected') : const Text('None'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (currentCustomization.backgroundImagePath != null)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.redAccent),
                              onPressed: () {
                                ref.read(clockCustomizationProvider.notifier).updateCustomization(
                                  currentCustomization.copyWith(clearBackgroundImage: true)
                                );
                              },
                            ),
                          Icon(Icons.image, color: theme.primaryColor),
                        ],
                      ),
                      onTap: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          ref.read(clockCustomizationProvider.notifier).updateCustomization(
                            currentCustomization.copyWith(backgroundImagePath: picked.path)
                          );
                        }
                      },
                    ),
                    ListTile(
                      title: Text('Background Color', style: TextStyle(color: theme.primaryColor)),
                      trailing: Container(width: 24, height: 24, decoration: BoxDecoration(color: currentCustomization.backgroundColorValue != null ? Color(currentCustomization.backgroundColorValue!) : null, border: Border.all())),
                      onTap: () => _showColorPicker(context, 'Background Color', currentCustomization.backgroundColorValue, (color) {
                        ref.read(clockCustomizationProvider.notifier).updateCustomization(
                          currentCustomization.copyWith(backgroundColorValue: color, clearBackgroundColor: color == null)
                        );
                      }),
                    ),
                    ListTile(
                      title: Text('Hour Hand Color', style: TextStyle(color: theme.primaryColor)),
                      trailing: Container(width: 24, height: 24, decoration: BoxDecoration(color: currentCustomization.hourHandColorValue != null ? Color(currentCustomization.hourHandColorValue!) : null, border: Border.all())),
                      onTap: () => _showColorPicker(context, 'Hour Hand Color', currentCustomization.hourHandColorValue, (color) {
                        ref.read(clockCustomizationProvider.notifier).updateCustomization(
                          currentCustomization.copyWith(hourHandColorValue: color, clearHourHandColor: color == null)
                        );
                      }),
                    ),
                    ListTile(
                      title: Text('Minute Hand Color', style: TextStyle(color: theme.primaryColor)),
                      trailing: Container(width: 24, height: 24, decoration: BoxDecoration(color: currentCustomization.minuteHandColorValue != null ? Color(currentCustomization.minuteHandColorValue!) : null, border: Border.all())),
                      onTap: () => _showColorPicker(context, 'Minute Hand Color', currentCustomization.minuteHandColorValue, (color) {
                        ref.read(clockCustomizationProvider.notifier).updateCustomization(
                          currentCustomization.copyWith(minuteHandColorValue: color, clearMinuteHandColor: color == null)
                        );
                      }),
                    ),
                    ListTile(
                      title: Text('Second Hand Color', style: TextStyle(color: theme.primaryColor)),
                      trailing: Container(width: 24, height: 24, decoration: BoxDecoration(color: Color(currentCustomization.secondHandColorValue), border: Border.all())),
                      onTap: () => _showColorPicker(context, 'Second Hand Color', currentCustomization.secondHandColorValue, (color) {
                        if (color != null) {
                          ref.read(clockCustomizationProvider.notifier).updateCustomization(
                            currentCustomization.copyWith(secondHandColorValue: color)
                          );
                        }
                      }),
                    ),
                    ListTile(
                      title: Text('Hour Dash Color', style: TextStyle(color: theme.primaryColor)),
                      trailing: Container(width: 24, height: 24, decoration: BoxDecoration(color: currentCustomization.hourDashColorValue != null ? Color(currentCustomization.hourDashColorValue!) : null, border: Border.all())),
                      onTap: () => _showColorPicker(context, 'Hour Dash Color', currentCustomization.hourDashColorValue, (color) {
                        ref.read(clockCustomizationProvider.notifier).updateCustomization(
                          currentCustomization.copyWith(hourDashColorValue: color, clearHourDashColor: color == null)
                        );
                      }),
                    ),
                    ListTile(
                      title: Text('Minute Dash Color', style: TextStyle(color: theme.primaryColor)),
                      trailing: Container(width: 24, height: 24, decoration: BoxDecoration(color: currentCustomization.minuteDashColorValue != null ? Color(currentCustomization.minuteDashColorValue!) : null, border: Border.all())),
                      onTap: () => _showColorPicker(context, 'Minute Dash Color', currentCustomization.minuteDashColorValue, (color) {
                        ref.read(clockCustomizationProvider.notifier).updateCustomization(
                          currentCustomization.copyWith(minuteDashColorValue: color, clearMinuteDashColor: color == null)
                        );
                      }),
                    ),
                    ListTile(
                      title: Text('Center Dot Color', style: TextStyle(color: theme.primaryColor)),
                      trailing: Container(width: 24, height: 24, decoration: BoxDecoration(color: currentCustomization.centerDotColorValue != null ? Color(currentCustomization.centerDotColorValue!) : null, border: Border.all())),
                      onTap: () => _showColorPicker(context, 'Center Dot Color', currentCustomization.centerDotColorValue, (color) {
                        ref.read(clockCustomizationProvider.notifier).updateCustomization(
                          currentCustomization.copyWith(centerDotColorValue: color, clearCenterDotColor: color == null)
                        );
                      }),
                    ),
                    ListTile(
                      title: Text('Number Color', style: TextStyle(color: theme.primaryColor)),
                      trailing: Container(width: 24, height: 24, decoration: BoxDecoration(color: currentCustomization.numberColorValue != null ? Color(currentCustomization.numberColorValue!) : null, border: Border.all())),
                      onTap: () => _showColorPicker(context, 'Number Color', currentCustomization.numberColorValue, (color) {
                        ref.read(clockCustomizationProvider.notifier).updateCustomization(
                          currentCustomization.copyWith(numberColorValue: color, clearNumberColor: color == null)
                        );
                      }),
                    ),

                    const SizedBox(height: 16),
                    Text('BORDER', style: TextStyle(color: theme.primaryColor.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold)),
                    ListTile(
                      title: Text('Border Color', style: TextStyle(color: theme.primaryColor)),
                      trailing: Container(width: 24, height: 24, decoration: BoxDecoration(color: currentCustomization.borderColorValue != null ? Color(currentCustomization.borderColorValue!) : null, border: Border.all())),
                      onTap: () => _showColorPicker(context, 'Border Color', currentCustomization.borderColorValue, (color) {
                        ref.read(clockCustomizationProvider.notifier).updateCustomization(
                          currentCustomization.copyWith(borderColorValue: color, clearBorderColor: color == null)
                        );
                      }),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Width: ${currentCustomization.borderWidth.toStringAsFixed(1)}', style: TextStyle(color: theme.primaryColor)),
                          Slider(
                            value: currentCustomization.borderWidth,
                            min: 0,
                            max: 10,
                            divisions: 100,
                            activeColor: theme.secondaryColor,
                            onChanged: (val) => ref.read(clockCustomizationProvider.notifier).updateCustomization(currentCustomization.copyWith(borderWidth: val)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text('NEO EFFECT', style: TextStyle(color: theme.primaryColor.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold)),
                    SwitchListTile(
                      title: Text('Enable Neo Effect', style: TextStyle(color: theme.primaryColor)),
                      value: currentCustomization.neoEffectEnabled,
                      onChanged: (val) => ref.read(clockCustomizationProvider.notifier).updateCustomization(currentCustomization.copyWith(neoEffectEnabled: val)),
                    ),
                    if (currentCustomization.neoEffectEnabled)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Neo Border Width: ${currentCustomization.neoBorderWidth.toStringAsFixed(1)}', style: TextStyle(color: theme.primaryColor)),
                            Slider(
                              value: currentCustomization.neoBorderWidth,
                              min: 1,
                              max: 20,
                              divisions: 19,
                              activeColor: theme.secondaryColor,
                              onChanged: (val) => ref.read(clockCustomizationProvider.notifier).updateCustomization(currentCustomization.copyWith(neoBorderWidth: val)),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        ref.read(clockCustomizationProvider.notifier).resetToDefaults();
                      },
                      child: const Text('Reset to Defaults'),
                    ),
                    const SizedBox(height: 100), // Padding
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
