#
#
#

class UserNameHandler
  def initialize owner_connection
    @owner = owner_connection
  end

  def prompt
    @owner.send_data "\n\nBy what name are you to be addressed?\n"
  end

  def handle_input line
    line = line.slice 0, 16
    if MUD::PlayerUtils.player_exists? line
      @owner.handler = PasswordHandler.new @owner, line
    else
      @owner.handler = NewPlayerStartHandler.new @owner, line
    end
  end

end

class NewPlayerStartHandler
  def initialize owner_connection, name
    @owner = owner_connection
    @name = name
  end

  def prompt
    @owner.send_data "\n\"#{@name.capitalize}\" is unfamiliar. Would you like to be known as #{@name}? (y/n)\n"
  end

  def handle_input line
    line = line.slice 0, 1
    if line == 'y'
      @owner.handler = NewPlayerPasswordHandler.new @owner, @name
    else
      @owner.handler = UserNameHandler.new @owner
    end
  end

end

class NewPlayerPasswordHandler
  def initialize owner_connection, name
    @owner = owner_connection
    @name = name
  end

  def prompt
    @owner.send_data "Excellent, #{@name}! Please provide a passphrase...\n"
  end

  def handle_input line
    line = line.slice 0, 16
    success = MUD::PlayerUtils.secure_player @name, line
    if success
      player = MUD::Entities::Player.new @name, @owner
      @owner.greet player
      player.add_soul MUD::Souls::DevSoul.new
      player.add_soul MUD::Souls::WizardSoul.new
      player.add_soul MUD::Souls::MortalSoul.new

      MUD::MUD.instance.add_player player.name, player
      start_zone = MUD::MUD.instance.loaded_zones[MUD::Settings.instance.start_zone]
      room = start_zone[MUD::Settings.instance.start_room]

      room.add_entity player
      player.zone = start_zone
      MUD::MUD.instance.add_connection player.name, @owner

      MUD::PlayerUtils.save_player player

      @owner.handler = LoggedInHandler.new @owner, player
    else
      puts "LOG ERROR!"
    end
  end

end

class PasswordHandler
  def initialize owner_connection, name
    @owner = owner_connection
    @name = name
  end

  def prompt
    @owner.send_data "Oh! Just to be certain: what is #{@name}'s passphrase?\n"
  end

  def handle_input line
    line = line.slice 0, 16

    player_data = MUD::PlayerUtils.load_player @name, line
    if player_data
      player = player_data[:player]
      zone_name = player_data[:zone_name]
      room_name = player_data[:room_name]
      player.connection = @owner
      @owner.greet player
      player.add_soul MUD::Souls::DevSoul.new
      player.add_soul MUD::Souls::WizardSoul.new
      player.add_soul MUD::Souls::MortalSoul.new

      MUD::MUD.instance.add_player player.name, player
      start_zone = MUD::MUD.instance.get_zone zone_name
      room = start_zone[room_name]
      room.add_entity player
      player.zone = start_zone
      MUD::MUD.instance.add_connection player.name, @owner

      @owner.handler = LoggedInHandler.new @owner, player
    else
      @owner.send_data "\nSadly, that is not correct."
      @owner.handler = UserNameHandler.new @owner
    end
  end

end

class LoggedInHandler
  def initialize owner_connection, player
    @owner = owner_connection
    @owner.player = player
  end

  def prompt

  end

  def handle_input line
    @owner.player.handle_input line
  end

end
