import 'package:flutter/material.dart';

class Dropdown extends FormField<String> {
  Dropdown({
    super.key,
    required List<String> dropDownList,
    required String dropDownTitle,
    super.onSaved,
    super.validator,
    super.initialValue,
  }) : super(
         builder: (FormFieldState<String> state) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               DropdownButton<String>(
                 value: state.value,
                 isExpanded: false,
                 hint: Text('Select $dropDownTitle'),
                 items: dropDownList.map((String value) {
                   return DropdownMenuItem<String>(
                     value: value,
                     child: Text(value),
                   );
                 }).toList(),
                 onChanged: (String? newValue) {
                   state.didChange(newValue);
                 },
               ),
               if (state.hasError)
                 Padding(
                   padding: const EdgeInsets.only(top: 5, left: 12),
                   child: Text(
                     state.errorText!,
                     style: TextStyle(
                       color: Theme.of(state.context).colorScheme.error,
                       fontSize: 12,
                     ),
                   ),
                 ),
             ],
           );
         },
       );
}
