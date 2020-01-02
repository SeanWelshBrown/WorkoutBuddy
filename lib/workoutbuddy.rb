require "tty-prompt"
require "pry"

PROMPT = TTY::Prompt.new

class WorkoutBuddy

  @@current_user = nil
  attr_accessor :current_user

#*** RUNNER METHOD ***#

  def run 
    greet
    login
    sleep 2
    main_menu
  end

#~~~ GENERAL METHODS ~~~#

  def greet
    system 'clear'
    puts "Welcome to WorkoutBuddy, your source for quality exercise tips and your very own personal workout tracker!"
    puts "\n"
  end

  def exit_app
    input = PROMPT.select('Are you sure you want to exit?', ["Yes", "No"], cycle: true)
    if input == "Yes"
      puts "So long for now!"
      abort
    elsif input == "No"
      system 'clear'
      go_to_previous_menu(1)
    end
  end

  def exit_check(input)
    if input == "exit"
      exit_app
    end
  end

  def find_user_by_username(input)
    User.find_by(username: input)
  end

  def go_to_previous_menu(caller_num) # MAKE BLOG POST ABOUT THIS #
    previous_method = caller[caller_num].split("`").pop.gsub("'", "")
    previous_method.to_sym

    # previous_method = caller[1].label
    # previous_method.to_sym
    send(previous_method)
  end

#~~~ LOGIN METHODS ~~~#

  def login
    input = PROMPT.select("Please log in to your existing account, or create a new account if you are a new user. (It's easy, we promise!)", ["Log in", "Create an Account", "Exit Application"], cycle: true)

    if input == "Log in"
      log_into_account
    elsif input == "Create an Account"
      puts "Thank you for choosing to create an account!"
      create_account
    elsif input == "Exit Application"
      exit_app
    end
  end

  def log_into_account
    system 'clear'
    input = PROMPT.ask("Please enter your Username, or 'create account' to create a new account. You may also enter 'exit' to exit the program.", convert: :string, required: true)
    if input == "create account"
      create_account
    end
    exit_check(input)

    user_check = find_user_by_username(input)
    if user_check
      @@current_user = user_check
      puts "Successfully logged in. Nice to see you again, #{@@current_user.first_name}!"
    elsif !user_check
      puts "No User Account found with that Username. Please try again."
      log_into_account
    end
  end

  def create_account
    system 'clear'

    username = nil
    first_name = nil
    last_name = nil
    age = nil

    input1 = PROMPT.ask("Please enter a Username. You may use only upper and lower case letters, as well as numbers. You may also enter 'exit' to exit the program.", convert: :string, required: true)

    if input1.index( /[^[:alnum:]]/ ) || input1.include?(" ")
      puts "Username contains invalid characters."
      create_account
    end
    exit_check(input1)

    user_check = find_user_by_username(input1)

    if user_check
      puts "This Username already exists."
      create_account
    elsif !user_check
      username = input1
      first_name = PROMPT.ask("Please enter your first name:", default: nil, convert: :string, required: true)
      exit_check(first_name)
      last_name = PROMPT.ask("Please enter your last name:", default: nil, convert: :string, required: true)
      exit_check(last_name)
      age = PROMPT.ask("Please enter your current age:", default: nil, convert: :int, required: true)
      exit_check(age)
      
      sleep 1.5

      @@current_user = User.create(username: username, first_name: first_name, last_name: last_name, age: age)
      puts "Account successfully created! You are now logged in as #{username}."
    end

  end

#~~~ MAIN MENU ~~~#

  def main_menu
    system 'clear'

    puts "*--- MAIN MENU ---*"
    puts "\n"

    input = PROMPT.select("Please select an option to navigate, #{@@current_user.first_name}:", ["View Exercises", "View/Edit Your Saved Exercises", "Edit Account Information", "Log Out (#{@@current_user.username})", "Exit Application"], cycle: true)

    if input == "View Exercises"
      view_exercises
    elsif input == "View/Edit Your Saved Exercises"
      view_edit_saved_exercises
    elsif input == "Edit Account Information"

    elsif input == "Log Out (#{@@current_user.username})"
      @@current_user = nil
      system 'clear'
      run
    elsif input == "Exit Application"
      exit_app
    end
  end

