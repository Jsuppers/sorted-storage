// Flutter imports:
import 'package:flutter/material.dart';
import 'package:sorted_storage/layout/layout.dart';
import 'package:sorted_storage/themes/colors.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Card(
      shape: const StadiumBorder(),
      child: TextFormField(
        style: _theme.textTheme.subtitle1,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          prefixIcon: Padding(
            padding: EdgeInsets.only(
              left: AppSpacings.twentyFour,
              right: AppSpacings.twelve,
            ),
            child: const Icon(
              Icons.search,
              color: StorageColors.blueGrey,
            ),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 12, minHeight: 12),
          hintText: 'Search your opened tabs',
          hintStyle: _theme.textTheme.bodyText1!.copyWith(
            color: StorageColors.blueGrey50,
          ),
          counterText: '',
        ),
      ),
    );
  }
}
