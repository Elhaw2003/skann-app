import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/features/home/data/models/amenity_model.dart';
import 'package:skann_app/features/home/data/models/location_model.dart';
import 'package:skann_app/features/home/data/models/property_filters.dart';
import 'package:skann_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:skann_app/features/home/presentation/cubit/home_state.dart';
import 'package:skann_app/features/home/presentation/views/widgets/home_filter_amenities.dart';
import 'package:skann_app/features/home/presentation/views/widgets/home_filter_components.dart';
import 'package:skann_app/features/home/presentation/views/widgets/home_filter_header.dart';

Future<void> showHomeFilterSheet(
  BuildContext context, {
  required HomeCubit cubit,
  required PropertyFilters filters,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SafeArea(
      top: false,
      child: BlocProvider.value(
        value: cubit,
        child: _HomeFilterSheet(initialFilters: filters),
      ),
    ),
  );
}

class _HomeFilterSheet extends StatefulWidget {
  const _HomeFilterSheet({required this.initialFilters});

  final PropertyFilters initialFilters;

  @override
  State<_HomeFilterSheet> createState() => _HomeFilterSheetState();
}

class _HomeFilterSheetState extends State<_HomeFilterSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _governorateController;
  late final TextEditingController _universityController;
  late final TextEditingController _facultyController;
  late final TextEditingController _minimumPriceController;
  late final TextEditingController _maximumPriceController;
  late final Set<String> _selectedAmenities;
  late String? _city;
  late String? _area;
  late String? _propertyType;
  late String? _genderPolicy;

  @override
  void initState() {
    super.initState();
    final filters = widget.initialFilters;
    _governorateController = TextEditingController(
      text: filters.governorate ?? '',
    );
    _universityController = TextEditingController(
      text: filters.university ?? '',
    );
    _facultyController = TextEditingController(text: filters.faculty ?? '');
    _minimumPriceController = TextEditingController(
      text: filters.minPrice?.toString() ?? '',
    );
    _maximumPriceController = TextEditingController(
      text: filters.maxPrice?.toString() ?? '',
    );
    _selectedAmenities = filters.amenities.toSet();
    _city = filters.city;
    _area = filters.area;
    _propertyType = filters.propertyType;
    _genderPolicy = filters.genderPolicy;
  }

  @override
  void dispose() {
    _governorateController.dispose();
    _universityController.dispose();
    _facultyController.dispose();
    _minimumPriceController.dispose();
    _maximumPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.9,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
      ),
      child: Column(
        children: [
          HomeFilterHeader(onReset: _reset),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.fromLTRB(18.w, 5.h, 18.w, 18.h),
                children: [
                  _buildLocationFields(),
                  SizedBox(height: 17.h),
                  HomeFilterTextField(
                    label: 'الجامعة',
                    hint: 'اكتب اسم الجامعة',
                    controller: _universityController,
                    icon: Icons.school_outlined,
                  ),
                  SizedBox(height: 14.h),
                  HomeFilterTextField(
                    label: 'الكلية',
                    hint: 'اكتب اسم الكلية',
                    controller: _facultyController,
                    icon: Icons.menu_book_outlined,
                  ),
                  SizedBox(height: 18.h),
                  HomeFilterChoiceChips(
                    title: 'نوع السكن',
                    icon: Icons.apartment_rounded,
                    value: _propertyType,
                    options: const {
                      'STUDENT_HOUSING': 'سكن طلاب',
                      'SHARED_APARTMENT': 'شقة مشتركة',
                    },
                    onChanged: (value) => setState(() => _propertyType = value),
                  ),
                  SizedBox(height: 18.h),
                  HomeFilterChoiceChips(
                    title: 'سياسة السكن',
                    icon: Icons.people_alt_outlined,
                    value: _genderPolicy,
                    options: const {'MALE': 'طلاب', 'FEMALE': 'طالبات'},
                    onChanged: (value) => setState(() => _genderPolicy = value),
                  ),
                  SizedBox(height: 18.h),
                  HomePriceRangeFields(
                    minimumController: _minimumPriceController,
                    maximumController: _maximumPriceController,
                    minimumValidator: (value) =>
                        _validatePrice(value, validateRange: true),
                    maximumValidator: (value) =>
                        _validatePrice(value, validateRange: false),
                  ),
                  SizedBox(height: 20.h),
                  HomeFilterAmenities(
                    selectedAmenities: _selectedAmenities,
                    onChanged: _toggleAmenity,
                  ),
                ],
              ),
            ),
          ),
          HomeFilterActions(onApply: _apply),
        ],
      ),
    );
  }

  Widget _buildLocationFields() {
    return Column(
      children: [
        HomeFilterTextField(
          label: 'المحافظة',
          hint: 'اكتب اسم المحافظة',
          controller: _governorateController,
          icon: Icons.map_outlined,
        ),
        SizedBox(height: 14.h),
        BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is! HomeLoaded) return const SizedBox.shrink();
            final cities = state.locations;
            final cityOptions = {
              for (final city in cities) city.nameAr: city.nameAr,
            };
            final selectedCity = cityOptions.containsKey(_city) ? _city : null;
            return Column(
              children: [
                HomeFilterDropdownField(
                  label: 'المدينة',
                  icon: Icons.location_city_outlined,
                  value: selectedCity,
                  options: cityOptions,
                  hint: state.isLoadingLocations
                      ? 'جارٍ تحميل المدن...'
                      : 'اختار المدينة',
                  onChanged: (value) {
                    setState(() {
                      _city = value;
                      _area = null;
                    });
                  },
                ),
                if (state.locationsError != null)
                  HomeLookupError(
                    message: state.locationsError ?? '',
                    onRetry: context.read<HomeCubit>().loadLocations,
                  ),
                SizedBox(height: 14.h),
                _buildAreaDropdown(cities),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildAreaDropdown(List<LocationModel> cities) {
    final selectedCity = cities.where((city) => city.nameAr == _city);
    final areas = selectedCity.isEmpty
        ? const <AreaModel>[]
        : selectedCity.first.areas;
    final areaOptions = {for (final area in areas) area.nameAr: area.nameAr};
    final selectedArea = areaOptions.containsKey(_area) ? _area : null;
    return HomeFilterDropdownField(
      label: 'المنطقة',
      icon: Icons.place_outlined,
      value: selectedArea,
      options: areaOptions,
      hint: _city == null ? 'اختار المدينة أولًا' : 'اختار المنطقة',
      onChanged: (value) => setState(() => _area = value),
    );
  }

  String? _validatePrice(String? value, {required bool validateRange}) {
    if (value == null || value.trim().isEmpty) return null;
    final amount = int.tryParse(value);
    if (amount == null || amount < 0) return 'أدخل سعرًا صحيحًا';

    final otherValue = validateRange
        ? _maximumPriceController.text
        : _minimumPriceController.text;
    final otherAmount = int.tryParse(otherValue);
    if (otherAmount != null) {
      if (validateRange && amount > otherAmount) {
        return 'يجب ألا يتجاوز الحد الأدنى الحد الأقصى';
      }
      if (!validateRange && amount < otherAmount) {
        return 'يجب ألا يقل الحد الأقصى عن الحد الأدنى';
      }
    }
    return null;
  }

  void _toggleAmenity(AmenityModel amenity, bool selected) {
    setState(() {
      if (selected) {
        _selectedAmenities.add(amenity.name);
      } else {
        _selectedAmenities.remove(amenity.name);
      }
    });
  }

  void _reset() {
    context.read<HomeCubit>().resetFilters();
    Navigator.of(context).pop();
  }

  void _apply() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<HomeCubit>().applyFilters(
      PropertyFilters(
        governorate: _normalizedText(_governorateController.text),
        city: _city,
        area: _area,
        university: _normalizedText(_universityController.text),
        faculty: _normalizedText(_facultyController.text),
        propertyType: _propertyType,
        genderPolicy: _genderPolicy,
        minPrice: int.tryParse(_minimumPriceController.text),
        maxPrice: int.tryParse(_maximumPriceController.text),
        amenities: _selectedAmenities.toList(growable: false),
      ),
    );
    Navigator.of(context).pop();
  }

  String? _normalizedText(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }
}
