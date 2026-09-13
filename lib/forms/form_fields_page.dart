import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n_extension.dart';

/// Field names in one place — a typo in `name:` would silently create a new key.
abstract final class FieldNames {
  static const meetingTime = 'meetingTime';
  static const appointment = 'appointment';
  static const tripDates = 'tripDates';
  static const volume = 'volume';
  static const priceRange = 'priceRange';
  static const age = 'age';
  static const newsletter = 'newsletter';
  static const contact = 'contact';
  static const phone = 'phone';
  static const interests = 'interests';
  static const size = 'size';
  static const toppings = 'toppings';
  static const rating = 'rating';
  static const color = 'color';
  static const notes = 'notes';
  static String guest(int id) => 'guest_$id';
}

/// Showcase of every flutter_form_builder field type plus custom, conditional and dynamic fields.
class FormFieldsPage extends StatefulWidget {
  const FormFieldsPage({super.key});

  @override
  State<FormFieldsPage> createState() => _FormFieldsPageState();
}

class _FormFieldsPageState extends State<FormFieldsPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  String? _contact;
  final _guestIds = <int>[];
  int _nextGuestId = 1;

  static const _gap = SizedBox(height: 16);
  static const _colors = [
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.blue,
    Colors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.formFieldsTitle),
        actions: [
          TextButton(
            onPressed: _fillExample,
            child: Text(l10n.fieldsFillExample),
          ),
        ],
      ),
      body: FormBuilder(
        key: _formKey,
        // Removed dynamic fields (guests, conditional phone) also drop their values.
        clearValueOnUnregister: true,
        // NOT ListView: it builds children lazily, and fields that were never built aren't
        // registered — they would be skipped by validate(), patchValue() and form.value.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------------------------------------------------------------- date & time
              _SectionTitle(l10n.fieldsSectionDateTime),
              FormBuilderDateTimePicker(
                name: FieldNames.meetingTime,
                inputType:
                    InputType.time, // value: DateTime (date part = today)
                format: DateFormat.jm(locale),
                decoration: InputDecoration(
                  labelText: l10n.fieldsMeetingTime,
                  suffixIcon: const Icon(Icons.access_time),
                ),
                validator: FormBuilderValidators.required(),
              ),
              _gap,
              FormBuilderDateTimePicker(
                name: FieldNames.appointment,
                inputType: InputType.both, // date picker, then time picker
                format: DateFormat.yMMMd(locale).add_jm(),
                firstDate: DateTime.now(),
                decoration: InputDecoration(
                  labelText: l10n.fieldsAppointment,
                  suffixIcon: const Icon(Icons.event),
                ),
              ),
              _gap,
              FormBuilderDateRangePicker(
                name: FieldNames.tripDates, // value: DateTimeRange
                firstDate: DateUtils.dateOnly(DateTime.now()),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                format: DateFormat.yMMMd(locale),
                decoration: InputDecoration(
                  labelText: l10n.fieldsTripDates,
                  suffixIcon: const Icon(Icons.date_range),
                ),
              ),

              // ---------------------------------------------------------------- numbers
              _SectionTitle(l10n.fieldsSectionNumbers),
              FormBuilderSlider(
                name: FieldNames.volume, // value: double
                min: 0,
                max: 100,
                divisions: 20,
                initialValue: 40,
                displayValues: DisplayValues.current,
                decoration: InputDecoration(labelText: l10n.fieldsVolume),
              ),
              FormBuilderRangeSlider(
                name: FieldNames.priceRange, // value: RangeValues
                min: 0,
                max: 10000,
                divisions: 20,
                initialValue: const RangeValues(1000, 5000),
                decoration: InputDecoration(labelText: l10n.fieldsPriceRange),
              ),
              FormBuilderTextField(
                name: FieldNames.age,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.fieldsAge),
                // Stored as int? instead of String in form.value.
                valueTransformer: (value) => int.tryParse(value ?? ''),
                // Optional field: checkNullOrEmpty: false → empty is valid, a value must be 18–120.
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.integer(checkNullOrEmpty: false),
                  FormBuilderValidators.min(18, checkNullOrEmpty: false),
                  FormBuilderValidators.max(120, checkNullOrEmpty: false),
                ]),
              ),

              // ---------------------------------------------------------------- choices
              _SectionTitle(l10n.fieldsSectionChoices),
              FormBuilderSwitch(
                name: FieldNames.newsletter, // value: bool
                initialValue: false,
                title: Text(l10n.fieldsNewsletter),
              ),
              FormBuilderRadioGroup<String>(
                name: FieldNames.contact,
                decoration: InputDecoration(
                  labelText: l10n.fieldsContactMethod,
                ),
                validator: FormBuilderValidators.required(),
                onChanged: (value) => setState(() => _contact = value),
                options: [
                  FormBuilderFieldOption(
                    value: 'email',
                    child: Text(l10n.formEmail),
                  ),
                  FormBuilderFieldOption(
                    value: 'phone',
                    child: Text(l10n.fieldsContactPhone),
                  ),
                  FormBuilderFieldOption(
                    value: 'sms',
                    child: Text(l10n.fieldsContactSms),
                  ),
                ],
              ),
              // Conditional field: only exists (and validates) when "Phone" is chosen.
              if (_contact == 'phone') ...[
                _gap,
                FormBuilderTextField(
                  name: FieldNames.phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: l10n.fieldsPhone),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.phoneNumber(),
                  ]),
                ),
              ],
              _gap,
              FormBuilderCheckboxGroup<String>(
                name: FieldNames.interests, // value: List<String>
                decoration: InputDecoration(labelText: l10n.fieldsInterests),
                validator: FormBuilderValidators.minLength(1),
                options: [
                  const FormBuilderFieldOption(
                    value: 'flutter',
                    child: Text('Flutter'),
                  ),
                  const FormBuilderFieldOption(
                    value: 'dart',
                    child: Text('Dart'),
                  ),
                  const FormBuilderFieldOption(
                    value: 'firebase',
                    child: Text('Firebase'),
                  ),
                  FormBuilderFieldOption(
                    value: 'design',
                    child: Text(l10n.fieldsInterestDesign),
                  ),
                ],
              ),
              _gap,
              FormBuilderChoiceChips<String>(
                name: FieldNames.size, // single choice
                decoration: InputDecoration(labelText: l10n.fieldsSize),
                spacing: 8,
                validator: FormBuilderValidators.required(),
                options: const [
                  FormBuilderChipOption(value: 'S'),
                  FormBuilderChipOption(value: 'M'),
                  FormBuilderChipOption(value: 'L'),
                  FormBuilderChipOption(value: 'XL'),
                ],
              ),
              _gap,
              FormBuilderFilterChips<String>(
                name: FieldNames.toppings, // multiple choice → List<String>
                decoration: InputDecoration(labelText: l10n.fieldsToppings),
                spacing: 8,
                options: [
                  FormBuilderChipOption(
                    value: 'cheese',
                    child: Text(l10n.fieldsToppingCheese),
                  ),
                  FormBuilderChipOption(
                    value: 'mushroom',
                    child: Text(l10n.fieldsToppingMushroom),
                  ),
                  FormBuilderChipOption(
                    value: 'olive',
                    child: Text(l10n.fieldsToppingOlive),
                  ),
                  FormBuilderChipOption(
                    value: 'pepper',
                    child: Text(l10n.fieldsToppingPepper),
                  ),
                ],
              ),

              // ---------------------------------------------------------------- custom & dynamic
              _SectionTitle(l10n.fieldsSectionCustom),
              _StarRatingField(
                name: FieldNames.rating,
                label: l10n.fieldsRating,
              ),
              _gap,
              _ColorField(
                name: FieldNames.color,
                label: l10n.fieldsFavoriteColor,
                colors: _colors,
              ),
              _gap,
              FormBuilderTextField(
                name: FieldNames.notes,
                maxLines: 4,
                maxLength: 200,
                decoration: InputDecoration(
                  labelText: l10n.fieldsNotes,
                  alignLabelWithHint: true,
                ),
              ),
              _gap,
              // Dynamic fields: each guest gets a unique, stable name.
              for (final (index, id) in _guestIds.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FormBuilderTextField(
                    key: ValueKey(id),
                    name: FieldNames.guest(id),
                    decoration: InputDecoration(
                      labelText: l10n.fieldsGuestName(index + 1),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        tooltip: l10n.fieldsRemoveGuest,
                        onPressed: () => setState(() => _guestIds.remove(id)),
                      ),
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: Text(l10n.fieldsAddGuest),
                  onPressed: () =>
                      setState(() => _guestIds.add(_nextGuestId++)),
                ),
              ),
              _gap,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      child: Text(l10n.formReset),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _submit,
                      child: Text(l10n.formSubmit),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Sets many fields at once — e.g. editing an existing record loaded from an API.
  void _fillExample() {
    setState(() => _contact = 'email');
    _formKey.currentState?.patchValue({
      FieldNames.meetingTime: DateTime(2026, 1, 1, 9, 30),
      FieldNames.volume: 70.0,
      FieldNames.priceRange: const RangeValues(2000, 8000),
      FieldNames.newsletter: true,
      FieldNames.contact: 'email',
      FieldNames.interests: ['flutter', 'dart'],
      FieldNames.size: 'M',
      FieldNames.toppings: ['cheese', 'olive'],
      FieldNames.rating: 4,
      FieldNames.color: Colors.green,
      FieldNames.notes: 'Filled with patchValue',
    });
  }

  void _reset() {
    _formKey.currentState?.reset();
    setState(() {
      _contact = null;
      _guestIds.clear();
    });
  }

  void _submit() {
    final l10n = context.l10n;
    final form = _formKey.currentState!;

    if (!form.saveAndValidate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.formInvalid)));
      return;
    }

    final locale = Localizations.localeOf(context).toLanguageTag();
    final lines =
        form.value.entries
            .where((entry) => entry.value != null)
            .map((entry) => '${entry.key}: ${_describe(entry.value, locale)}')
            .toList()
          ..sort();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.fieldsResult),
        content: SingleChildScrollView(child: Text(lines.join('\n'))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
  }

  static String _describe(Object? value, String locale) => switch (value) {
    DateTimeRange(:final start, :final end) =>
      '${DateFormat.yMMMd(locale).format(start)} – ${DateFormat.yMMMd(locale).format(end)}',
    DateTime() => DateFormat.yMMMd(locale).add_jm().format(value),
    RangeValues(:final start, :final end) =>
      '${start.round()} – ${end.round()}',
    Color() =>
      '#${value.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
    List() => value.join(', '),
    double() => value.round().toString(),
    _ => '$value',
  };
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

