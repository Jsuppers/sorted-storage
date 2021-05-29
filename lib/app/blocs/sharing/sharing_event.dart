/// abstract class for share event
abstract class ShareEvent {}

/// initial event
class InitialEvent extends ShareEvent {}

/// folder is setting it's permissions
class StartSharingEvent extends ShareEvent {}

/// folder has set it's permissions
class StopSharingEvent extends ShareEvent {}