#~~~ 'VIEW EXERCISES' ~~~#

    #--- GENERAL EXERCISE METHODS ---#

  def find_exercise_by_type(input)
    Exercise.where("exercise_type = '#{input}'")
  end

  def find_exercise_by_body_part(input)
    Exercise.where(["exercise_type = ? and body_part = ?", "Strength", "#{input}"])
  end

  def user_exercise_checker(user, exercise)
    UserExercise.find_by(user_id: user, exercise_id: exercise)
  end

  def display_exercise_info(exercise_name, current_menu)
    system 'clear'

    exercise = Exercise.find_by(name: exercise_name)
    puts "Name: #{exercise.name}"
    puts "\n"
    puts "Body Part: #{exercise.body_part}"
    puts "\n"
    puts "Muscle Group: #{exercise.muscle_group}"
    puts "\n"
    puts "Description:"
    puts "\n"
    puts exercise.description
    puts "\n"

    sleep 1

    input = PROMPT.select("What would you like to do?", ["Add this exercise to my workout list", "\u{2b05}  Go back to previous menu"], cycle: true)
    
    if input == "Add this exercise to my workout list"
      if user_exercise_checker(@@current_user.id, exercise.id)
        system 'clear'
        input = PROMPT.select("This exercise is already in your workout list.", ["\u{2b05}  Go back to previous menu"])
        if input
          menu = current_menu.to_sym
          send(menu)
        end
      elsif !user_exercise_checker(@@current_user.id, exercise.id)
        UserExercise.create(user_id: @@current_user.id, exercise_id: exercise.id)
        input = PROMPT.select("Exercise successfully saved!", ["\u{2b05}  Go back to previous menu"])
        if input
          menu = current_menu.to_sym
          send(menu)
        end
      end
    elsif input == "\u{2b05}  Go back to previous menu"
      menu = current_menu.to_sym
      send(menu)
    end
  end

  def display_or_remove_exercise(exercise_name, current_menu)
    system 'clear'

    exercise = Exercise.find_by(name: exercise_name)
    puts "Name: #{exercise.name}"
    puts "\n"
    puts "Body Part: #{exercise.body_part}"
    puts "\n"
    puts "Muscle Group: #{exercise.muscle_group}"
    puts "\n"
    puts "Description:"
    puts "\n"
    puts exercise.description
    puts "\n"

    sleep 1

    input = PROMPT.select("What would you like to do?", ["\u{1f6ab}  Remove this exercise from my workout list", "\u{2b05}  Go back to previous menu"], cycle: true)
    
    if input == "\u{1f6ab}  Remove this exercise from my workout list"
      system 'clear'
      input2 = PROMPT.select("Are you sure you want to remove this exercise from your list?", ["Yes", "No"])
      if input2 == "Yes"
        sleep 1
        remove_exercise(exercise)
        input3 = PROMPT.select("Exercise successfully removed.", ["\u{2b05}  Go back to previous menu"])
        if input3
          menu = current_menu.to_sym
          send(menu)
        end
      elsif input2 == "No"
        menu = current_menu.to_sym
        send(menu)
      end
    elsif input == "\u{2b05}  Go back to previous menu"
      menu = current_menu.to_sym
      send(menu)
    end
  end

  def remove_exercise(exercise)
    UserExercise.find_by(user_id: @@current_user.id, exercise_id: exercise.id).destroy
  end

    #--- EXERCISE MENU ---#

  def view_exercises
    system 'clear'

    puts "*--- VIEW EXERCISES ---*"
    puts "\n"

    input = PROMPT.select("Would you like to learn about Strength Training or Cardio exercises?", ["Strength Training", "Cardio", "\u{2b05}  Go back to previous menu"], cycle: true)

    if input == "Strength Training"
      strength_training
    elsif input == "Cardio"
      cardio
    elsif input == "\u{2b05}  Go back to previous menu"
      main_menu
    end
  end

    #--- STRENGTH MENU ---#

  def strength_training
    system 'clear'

    puts "*--- STRENGTH TRAINING ---*"
    puts "\n"

    input = PROMPT.select("What part of the body would you like to focus on?", ["Upper Body", "Legs", "Core", "\u{2b05}  Go back to previous menu"], cycle: true)

    if input == "Upper Body"
      upper_body
    elsif input == "Legs"
      legs
    elsif input == "Core"
      core
    elsif input == "\u{2b05}  Go back to previous menu"
      view_exercises
    end
  end

  def upper_body
    system 'clear'

    upper_body_exercises = []
    upper_body_exercises << find_exercise_by_body_part("Arms")
    upper_body_exercises << find_exercise_by_body_part("Chest")
    upper_body_exercises << find_exercise_by_body_part("Shoulders")
    flatten_exercises = upper_body_exercises.flatten

    exercise_names = flatten_exercises.collect { |exercise| exercise.name }

    puts "*--- UPPER BODY ---*"
    puts "\n"

    input = PROMPT.select("Select an exercise for more information:", exercise_names, "\u{2b05}  Go back to previous menu", cycle: true)

    if input == "\u{2b05}  Go back to previous menu"
      strength_training
    else display_exercise_info(input, "upper_body")
    end
  end

  def legs
    system 'clear'

    leg_exercises = []
    leg_exercises << find_exercise_by_body_part("Upper Legs")
    leg_exercises << find_exercise_by_body_part("Lower Legs")
    flatten_exercises = leg_exercises.flatten

    exercise_names = flatten_exercises.collect { |exercise| exercise.name }

    puts "*--- LEGS ---*"
    puts "\n"

    input = PROMPT.select("Select an exercise for more information:", exercise_names, "\u{2b05}  Go back to previous menu", cycle: true)

    if input == "\u{2b05}  Go back to previous menu"
      strength_training
    else display_exercise_info(input, "legs")
    end
  end

  def core 
    system 'clear'

    core_exercises = []
    core_exercises << find_exercise_by_body_part("Abs")
    flatten_exercises = core_exercises.flatten

    exercise_names = flatten_exercises.collect { |exercise| exercise.name }

    puts "*--- CORE ---*"
    puts "\n"

    input = PROMPT.select("Select an exercise for more information:", exercise_names, "\u{2b05}  Go back to previous menu", cycle: true)

    if input == "\u{2b05}  Go back to previous menu"
      strength_training
    else display_exercise_info(input, "core")
    end
  end

    #--- CARDIO MENU ---#

  def cardio
    system 'clear'

    cardio_exercises = find_exercise_by_type("Cardio")

    exercise_names = cardio_exercises.collect { |exercise| exercise.name }

    puts "*-- CARDIO --*"
    puts "\n"

    input = PROMPT.select("Select an exercise for more information:", exercise_names, "\u{2b05}  Go back to previous menu", cycle: true)

    if input == "\u{2b05}  Go back to previous menu"
      view_exercises
    else display_exercise_info(input, "cardio")
    end
  end

