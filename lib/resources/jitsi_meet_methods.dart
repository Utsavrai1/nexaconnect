import 'package:flutter/material.dart';
import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';
import 'package:nexaconnect/resources/auth_methods.dart';
import 'package:nexaconnect/resources/firestore_methods.dart';

class JitsiMeetMethods {
  final AuthMethods _authMethods = AuthMethods();
  final FirestoreMethods _firestoreMethods = FirestoreMethods();

  void createMeeting({
    required String roomName,
    required bool isAudioMuted,
    required bool isVideoMuted,
    String username = '',
  }) async {
    try {
      Map<String, Object> featureFlags = {
        'welcomePageEnabled': false,
      };
      String name;
      if (username.isEmpty) {
        name = _authMethods.user.displayName!;
      } else {
        name = username;
      }
      var options = JitsiMeetingOptions(
        roomNameOrUrl: roomName,
        userDisplayName: name,
        userEmail: _authMethods.user.email,
        userAvatarUrl: _authMethods.user.photoURL,
        isAudioMuted: isAudioMuted,
        isVideoMuted: isVideoMuted,
        featureFlags: featureFlags,
      );

      _firestoreMethods.addToMeetingHistory(roomName);
      await JitsiMeetWrapper.joinMeeting(
        options: options,
        listener: JitsiMeetingListener(
          onOpened: () => debugPrint("onOpened"),
          onConferenceWillJoin: (url) {
            debugPrint("onConferenceWillJoin: url: $url");
          },
          onConferenceJoined: (url) {
            debugPrint("onConferenceJoined: url: $url");
          },
          onConferenceTerminated: (url, error) {
            debugPrint("onConferenceTerminated: url: $url, error: $error");
          },
          onAudioMutedChanged: (isMuted) {
            debugPrint("onAudioMutedChanged: isMuted: $isMuted");
          },
          onVideoMutedChanged: (isMuted) {
            debugPrint("onVideoMutedChanged: isMuted: $isMuted");
          },
          onScreenShareToggled: (participantId, isSharing) {
            debugPrint(
              "onScreenShareToggled: participantId: $participantId, "
              "isSharing: $isSharing",
            );
          },
          onParticipantJoined: (email, name, role, participantId) {
            debugPrint(
              "onParticipantJoined: email: $email, name: $name, role: $role, "
              "participantId: $participantId",
            );
          },
          onParticipantLeft: (participantId) {
            debugPrint("onParticipantLeft: participantId: $participantId");
          },
          onParticipantsInfoRetrieved: (participantsInfo, requestId) {
            debugPrint(
              "onParticipantsInfoRetrieved: participantsInfo: $participantsInfo, "
              "requestId: $requestId",
            );
          },
          onChatMessageReceived: (senderId, message, isPrivate) {
            debugPrint(
              "onChatMessageReceived: senderId: $senderId, message: $message, "
              "isPrivate: $isPrivate",
            );
          },
          onChatToggled: (isOpen) =>
              debugPrint("onChatToggled: isOpen: $isOpen"),
          onClosed: () => debugPrint("onClosed"),
        ),
      );
    } catch (error) {
      debugPrint("error: $error");
    }
  }
}
