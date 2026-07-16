import 'package:dio/dio.dart';

/// A Mock Dio Interceptor that intercepts all outgoing HTTP requests and
/// satisfies them with local, mock responses. This enables frontend development,
/// verification, and UI testing without needing a running backend.
class MockInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.path;
    final method = options.method;

    // Helper to wrap response in standard API envelope
    Response successResponse(dynamic data) {
      return Response(
        requestOptions: options,
        data: {
          'status': 'success',
          'data': data,
        },
        statusCode: 200,
      );
    }

    // POST /auth/login
    if (path.contains('/auth/login')) {
      final body = options.data as Map<String, dynamic>? ?? {};
      final email = body['email'] as String? ?? 'admin@ams.com';

      String role = 'admin';
      String name = 'Jane Admin (Mock)';
      if (email.contains('teacher')) {
        role = 'teacher';
        name = 'Tanya Teacher (Mock)';
      } else if (email.contains('student')) {
        role = 'student';
        name = 'Sammy Student (Mock)';
      } else if (email.contains('parent')) {
        role = 'parent';
        name = 'Patricia Parent (Mock)';
      }

      return handler.resolve(successResponse({
        'access_token': 'mock_access_token_$role',
        'refresh_token': 'mock_refresh_token_$role',
        'user': {
          'id': 'mock-user-$role',
          'name': name,
          'role': role,
          'email': email,
          'phone': '9876543210',
          'status': 'active',
          'institute_id': 'mock-institute-1',
        }
      }));
    }

    // GET /auth/me
    if (path.contains('/auth/me')) {
      final authHeader = options.headers['Authorization'] as String? ?? '';

      String role = 'admin';
      String name = 'Jane Admin (Mock)';
      if (authHeader.contains('teacher')) {
        role = 'teacher';
        name = 'Tanya Teacher (Mock)';
      } else if (authHeader.contains('student')) {
        role = 'student';
        name = 'Sammy Student (Mock)';
      } else if (authHeader.contains('parent')) {
        role = 'parent';
        name = 'Patricia Parent (Mock)';
      }

      return handler.resolve(successResponse({
        'id': 'mock-user-$role',
        'name': name,
        'role': role,
        'email': '$role@ams.com',
        'phone': '9876543210',
        'status': 'active',
        'institute_id': 'mock-institute-1',
      }));
    }

    // POST /auth/logout or /auth/refresh
    if (path.contains('/auth/logout') || path.contains('/auth/refresh')) {
      return handler.resolve(successResponse({}));
    }

    // GET /dashboard/owner/
    if (path.contains('/dashboard/owner')) {
      return handler.resolve(successResponse({
        'date': '2026-07-16',
        'todays_attendance_marked_batches': 4,
        'todays_attendance_pending_batches': 2,
        'students_present_today': 120,
        'students_absent_today': 15,
        'attendance_percentage_today': 88.8,
        'new_admissions_this_month': 12,
        'pending_fees_amount': 45000,
        'pending_fees_students_count': 5,
        'todays_batches': [
          {
            'id': 'batch-1',
            'name': 'Grade 10 - Mathematics',
            'subject_name': 'Mathematics',
            'teacher_name': 'Tanya Teacher (Mock)',
            'start_time': '09:00',
            'end_time': '10:30',
            'standard': '10th Standard',
            'student_count': 25,
          },
          {
            'id': 'batch-2',
            'name': 'Grade 10 - Physics',
            'subject_name': 'Physics',
            'teacher_name': 'Paul Physics (Mock)',
            'start_time': '11:00',
            'end_time': '12:30',
            'standard': '10th Standard',
            'student_count': 24,
          },
          {
            'id': 'batch-3',
            'name': 'Grade 12 - Chemistry',
            'subject_name': 'Chemistry',
            'teacher_name': 'Chris Chemistry (Mock)',
            'start_time': '14:00',
            'end_time': '15:30',
            'standard': '12th Standard',
            'student_count': 30,
          }
        ]
      }));
    }

    // GET/POST/PUT /institutes/
    if (path.startsWith('/institutes')) {
      final segments = path.split('/').where((s) => s.isNotEmpty).toList();
      if (segments.length > 1 && segments[1] != 'create') {
        // GET detail
        return handler.resolve(successResponse({
          'id': segments[1],
          'name': 'Inittutor Coaching Institute (Mock)',
          'address': '123 Main Street',
          'city': 'Mumbai',
          'state': 'Maharashtra',
          'pincode': '400001',
          'phone': '9876543210',
          'email': 'contact@inittutor.com',
          'website': 'www.inittutor.com',
          'timezone': 'Asia/Kolkata',
          'status': 'active',
        }));
      } else {
        // GET list or POST create
        if (method == 'POST') {
          final body = options.data as Map<String, dynamic>? ?? {};
          return handler.resolve(successResponse({
            'id': 'mock-new-institute',
            ...body,
            'timezone': 'Asia/Kolkata',
            'status': 'active',
          }));
        }
        return handler.resolve(successResponse([
          {
            'id': 'mock-institute-1',
            'name': 'Inittutor Coaching Institute (Mock)',
            'address': '123 Main Street',
            'city': 'Mumbai',
            'state': 'Maharashtra',
            'pincode': '400001',
            'phone': '9876543210',
            'email': 'contact@inittutor.com',
            'website': 'www.inittutor.com',
            'timezone': 'Asia/Kolkata',
            'status': 'active',
          }
        ]));
      }
    }

    // GET/POST/PUT/DELETE /teachers/
    if (path.startsWith('/teachers')) {
      final segments = path.split('/').where((s) => s.isNotEmpty).toList();
      if (segments.length > 1) {
        // detail/update/delete
        final id = segments[1];
        if (method == 'DELETE') {
          return handler.resolve(Response(requestOptions: options, statusCode: 204));
        }
        final body = options.data as Map<String, dynamic>? ?? {};
        return handler.resolve(successResponse({
          'id': id,
          'user': {
            'id': 'user-$id',
            'full_name': body['full_name'] as String? ?? 'Teacher $id (Mock)',
            'phone': body['phone'] as String? ?? '9876543210',
            'email': body['email'] as String? ?? 'teacher_$id@ams.com',
            'status': 'active',
          },
          'employee_code': body['employee_code'] as String? ?? 'EMP-$id',
          'specialization': body['specialization'] as String? ?? 'Mathematics',
          'joining_date': body['joining_date'] as String? ?? '2025-01-01',
          'status': 'active',
        }));
      } else {
        // list or create
        if (method == 'POST') {
          final body = options.data as Map<String, dynamic>? ?? {};
          return handler.resolve(successResponse({
            'id': 'teacher-new',
            'user': {
              'id': 'user-teacher-new',
              'full_name': body['full_name'] ?? 'New Teacher (Mock)',
              'phone': body['phone'] ?? '9876543210',
              'email': body['email'] ?? 'new_teacher@ams.com',
              'status': 'active',
            },
            'employee_code': body['employee_code'] ?? 'EMP-NEW',
            'specialization': body['specialization'] ?? 'General',
            'joining_date': body['joining_date'] ?? '2026-07-16',
            'status': 'active',
          }));
        }
        return handler.resolve(successResponse({
          'count': 3,
          'next': null,
          'previous': null,
          'results': [
            {
              'id': 'teacher-1',
              'user': {
                'id': 'user-teacher-1',
                'full_name': 'Tanya Teacher (Mock)',
                'phone': '9876543211',
                'email': 'tanya@ams.com',
                'status': 'active',
              },
              'employee_code': 'EMP-001',
              'specialization': 'Mathematics',
              'joining_date': '2025-01-01',
              'status': 'active',
            },
            {
              'id': 'teacher-2',
              'user': {
                'id': 'user-teacher-2',
                'full_name': 'Paul Physics (Mock)',
                'phone': '9876543212',
                'email': 'paul@ams.com',
                'status': 'active',
              },
              'employee_code': 'EMP-002',
              'specialization': 'Physics',
              'joining_date': '2025-02-01',
              'status': 'active',
            },
            {
              'id': 'teacher-3',
              'user': {
                'id': 'user-teacher-3',
                'full_name': 'Chris Chemistry (Mock)',
                'phone': '9876543213',
                'email': 'chris@ams.com',
                'status': 'active',
              },
              'employee_code': 'EMP-003',
              'specialization': 'Chemistry',
              'joining_date': '2025-03-01',
              'status': 'active',
            }
          ]
        }));
      }
    }

    // GET/POST/PUT/DELETE /students/
    if (path.startsWith('/students')) {
      final segments = path.split('/').where((s) => s.isNotEmpty).toList();
      if (segments.length > 1) {
        final id = segments[1];
        if (method == 'DELETE') {
          return handler.resolve(Response(requestOptions: options, statusCode: 204));
        }
        final body = options.data as Map<String, dynamic>? ?? {};
        return handler.resolve(successResponse({
          'id': id,
          'roll_number': body['roll_number'] as String? ?? 'ROLL-$id',
          'admission_date': body['admission_date'] as String? ?? '2025-06-01',
          'first_name': body['first_name'] as String? ?? 'Student',
          'last_name': body['last_name'] as String? ?? id.toUpperCase(),
          'phone': body['phone'] as String? ?? '9876543220',
          'parent_phone': body['parent_phone'] as String? ?? '9876543221',
          'email': body['email'] as String? ?? 'student_$id@ams.com',
          'address': body['address'] as String? ?? '456 Student Lane',
          'school': body['school'] as String? ?? 'Model High School',
          'standard': body['standard'] as String? ?? '10th Standard',
          'status': body['status'] as String? ?? 'active',
          'primary_parent': {
            'full_name': 'Patricia Parent $id (Mock)',
            'phone': body['parent_phone'] as String? ?? '9876543221',
            'relation': 'mother',
            'is_primary': true,
          }
        }));
      } else {
        if (method == 'POST') {
          final body = options.data as Map<String, dynamic>? ?? {};
          return handler.resolve(successResponse({
            'id': 'student-new',
            'roll_number': body['roll_number'] ?? 'ROLL-NEW',
            'admission_date': body['admission_date'] ?? '2026-07-16',
            'first_name': body['first_name'] ?? 'New',
            'last_name': body['last_name'] ?? 'Student (Mock)',
            'phone': body['phone'],
            'parent_phone': body['parent_phone'] ?? '9876543221',
            'email': body['email'],
            'address': body['address'],
            'school': body['school'],
            'standard': body['standard'] ?? '10th Standard',
            'status': 'active',
            'primary_parent': {
              'full_name': 'Patricia Parent (Mock)',
              'phone': body['parent_phone'] ?? '9876543221',
              'relation': 'mother',
              'is_primary': true,
            }
          }));
        }
        return handler.resolve(successResponse({
          'count': 3,
          'next': null,
          'previous': null,
          'results': [
            {
              'id': 'student-1',
              'roll_number': 'ROLL-001',
              'admission_date': '2025-06-01',
              'first_name': 'Sammy',
              'last_name': 'Student (Mock)',
              'phone': '9876543220',
              'parent_phone': '9876543221',
              'email': 'sammy@ams.com',
              'address': '456 Student Lane',
              'school': 'Model High School',
              'standard': '10th Standard',
              'status': 'active',
              'primary_parent': {
                'full_name': 'Patricia Parent (Mock)',
                'phone': '9876543221',
                'relation': 'mother',
                'is_primary': true,
              }
            },
            {
              'id': 'student-2',
              'roll_number': 'ROLL-002',
              'admission_date': '2025-06-02',
              'first_name': 'Alice',
              'last_name': 'Baker (Mock)',
              'phone': '9876543222',
              'parent_phone': '9876543223',
              'email': 'alice@ams.com',
              'address': '789 Academy Road',
              'school': 'St. Xavier School',
              'standard': '10th Standard',
              'status': 'active',
              'primary_parent': {
                'full_name': 'Arthur Baker (Mock)',
                'phone': '9876543223',
                'relation': 'father',
                'is_primary': true,
              }
            },
            {
              'id': 'student-3',
              'roll_number': 'ROLL-003',
              'admission_date': '2025-06-03',
              'first_name': 'Bob',
              'last_name': 'Charlie (Mock)',
              'phone': '9876543224',
              'parent_phone': '9876543225',
              'email': 'bob@ams.com',
              'address': '101 Campus Boulevard',
              'school': 'City Public School',
              'standard': '12th Standard',
              'status': 'active',
              'primary_parent': {
                'full_name': 'Beatrice Charlie (Mock)',
                'phone': '9876543225',
                'relation': 'mother',
                'is_primary': true,
              }
            }
          ]
        }));
      }
    }

    // Media Upload
    if (path.contains('/media/upload')) {
      return handler.resolve(successResponse({
        'url': 'https://picsum.photos/200',
      }));
    }

    // Batches endpoints
    if (path.startsWith('/batches')) {
      final segments = path.split('/').where((s) => s.isNotEmpty).toList();

      // GET /batches/subjects/
      if (path.contains('/batches/subjects')) {
        return handler.resolve(successResponse([
          {'id': 'sub-maths', 'name': 'Mathematics'},
          {'id': 'sub-physics', 'name': 'Physics'},
          {'id': 'sub-chemistry', 'name': 'Chemistry'},
        ]));
      }

      // GET /batches/classrooms/
      if (path.contains('/batches/classrooms')) {
        return handler.resolve(successResponse([
          {'id': 'room-101', 'name': 'Room 101', 'capacity': 30},
          {'id': 'room-102', 'name': 'Room 102', 'capacity': 40},
          {'id': 'room-lab', 'name': 'Science Lab', 'capacity': 25},
        ]));
      }

      // GET/PUT/DELETE /batches/:id/
      if (segments.length > 1 && segments[1] != 'subjects' && segments[1] != 'classrooms') {
        final id = segments[1];

        if (method == 'DELETE') {
          return handler.resolve(Response(requestOptions: options, statusCode: 204));
        }

        // Return Batch + Roster details
        return handler.resolve(successResponse({
          'batch': {
            'id': id,
            'name': 'Mock Batch $id',
            'subject': {'id': 'sub-maths', 'name': 'Mathematics'},
            'teacher': {
              'id': 'teacher-1',
              'user': {
                'id': 'user-teacher-1',
                'full_name': 'Tanya Teacher (Mock)',
                'phone': '9876543211',
                'email': 'tanya@ams.com',
                'status': 'active',
              },
              'employee_code': 'EMP-001',
              'specialization': 'Mathematics',
              'joining_date': '2025-01-01',
              'status': 'active',
            },
            'classroom': {'id': 'room-101', 'name': 'Room 101', 'capacity': 30},
            'standard': '10th Standard',
            'capacity': 30,
            'status': 'active',
            'schedules': [
              {
                'id': 'sched-1',
                'day_of_week': 'mon',
                'start_time': '09:00',
                'end_time': '10:30',
              },
              {
                'id': 'sched-2',
                'day_of_week': 'wed',
                'start_time': '09:00',
                'end_time': '10:30',
              }
            ]
          },
          'roster': [
            {
              'id': 'roster-1',
              'student': {
                'id': 'student-1',
                'roll_number': 'ROLL-001',
                'admission_date': '2025-06-01',
                'first_name': 'Sammy',
                'last_name': 'Student (Mock)',
                'phone': '9876543220',
                'parent_phone': '9876543221',
                'email': 'sammy@ams.com',
                'address': '456 Student Lane',
                'school': 'Model High School',
                'standard': '10th Standard',
                'status': 'active',
              },
              'enrolled_on': '2025-06-01',
              'status': 'active',
            },
            {
              'id': 'roster-2',
              'student': {
                'id': 'student-2',
                'roll_number': 'ROLL-002',
                'admission_date': '2025-06-02',
                'first_name': 'Alice',
                'last_name': 'Baker (Mock)',
                'phone': '9876543222',
                'parent_phone': '9876543223',
                'email': 'alice@ams.com',
                'address': '789 Academy Road',
                'school': 'St. Xavier School',
                'standard': '10th Standard',
                'status': 'active',
              },
              'enrolled_on': '2025-06-02',
              'status': 'active',
            }
          ]
        }));
      } else {
        // GET list or POST create
        if (method == 'POST') {
          final body = options.data as Map<String, dynamic>? ?? {};
          return handler.resolve(successResponse({
            'id': 'batch-new',
            'name': body['name'] ?? 'New Batch (Mock)',
            'subject': {'id': body['subject_id'] ?? 'sub-maths', 'name': 'Mathematics'},
            'teacher': {
              'id': body['teacher_id'] ?? 'teacher-1',
              'user': {
                'id': 'user-teacher-1',
                'full_name': 'Tanya Teacher (Mock)',
                'phone': '9876543211',
                'email': 'tanya@ams.com',
                'status': 'active',
              },
              'employee_code': 'EMP-001',
              'specialization': 'Mathematics',
              'joining_date': '2025-01-01',
              'status': 'active',
            },
            'classroom': {'id': body['classroom_id'] ?? 'room-101', 'name': 'Room 101', 'capacity': 30},
            'standard': body['standard'] ?? '10th Standard',
            'capacity': body['capacity'] ?? 30,
            'status': 'active',
            'schedules': []
          }));
        }
        return handler.resolve(successResponse({
          'count': 2,
          'next': null,
          'previous': null,
          'results': [
            {
              'id': 'batch-1',
              'name': 'Grade 10 - Mathematics',
              'subject': {'id': 'sub-maths', 'name': 'Mathematics'},
              'teacher': {
                'id': 'teacher-1',
                'user': {
                  'id': 'user-teacher-1',
                  'full_name': 'Tanya Teacher (Mock)',
                  'phone': '9876543211',
                  'email': 'tanya@ams.com',
                  'status': 'active',
                },
                'employee_code': 'EMP-001',
                'specialization': 'Mathematics',
                'joining_date': '2025-01-01',
                'status': 'active',
              },
              'classroom': {'id': 'room-101', 'name': 'Room 101', 'capacity': 30},
              'standard': '10th Standard',
              'capacity': 30,
              'status': 'active',
              'schedules': [
                {
                  'id': 'sched-1',
                  'day_of_week': 'mon',
                  'start_time': '09:00',
                  'end_time': '10:30',
                }
              ]
            },
            {
              'id': 'batch-2',
              'name': 'Grade 10 - Physics',
              'subject': {'id': 'sub-physics', 'name': 'Physics'},
              'teacher': {
                'id': 'teacher-2',
                'user': {
                  'id': 'user-teacher-2',
                  'full_name': 'Paul Physics (Mock)',
                  'phone': '9876543212',
                  'email': 'paul@ams.com',
                  'status': 'active',
                },
                'employee_code': 'EMP-002',
                'specialization': 'Physics',
                'joining_date': '2025-02-01',
                'status': 'active',
              },
              'classroom': {'id': 'room-102', 'name': 'Room 102', 'capacity': 40},
              'standard': '10th Standard',
              'capacity': 40,
              'status': 'active',
              'schedules': [
                {
                  'id': 'sched-3',
                  'day_of_week': 'tue',
                  'start_time': '11:00',
                  'end_time': '12:30',
                }
              ]
            }
          ]
        }));
      }
    }

    // Default fallback (let request go through)
    return handler.next(options);
  }
}
