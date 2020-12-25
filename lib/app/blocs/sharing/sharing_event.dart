/// abstract class for share event
abstract class ShareEvent {}

/// initial event
class InitialEvent extends ShareEvent{}

/// story is setting it's permissions
class StartSharingEvent extends ShareEvent{}

/// story has set it's permissions
class StopSharingEvent extends ShareEvent{}