/// Custom field: any widget can become a form field with `FormBuilderField<T>`.
class _StarRatingField extends StatelessWidget {
  const _StarRatingField({required this.name, required this.label});

  final String name;
  final String label;

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<int>(
      name: name,
      validator: FormBuilderValidators.required(),
      builder: (field) => InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText:
              field.errorText, // shows validator errors like built-in fields
          border: InputBorder.none,
        ),
        child: Row(
          children: [
            for (var star = 1; star <= 5; star++)
              IconButton(
                tooltip: '$star',
                icon: Icon(
                  star <= (field.value ?? 0) ? Icons.star : Icons.star_border,
                  color: Colors.amber.shade700,
                ),
                onPressed: () =>
                    field.didChange(star), // updates value + runs onChanged
              ),
          ],
        ),
      ),
    );
  }
}

class _ColorField extends StatelessWidget {
  const _ColorField({
    required this.name,
    required this.label,
    required this.colors,
  });

  final String name;
  final String label;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<Color>(
      name: name,
      builder: (field) => InputDecorator(
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
        child: Wrap(
          spacing: 12,
          children: [
            for (final color in colors)
              Semantics(
                button: true,
                selected: field.value == color,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => field.didChange(color),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: field.value == color
                          ? Border.all(
                              width: 3,
                              color: Theme.of(context).colorScheme.onSurface,
                            )
                          : null,
                    ),
                    child: field.value == color
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
