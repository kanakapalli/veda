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
import '../lms/lms_endpoint.dart' as _i6;
import '../profiles/user_profile_endpoint.dart' as _i7;
import 'package:veda_server/src/generated/gemini/chat_request.dart' as _i8;
import 'package:veda_server/src/generated/gemini/course_chat_request.dart'
    as _i9;
import 'package:veda_server/src/generated/lms/course.dart' as _i10;
import 'package:veda_server/src/generated/lms/course_visibility.dart' as _i11;
import 'package:veda_server/src/generated/lms/knowledge_file.dart' as _i12;
import 'package:veda_server/src/generated/lms/module.dart' as _i13;
import 'package:veda_server/src/generated/lms/topic.dart' as _i14;
import 'package:veda_server/src/generated/lms/module_item.dart' as _i15;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i16;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i17;

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
      'lms': _i6.LmsEndpoint()
        ..initialize(
          server,
          'lms',
          null,
        ),
      'vedaUserProfile': _i7.VedaUserProfileEndpoint()
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
              type: _i1.getType<_i8.ChatRequest>(),
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
              type: _i1.getType<_i9.CourseChatRequest>(),
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
        'startTeachingChat': _i1.MethodConnector(
          name: 'startTeachingChat',
          params: {
            'courseId': _i1.ParameterDescription(
              name: 'courseId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'systemPrompt': _i1.ParameterDescription(
              name: 'systemPrompt',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'firstMessage': _i1.ParameterDescription(
              name: 'firstMessage',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'minWords': _i1.ParameterDescription(
              name: 'minWords',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'maxWords': _i1.ParameterDescription(
              name: 'maxWords',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['gemini'] as _i4.GeminiEndpoint).startTeachingChat(
                    session,
                    params['courseId'],
                    systemPrompt: params['systemPrompt'],
                    firstMessage: params['firstMessage'],
                    minWords: params['minWords'],
                    maxWords: params['maxWords'],
                  ),
        ),
        'answerTeachingQuestion': _i1.MethodConnector(
          name: 'answerTeachingQuestion',
          params: {
            'courseId': _i1.ParameterDescription(
              name: 'courseId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'moduleTitle': _i1.ParameterDescription(
              name: 'moduleTitle',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'question': _i1.ParameterDescription(
              name: 'question',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'history': _i1.ParameterDescription(
              name: 'history',
              type: _i1.getType<List<Map<String, String>>?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['gemini'] as _i4.GeminiEndpoint)
                  .answerTeachingQuestion(
                    session,
                    params['courseId'],
                    moduleTitle: params['moduleTitle'],
                    question: params['question'],
                    history: params['history'],
                  ),
        ),
        'generateSpeech': _i1.MethodConnector(
          name: 'generateSpeech',
          params: {
            'text': _i1.ParameterDescription(
              name: 'text',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['gemini'] as _i4.GeminiEndpoint).generateSpeech(
                    session,
                    params['text'],
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
    connectors['lms'] = _i1.EndpointConnector(
      name: 'lms',
      endpoint: endpoints['lms']!,
      methodConnectors: {
        'createCourse': _i1.MethodConnector(
          name: 'createCourse',
          params: {
            'course': _i1.ParameterDescription(
              name: 'course',
              type: _i1.getType<_i10.Course>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i6.LmsEndpoint).createCourse(
                session,
                params['course'],
              ),
        ),
        'updateCourse': _i1.MethodConnector(
          name: 'updateCourse',
          params: {
            'course': _i1.ParameterDescription(
              name: 'course',
              type: _i1.getType<_i10.Course>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i6.LmsEndpoint).updateCourse(
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
              ) async => (endpoints['lms'] as _i6.LmsEndpoint).deleteCourse(
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
              ) async => (endpoints['lms'] as _i6.LmsEndpoint).getCourseById(
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
              type: _i1.getType<_i11.CourseVisibility?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i6.LmsEndpoint).listCourses(
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
              type: _i1.getType<_i12.KnowledgeFile>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i6.LmsEndpoint).addFileToCourse(
                session,
                params['file'],
              ),
        ),
        'processFileEmbedding': _i1.MethodConnector(
          name: 'processFileEmbedding',
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
              ) async =>
                  (endpoints['lms'] as _i6.LmsEndpoint).processFileEmbedding(
                    session,
                    params['fileId'],
                  ),
        ),
        'processAllFileEmbeddings': _i1.MethodConnector(
          name: 'processAllFileEmbeddings',
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
              ) async => (endpoints['lms'] as _i6.LmsEndpoint)
                  .processAllFileEmbeddings(
                    session,
                    params['courseId'],
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
                  (endpoints['lms'] as _i6.LmsEndpoint).getFilesForCourse(
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
              ) async => (endpoints['lms'] as _i6.LmsEndpoint).deleteFile(
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
              ) async => (endpoints['lms'] as _i6.LmsEndpoint).getModules(
                session,
                params['courseId'],
              ),
        ),
        'createModule': _i1.MethodConnector(
          name: 'createModule',
          params: {
            'module': _i1.ParameterDescription(
              name: 'module',
              type: _i1.getType<_i13.Module>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i6.LmsEndpoint).createModule(
                session,
                params['module'],
              ),
        ),
        'updateModule': _i1.MethodConnector(
          name: 'updateModule',
          params: {
            'module': _i1.ParameterDescription(
              name: 'module',
              type: _i1.getType<_i13.Module>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i6.LmsEndpoint).updateModule(
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
              ) async => (endpoints['lms'] as _i6.LmsEndpoint).deleteModule(
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
              ) async => (endpoints['lms'] as _i6.LmsEndpoint).deleteAllModules(
                session,
                params['courseId'],
              ),
        ),
        'createTopic': _i1.MethodConnector(
          name: 'createTopic',
          params: {
            'topic': _i1.ParameterDescription(
              name: 'topic',
              type: _i1.getType<_i14.Topic>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i6.LmsEndpoint).createTopic(
                session,
                params['topic'],
              ),
        ),
        'updateTopic': _i1.MethodConnector(
          name: 'updateTopic',
          params: {
            'topic': _i1.ParameterDescription(
              name: 'topic',
              type: _i1.getType<_i14.Topic>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i6.LmsEndpoint).updateTopic(
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
              ) async => (endpoints['lms'] as _i6.LmsEndpoint).getTopicById(
                session,
                params['id'],
              ),
        ),
        'createModuleItem': _i1.MethodConnector(
          name: 'createModuleItem',
          params: {
            'moduleItem': _i1.ParameterDescription(
              name: 'moduleItem',
              type: _i1.getType<_i15.ModuleItem>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i6.LmsEndpoint).createModuleItem(
                session,
                params['moduleItem'],
              ),
        ),
        'updateModuleItem': _i1.MethodConnector(
          name: 'updateModuleItem',
          params: {
            'moduleItem': _i1.ParameterDescription(
              name: 'moduleItem',
              type: _i1.getType<_i15.ModuleItem>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i6.LmsEndpoint).updateModuleItem(
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
              ) async => (endpoints['lms'] as _i6.LmsEndpoint).deleteModuleItem(
                session,
                params['moduleItemId'],
              ),
        ),
        'generateCourseTableOfContents': _i1.MethodConnector(
          name: 'generateCourseTableOfContents',
          params: {
            'courseId': _i1.ParameterDescription(
              name: 'courseId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'customPrompt': _i1.ParameterDescription(
              name: 'customPrompt',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lms'] as _i6.LmsEndpoint)
                  .generateCourseTableOfContents(
                    session,
                    params['courseId'],
                    customPrompt: params['customPrompt'],
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
                  (endpoints['lms'] as _i6.LmsEndpoint).getUploadDescription(
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
              ) async => (endpoints['lms'] as _i6.LmsEndpoint).verifyUpload(
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
              ) async => (endpoints['lms'] as _i6.LmsEndpoint).getPublicUrl(
                session,
                params['path'],
              ),
        ),
        'findRelevantKnowledge': _i1.MethodConnector(
          name: 'findRelevantKnowledge',
          params: {
            'query': _i1.ParameterDescription(
              name: 'query',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'courseId': _i1.ParameterDescription(
              name: 'courseId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'similarityThreshold': _i1.ParameterDescription(
              name: 'similarityThreshold',
              type: _i1.getType<double>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['lms'] as _i6.LmsEndpoint).findRelevantKnowledge(
                    session,
                    params['query'],
                    params['courseId'],
                    limit: params['limit'],
                    similarityThreshold: params['similarityThreshold'],
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
                  (endpoints['vedaUserProfile'] as _i7.VedaUserProfileEndpoint)
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
                  (endpoints['vedaUserProfile'] as _i7.VedaUserProfileEndpoint)
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
                  (endpoints['vedaUserProfile'] as _i7.VedaUserProfileEndpoint)
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
                  (endpoints['vedaUserProfile'] as _i7.VedaUserProfileEndpoint)
                      .getMyProfileWithEmail(session),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i16.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i17.Endpoints()
      ..initializeEndpoints(server);
  }
}