#~~~ VIEW/EDIT SAVED EXERCISES ~~~*

  def view_edit_saved_exercises
    system 'clear'

    puts "*--- SAVED EXERCISES (YOUR WORKOUT) ---*"
    puts "\n"

    puts "Here is your current list of saved exercises, #{@@current_user.first_name}."
    puts "\n"
    puts "You may select an exercise to view its details again, or delete it from your list."
    puts "\n"

    saved_exercises = @@current_user.exercises
    saved_exercises.reload
    saved_exercise_names = saved_exercises.collect {|exercise| exercise.name}

    input = PROMPT.select("Select an exercise:", saved_exercise_names, "\u{1f6ab}  Delete entire list", "\u{2b05}  Go back to previous menu", cycle: true)
    if input == "\u{1f6ab}  Delete entire list"
      system 'clear'
      input2 = PROMPT.select("Are you sure you want to delete your entire workout list?", ["Yes", "No"])
      if input2 == "Yes"
        delete_list
      elsif input2 == "No"
        view_edit_saved_exercises
      end
    elsif input == "\u{2b05}  Go back to previous menu"
      main_menu
    else display_or_remove_exercise(input, "view_edit_saved_exercises")
    end
  end

    #--- DELETE WORKOUT LIST METHOD ---#

  def delete_list
    sleep 1
    UserExercise.where(user_id: @@current_user.id).destroy_all
    input = PROMPT.select("List successfully deleted.", ["\u{2b05}  Go back to previous menu"])
    if input
      view_edit_saved_exercises
    end
  end

#~~~ EDIT USER ACCOUNT INFORMATION ~~~#

end