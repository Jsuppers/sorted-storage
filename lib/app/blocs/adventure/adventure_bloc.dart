//import 'dart:convert';
//import 'dart:typed_data';
//
//import 'package:bloc/bloc.dart';
//import 'package:file_picker/file_picker.dart';
//import 'package:flutter/services.dart';
//import 'package:googleapis/drive/v3.dart';
//import 'package:mime/mime.dart';
//import 'package:web/app/models/adventure.dart';
//import 'package:web/constants.dart';
//import 'package:web/ui/widgets/timeline_card.dart';
//
//
//class TimelineDataSearchResponse {
//  final EventContent eventContent;
//  final int index;
//
//  TimelineDataSearchResponse({this.eventContent, this.index});
//}
//class UploadImageReturn {
//  String id;
//  StoryMedia image;
//
//  UploadImageReturn(this.id, this.image);
//}
//
//class AdventureBloc extends Bloc<AdventureEvent, AdventureState> {
//  TimelineData localCopy;
//  TimelineData cloudCopy;
//  DriveApi driveApi;
//  TimelineData viewTimeline;
//  List<List<String>> uploadingImages;
//
//  AdventureBloc({this.cloudCopy}) : super(null) {
//    if (this.cloudCopy != null) {
//      this.localCopy = TimelineData.clone(cloudCopy);
//      _populateList(this.localCopy);
//    }
//  }
//
//  _populateList(TimelineData data) {
//    uploadingImages = List();
//    uploadingImages.add(List());
//    for (int i = 0; i< data.subEvents.length; i++) {
//      uploadingImages.add(List());
//    }
//  }
//
//  @override
//  Stream<AdventureState> mapEventToState(AdventureEvent event) async* {
//    if (event is AdventureUpdatedUploadedImagesEvent){
//      yield AdventureNewState(cloudCopy);
//    }
//    if (event is AdventureUpdatedEvent) {
//      yield AdventureNewState(cloudCopy);
//    }
//    if (event is AdventureSaveEvent) {
//      _syncCopies();
//    }
//
//
//
////    if (event is AdventureGetViewEvent) {
////      if (viewTimeline == null) {
////        viewTimeline = TimelineData();
////        viewTimeline = await _getViewEvent(event.folderID);
////        _populateList(viewTimeline);
////        yield AdventureNewState(viewTimeline, uploadingImages);
////      }
////    }
//  }
//
//
//
////  Future<TimelineData> _getViewEvent(String folderID) async {
////    var folder = await driveApi.files.get(folderID);
////    if (folder == null) {
////      return null;
////    }
////    int timestamp = int.tryParse(folder.name);
////    if (timestamp == null) {
////      return null;
////    }
////    var mainEvent = await _createEventFromFolder(folderID, timestamp);
////
////    List<EventContent> subEvents = List();
////    for (SubEvent subEvent in mainEvent.subEvents) {
////      subEvents
////          .add(await _createEventFromFolder(subEvent.id, subEvent.timestamp));
////    }
////
////    return TimelineData(mainEvent: mainEvent, subEvents: subEvents);
////  }
//
//
//  TimelineDataSearchResponse _getTimelineData(String folderID, TimelineData timelineEvent) {
//    EventContent content;
//    int index = -1;
//    if (timelineEvent.mainEvent.folderID == folderID) {
//      content = timelineEvent.mainEvent;
//      index = 0;
//    } else {
//      for (int i = 0; i < timelineEvent.subEvents.length; i++) {
//        EventContent element = timelineEvent.subEvents[i];
//        if (element.folderID == folderID) {
//          content = element;
//          index = i + 1;
//          break;
//        }
//      }
//    }
//    return TimelineDataSearchResponse(
//      eventContent: content,
//      index: index
//    );
//  }
//
//  Future<EventContent> _createEventFolder() async {
//    try {
//      File eventToUpload = File();
//      eventToUpload.parents = [cloudCopy.mainEvent.folderID];
//      eventToUpload.mimeType = "application/vnd.google-apps.folder";
//      eventToUpload.name = cloudCopy.mainEvent.timestamp.toString();
//
//      var folder = await driveApi.files.create(eventToUpload);
//      return EventContent(
//          comments: AdventureComments(comments: List()),
//          folderID: folder.id,
//          timestamp: cloudCopy.mainEvent.timestamp,
//          subEvents: List(),
//          images: Map());
//    } catch (e) {
//      print('error: $e');
//      return null;
//    }
//  }
//
//  _syncCopies() async {
//    for (int i = 0; i < localCopy.subEvents.length; i++) {
//      EventContent subEvent = localCopy.subEvents[i];
//      EventContent cloudSubEvent;
//      if (subEvent.folderID.startsWith("temp_")){
//        print('found local subevent');
//        cloudSubEvent = await _createEventFolder();
//        cloudCopy.subEvents.add(cloudSubEvent);
//        subEvent.folderID = cloudSubEvent.folderID;
//      } else {
//        cloudSubEvent = cloudCopy.subEvents
//            .singleWhere((element) => element.folderID == subEvent.folderID);
//      }
//
//      await _syncContent(i, subEvent, cloudSubEvent);
//    }
//
//    List<EventContent> eventsToDelete = List();
//    for (EventContent subEvent in cloudCopy.subEvents) {
//      EventContent localEvent;
//      for (int i = 0; i < localCopy.subEvents.length; i++) {
//        if (subEvent.folderID == localCopy.subEvents[i].folderID) {
//          localEvent = localCopy.subEvents[i];
//          break;
//        }
//      }
//      if (localEvent == null) {
//        await _deleteFile(subEvent.folderID);
//        eventsToDelete.add(subEvent);
//      }
//    }
//
//    for (EventContent subEvent in eventsToDelete) {
//      cloudCopy.subEvents.remove(subEvent);
//    }
//
//    await _syncContent(0, localCopy.mainEvent, cloudCopy.mainEvent);
//    localCopy = TimelineData.clone(cloudCopy);
//    print(localCopy.mainEvent.images);
//
//    this.add(AdventureUpdatedEvent());
//  }
//
//  Future _syncContent(int eventIndex, EventContent localCopy, EventContent cloudCopy) async {
//    List<Future> tasks = List();
//
//    print('updating cloud storage');
//    if (localCopy.timestamp != cloudCopy.timestamp) {
//      tasks.add(
//          _updateEventFolderTimestamp(localCopy.folderID, localCopy.timestamp)
//              .then((value) {
//        cloudCopy.timestamp = localCopy.timestamp;
//      }, onError: (error) {
//        print('error $error');
//      }));
//      print("timestamp is different!");
//    }
//
//    if (localCopy.title != cloudCopy.title ||
//        localCopy.description != cloudCopy.description) {
//      print('updating settings storage');
//      tasks.add(
//          _uploadSettingsFile(cloudCopy.folderID, localCopy).then((settingsId) {
//        cloudCopy.settingsID = settingsId;
//        cloudCopy.title = localCopy.title;
//        cloudCopy.description = localCopy.description;
//      }, onError: (error) {
//        print('error $error');
//      }));
//    }
//
//    Map<String, StoryMedia> imagesToAdd = Map();
//    List<String> imagesToDelete = [];
//    if (localCopy.images != null) {
//      print('uploading ${localCopy.images.length}');
//
//      // TODO: progress bar and elegant way sending images
//      int batchLength = 2;
//      for (int i = 0; i < localCopy.images.length; i += batchLength) {
//        for (int j = i;
//            j < i + batchLength && j < localCopy.images.length;
//            j++) {
//          MapEntry<String, StoryMedia> image =
//              localCopy.images.entries.elementAt(j);
//          if (!cloudCopy.images.containsKey(image.key)) {
//
//            this.add(AdventureUpdatedUploadedImagesEvent());
//            tasks.add(_uploadMediaToFolder(
//                    cloudCopy, image.key, image.value, 10)
//                .then((uploadResponse) {
//              // this causes a bug
//              uploadingImages[eventIndex].remove(image.key);
//              this.add(AdventureUpdatedUploadedImagesEvent());
//
//                  if(uploadResponse != null) {
//
//                    imagesToAdd.putIfAbsent(
//                        uploadResponse.id, () => uploadResponse.image);
//                  } else {
//                    print('uploadResponse $uploadResponse');
//                  }
//
//              print('uploaded this image: ${image.key}');
//            }, onError: (error) {
//              print('error $error');
//            }));
//            print('created request $i');
//          }
//        }
//      }
//
//      for (MapEntry<String, StoryMedia> image in cloudCopy.images.entries) {
//        if (!localCopy.images.containsKey(image.key)) {
//          print('delete this image: ${image.key}');
//          tasks.add(_deleteFile(image.key).then((value) {
//            imagesToDelete.add(image.key);
//          }, onError: (error) {
//            print('error $error');
//          }));
//        }
//      }
//    }
//
//
//    return Future.wait(tasks).then((_) {
//      cloudCopy.images.addAll(imagesToAdd);
//      cloudCopy.images
//          .removeWhere((key, value) => imagesToDelete.contains(key));
//    });
//  }
//
//  Future _deleteFile(String fileId) async {
//    return await driveApi.files.delete(fileId);
//  }
//
//  Future<String> _updateEventFolderTimestamp(
//      String fileID, int timestamp) async {
//    try {
//      File eventToUpload = File();
//      eventToUpload.name = timestamp.toString();
//
//      var folder = await driveApi.files.update(eventToUpload, fileID);
//      print('updated folder: $folder');
//
//      return folder.id;
//    } catch (e) {
//      print('error: $e');
//      return e.toString();
//    }
//  }
//
//  Future<String> _uploadSettingsFile(
//      String parentId, EventContent content) async {
//    AdventureSettings settings =
//        AdventureSettings(title: content.title, description: content.description);
//    String jsonString = jsonEncode(settings);
//
//
//    List<int> fileContent = utf8.encode(jsonString);
//    final Stream<List<int>> mediaStream =
//        Future.value(fileContent).asStream().asBroadcastStream();
//
//    if (content.settingsID != null) {
//      var folder = await driveApi.files.update(null, content.settingsID,
//          uploadMedia: Media(mediaStream, fileContent.length));
//      return folder.id;
//    }
//
//    File eventToUpload = File();
//    eventToUpload.parents = [parentId];
//    eventToUpload.mimeType = "application/json";
//    eventToUpload.name = Constants.SETTINGS_FILE;
//    var folder = await driveApi.files.create(eventToUpload,
//        uploadMedia: Media(mediaStream, fileContent.length));
//    return folder.id;
//  }
//
//  Future<UploadImageReturn> _uploadMediaToFolder(EventContent eventContent,
//      String imageName, StoryMedia storyMedia, int delayMilliseconds) async {
//    print('converting to list');
//    Stream<List<int>> dataStream;
//    if (storyMedia.isImage) {
//      dataStream = Future.value(storyMedia.bytes.toList()).asStream();
//    }else {
//      dataStream = storyMedia.stream;
//    }
//
//    File originalFileToUpload = File();
//    originalFileToUpload.parents = [eventContent.folderID];
//    originalFileToUpload.name = imageName;
//    Media image = Media(dataStream, storyMedia.size);
//
//    var uploadMedia = await driveApi.files
//        .create(originalFileToUpload, uploadMedia: image);
//
//    return UploadImageReturn(uploadMedia.id, storyMedia);
//  }
//
//}
