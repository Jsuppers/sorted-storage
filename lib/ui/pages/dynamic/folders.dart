import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/models/folder_properties.dart';

class FolderPage extends StatefulWidget {
  @override
  _FolderPageState createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<CloudStoriesBloc>(context)
        .add(const CloudStoriesEvent(CloudStoriesType.retrieveFolders));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return FolderView();
        },
      ),
    );
  }
}

class FolderView extends StatefulWidget {
  @override
  _FolderViewState createState() => _FolderViewState();
}

class _FolderViewState extends State<FolderView> {
  List<FolderProperties> folders = [];

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    for (FolderProperties folder in folders) {
      children.add(TextButton(
          onPressed: () => {
                BlocProvider.of<NavigationBloc>(context)
                    .add(NavigateToMediaEvent())
              },
          child: Text(folder.title)));
    }

    return BlocListener<CloudStoriesBloc, CloudStoriesState>(
      listener: (BuildContext context, CloudStoriesState state) {
        if (state.type == CloudStoriesType.retrieveFolders) {
          setState(() {
            folders = state.data as List<FolderProperties>;
          });
        }
      },
      child: Column(children: children),
    );
  }
}
