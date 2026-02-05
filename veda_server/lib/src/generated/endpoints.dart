/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import '../auth/email_idp_endpoint.dart' as _i2;
import '../auth/jwt_refresh_endpoint.dart' as _i3;
import '../gemini/gemini_endpoint.dart' as _i4;
import '../greetings/greeting_endpoint.dart' as _i5;
import '../live/live_endpoint.dart' as _i6;
import '../lms/lms_endpoint.dart' as _i7;
import '../profiles/user_profile_endpoint.dart' as _i8;
import 'package:veda_server/src/generated/gemini/chat_request.dart' as _i9;
import 'package:veda_server/src/generated/gemini/course_chat_request.dart'
    as _i10;
import 'package:veda_server/src/generated/live/live_message.dart' as _i11;
import 'package:veda_server/src/generated/lms/course.dart' as _i12;
import 'package:veda_server/src/generated/lms/course_visibility.dart' as _i13;
import 'package:veda_server/src/generated/lms/knowledge_file.dart' as _i14;
import 'package:veda_server/src/generated/lms/module.dart' as _i15;
import 'package:veda_server/src/generated/lms/topic.dart' as _i16;
import 'package:veda_server/src/generated/lms/module_item.dart' as _i17;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i18;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i19;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'emailIdp': _i2.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _i3.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'gemini': _i4.GeminiEndpoint()
        ..initialize(
          server,
          'gemini',
          null,
        ),
      'greeting': _i5.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
      'live': _i6.LiveEndpoint()
        ..initialize(
          server,
          'live',
          null,
        ),
      'lms': _i7.LmsEndpoint()
        ..initialize(
          server,
          'lms',
          null,
        ),
      'vedaUserProfile': _i8.VedaUserProfileEndpoint()
        ..initialize(
          server,
          'vedaUserProfile',
          null,
        ),
    };
    connectors['emailIdp'] = _i1.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint).login(
                session,
                email: params['email'],
                password: params['password'],
              ),
        ),
        'startRegistration': _i1.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _i1.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _i1.ParameterDescription(
              name: 'accountRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _i1.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _i1.ParameterDescription(
              name: 'registrationToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _i1.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _i1.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _i1.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _i1.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _i1.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newPassword': _i1.ParameterDescription(
              name: 'newPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
      },
    );
    connectors['jwtRefresh'] = _i1.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _i1.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _i1.ParameterDescription(
              name: 'refreshToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['jwtRefresh'] as _i3.JwtRefreshEndpoint)
                  .refreshAccessToken(
                    session,
                    refreshToken: params['refreshToken'],
                  ),
        ),
      },
    );
    connectors['gemini'] = _i1.EndpointConnector(
      name: 'gemini',
      endpoint: endpoints['gemini']!,
      methodConnectors: {
        'chat': _i1.MethodConnector(
          name: 'chat',
          params: {
            'request': _i1.ParameterDescription(
              name: 'request',
              type: _i1.getType<_i9.ChatRequest>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['gemini'] as _i4.GeminiEndpoint).chat(
                session,
                params['request'],
              ),
        ),
        'courseChat': _i1.MethodConnector(
          name: 'courseChat',
          params: {
            'request': _i1.ParameterDescription(
              name: 'request',
              type: _i1.getType<_i10.CourseChatRequest>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['gemini'] as _i4.GeminiEndpoint).courseChat(
                session,
                params['request'],
              ),
        ),
      },
    );
    connectors['greeting'] = _i1.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _i1.MethodConnector(
          name: 'hello',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['greeting'] as _i5.GreetingEndpoint).hello(
                session,
                params['name'],
              ),
        ),
      },
    );
    connectors['live'] = _i1.EndpointConnector(
      name: 'live',
      endpoint: endpoints['live']!,
      methodConnectors: {
        'audioSession': _i1.MethodStreamConnector(
          name: 'audioSession',
          params: {},
          streamParams: {
            'inputStream': _i1.StreamParameterDescription<_i11.LiveMessage>(
              name: 'inputStream',
              nullable: false,
            ),
          },
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['live'] as _i6.LiveEndpoint).audioSession(
                session,
                streamParams['inputStream']!.cast<_i11.LiveMessage>(),
              ),
        ),
      },
    );
    connectors['lms'] = _i1.EndpointConnector(
      name: 'lms',
      endpoint: endpoints['lms']!,
      methodConnectors: {
        'createCourse': _i1.MethodConnector(
          name: 'createCourse',
          params: {
            'course': _i1.ParameterDescription(
              name: 'course',
              type: _i1.getType<_i12.Course>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i7.LmsEndpoint).createCourse(
                session,
                params['course'],
              ),
        ),
        'updateCourse': _i1.MethodConnector(
          name: 'updateCourse',
          params: {
            'course': _i1.ParameterDescription(
              name: 'course',
              type: _i1.getType<_i12.Course>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i7.LmsEndpoint).updateCourse(
                session,
                params['course'],
              ),
        ),
        'deleteCourse': _i1.MethodConnector(
          name: 'deleteCourse',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i7.LmsEndpoint).deleteCourse(
                session,
                params['id'],
              ),
        ),
        'getCourseById': _i1.MethodConnector(
          name: 'getCourseById',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i7.LmsEndpoint).getCourseById(
                session,
                params['id'],
              ),
        ),
        'listCourses': _i1.MethodConnector(
          name: 'listCourses',
          params: {
            'keyword': _i1.ParameterDescription(
              name: 'keyword',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'visibility': _i1.ParameterDescription(
              name: 'visibility',
              type: _i1.getType<_i13.CourseVisibility?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i7.LmsEndpoint).listCourses(
                session,
                keyword: params['keyword'],
                visibility: params['visibility'],
              ),
        ),
        'addFileToCourse': _i1.MethodConnector(
          name: 'addFileToCourse',
          params: {
            'file': _i1.ParameterDescription(
              name: 'file',
              type: _i1.getType<_i14.KnowledgeFile>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i7.LmsEndpoint).addFileToCourse(
                session,
                params['file'],
              ),
        ),
        'getFilesForCourse': _i1.MethodConnector(
          name: 'getFilesForCourse',
          params: {
            'courseId': _i1.ParameterDescription(
              name: 'courseId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['lms'] as _i7.LmsEndpoint).getFilesForCourse(
                    session,
                    params['courseId'],
                  ),
        ),
        'deleteFile': _i1.MethodConnector(
          name: 'deleteFile',
          params: {
            'fileId': _i1.ParameterDescription(
              name: 'fileId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i7.LmsEndpoint).deleteFile(
                session,
                params['fileId'],
              ),
        ),
        'getModules': _i1.MethodConnector(
          name: 'getModules',
          params: {
            'courseId': _i1.ParameterDescription(
              name: 'courseId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i7.LmsEndpoint).getModules(
                session,
                params['courseId'],
              ),
        ),
        'createModule': _i1.MethodConnector(
          name: 'createModule',
          params: {
            'module': _i1.ParameterDescription(
              name: 'module',
              type: _i1.getType<_i15.Module>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i7.LmsEndpoint).createModule(
                session,
                params['module'],
              ),
        ),
        'updateModule': _i1.MethodConnector(
          name: 'updateModule',
          params: {
            'module': _i1.ParameterDescription(
              name: 'module',
              type: _i1.getType<_i15.Module>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i7.LmsEndpoint).updateModule(
                session,
                params['module'],
              ),
        ),
        'deleteModule': _i1.MethodConnector(
          name: 'deleteModule',
          params: {
            'moduleId': _i1.ParameterDescription(
              name: 'moduleId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i7.LmsEndpoint).deleteModule(
                session,
                params['moduleId'],
              ),
        ),
        'deleteAllModules': _i1.MethodConnector(
          name: 'deleteAllModules',
          params: {
            'courseId': _i1.ParameterDescription(
              name: 'courseId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i7.LmsEndpoint).deleteAllModules(
                session,
                params['courseId'],
              ),
        ),
        'createTopic': _i1.MethodConnector(
          name: 'createTopic',
          params: {
            'topic': _i1.ParameterDescription(
              name: 'topic',
              type: _i1.getType<_i16.Topic>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i7.LmsEndpoint).createTopic(
                session,
                params['topic'],
              ),
        ),
        'updateTopic': _i1.MethodConnector(
          name: 'updateTopic',
          params: {
            'topic': _i1.ParameterDescription(
              name: 'topic',
              type: _i1.getType<_i16.Topic>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i7.LmsEndpoint).updateTopic(
                session,
                params['topic'],
              ),
        ),
        'getTopicById': _i1.MethodConnector(
          name: 'getTopicById',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i7.LmsEndpoint).getTopicById(
                session,
                params['id'],
              ),
        ),
        'createModuleItem': _i1.MethodConnector(
          name: 'createModuleItem',
          params: {
            'moduleItem': _i1.ParameterDescription(
              name: 'moduleItem',
              type: _i1.getType<_i17.ModuleItem>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i7.LmsEndpoint).createModuleItem(
                session,
                params['moduleItem'],
              ),
        ),
        'updateModuleItem': _i1.MethodConnector(
          name: 'updateModuleItem',
          params: {
            'moduleItem': _i1.ParameterDescription(
              name: 'moduleItem',
              type: _i1.getType<_i17.ModuleItem>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i7.LmsEndpoint).updateModuleItem(
                session,
                params['moduleItem'],
              ),
        ),
        'deleteModuleItem': _i1.MethodConnector(
          name: 'deleteModuleItem',
          params: {
            'moduleItemId': _i1.ParameterDescription(
              name: 'moduleItemId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i7.LmsEndpoint).deleteModuleItem(
                session,
                params['moduleItemId'],
              ),
        ),
        'getUploadDescription': _i1.MethodConnector(
          name: 'getUploadDescription',
          params: {
            'path': _i1.ParameterDescription(
              name: 'path',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['lms'] as _i7.LmsEndpoint).getUploadDescription(
                    session,
                    params['path'],
                  ),
        ),
        'verifyUpload': _i1.MethodConnector(
          name: 'verifyUpload',
          params: {
            'path': _i1.ParameterDescription(
              name: 'path',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i7.LmsEndpoint).verifyUpload(
                session,
                params['path'],
              ),
        ),
        'getPublicUrl': _i1.MethodConnector(
          name: 'getPublicUrl',
          params: {
            'path': _i1.ParameterDescription(
              name: 'path',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i7.LmsEndpoint).getPublicUrl(
                session,
                params['path'],
              ),
        ),
      },
    );
    connectors['vedaUserProfile'] = _i1.EndpointConnector(
      name: 'vedaUserProfile',
      endpoint: endpoints['vedaUserProfile']!,
      methodConnectors: {
        'upsertProfile': _i1.MethodConnector(
          name: 'upsertProfile',
          params: {
            'fullName': _i1.ParameterDescription(
              name: 'fullName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'bio': _i1.ParameterDescription(
              name: 'bio',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'interests': _i1.ParameterDescription(
              name: 'interests',
              type: _i1.getType<List<String>>(),
              nullable: false,
            ),
            'learningGoal': _i1.ParameterDescription(
              name: 'learningGoal',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['vedaUserProfile'] as _i8.VedaUserProfileEndpoint)
                      .upsertProfile(
                        session,
                        fullName: params['fullName'],
                        bio: params['bio'],
                        interests: params['interests'],
                        learningGoal: params['learningGoal'],
                      ),
        ),
        'getMyProfile': _i1.MethodConnector(
          name: 'getMyProfile',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['vedaUserProfile'] as _i8.VedaUserProfileEndpoint)
                      .getMyProfile(session),
        ),
        'hasCompletedOnboarding': _i1.MethodConnector(
          name: 'hasCompletedOnboarding',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['vedaUserProfile'] as _i8.VedaUserProfileEndpoint)
                      .hasCompletedOnboarding(session),
        ),
        'getMyProfileWithEmail': _i1.MethodConnector(
          name: 'getMyProfileWithEmail',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['vedaUserProfile'] as _i8.VedaUserProfileEndpoint)
                      .getMyProfileWithEmail(session),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i18.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i19.Endpoints()
      ..initializeEndpoints(server);
  }
}
