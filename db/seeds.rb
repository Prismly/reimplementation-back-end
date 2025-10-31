# frozen_string_literal: true

begin
    #Create an instritution
    inst_id = Institution.create!(
      name: 'North Carolina State University',
    ).id
    
    # Create an admin user
    User.create!(
      name: 'admin',
      email: 'admin2@example.com',
      password: 'password123',
      full_name: 'admin admin',
      institution_id: 1,
      role_id: 1
    )
    

    #Generate Random Users
    num_students = 48
    num_assignments = 8
    num_teams = 16
    num_courses = 2
    num_instructors = 2
    
    puts "creating instructors"
    instructor_user_ids = []
    num_instructors.times do
      instructor_user_ids << User.create(
        name: Faker::Internet.unique.username,
        email: Faker::Internet.unique.email,
        password: "password",
        full_name: Faker::Name.name,
        institution_id: 1,
        role_id: 3,
      ).id
    end

    puts "creating courses"
    course_ids = []
    num_courses.times do |i|
      course_ids << Course.create(
        instructor_id: instructor_user_ids[i],
        institution_id: inst_id,
        directory_path: Faker::File.dir(segment_count: 2),
        name: Faker::Company.industry,
        info: "A fake class",
        private: false
      ).id
    end

    puts "creating assignments"
    assignment_ids = []
    num_assignments.times do |i|
      assignment_ids << Assignment.create(
        name: Faker::Verb.base,
        instructor_id: instructor_user_ids[i%num_instructors],
        course_id: course_ids[i%num_courses],
        has_teams: true,
        private: false
      ).id
    end
  puts "creating questionnaires and items"
  questionnaire_ids = []

  num_assignments.times do |i|
    # Create a questionnaire for each assignment
    begin
      q = Questionnaire.create!(
        name: "Questionnaire #{i + 1}",
        instructor_id: instructor_user_ids[i % num_instructors],
        private: false,
        min_question_score: 0,
        max_question_score: 5,
        questionnaire_type: 'Review',
        display_type: 'Dropdown',
        instruction_loc: 'No instructions',
      )
      questionnaire_ids << q.id

      # Add 3 simple items/questions per questionnaire
      3.times do |j|
        Item.create!(
          txt: "Question #{j + 1} for Questionnaire #{i + 1}",
          weight: 1,
          seq: j + 1,
          question_type: 'Criterion',
          size: 'Medium',
          questionnaire_id: q.id
        )
      end

      # Link questionnaire to assignment safely
      aq = AssignmentQuestionnaire.create(
        assignment_id: assignment_ids[i % num_assignments],
        questionnaire_id: q.id,
        used_in_round: 1
      )

      if aq.persisted?
        puts "Linked Assignment #{assignment_ids[i % num_assignments]} with Questionnaire #{q.id}"
      else
        puts "Failed to link AssignmentQuestionnaire: #{aq.errors.full_messages.join(', ')}"
      end

    rescue ActiveRecord::RecordInvalid => e
      puts "Failed to create questionnaire or items: #{e.record.errors.full_messages.join(', ')}"
    end
  end


    puts "creating teams"
    team_ids = []
    num_teams.times do |i|
      team_ids << AssignmentTeam.create(
        name: "Team #{i + 1}",
        parent_id: assignment_ids[i%num_assignments]
      ).id
    end

    puts "creating students"
    student_user_ids = []
    num_students.times do
      student_user_ids << User.create(
        name: Faker::Internet.unique.username,
        email: Faker::Internet.unique.email,
        password: "password",
        full_name: Faker::Name.name,
        institution_id: 1,
        role_id: 5,
      ).id
    end

    puts "assigning students to teams"
    teams_users_ids = []
    #num_students.times do |i|
    #  teams_users_ids << TeamsUser.create(
    #    team_id: team_ids[i%num_teams],
    #    user_id: student_user_ids[i]
    #  ).id
    #end

    num_students.times do |i|
      puts "Creating TeamsUser with team_id: #{team_ids[i % num_teams]}, user_id: #{student_user_ids[i]}"
      teams_user = TeamsUser.create(
        team_id: team_ids[i % num_teams],
        user_id: student_user_ids[i]
      )
      if teams_user.persisted?
        teams_users_ids << teams_user.id
        puts "Created TeamsUser with ID: #{teams_user.id}"
      else
        puts "Failed to create TeamsUser: #{teams_user.errors.full_messages.join(', ')}"
      end
    end

    puts "assigning participant to students, teams, courses, and assignments"
    participant_ids = []
    num_students.times do |i|
      participant_ids << AssignmentParticipant.create(
        user_id: student_user_ids[i],
        parent_id: assignment_ids[i%num_assignments],
        team_id: team_ids[i%num_teams],
      ).id
    end








rescue ActiveRecord::RecordInvalid => e
    puts 'The db has already been seeded'
end
