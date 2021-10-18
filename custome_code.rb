require 'rubygems'
require 'gosu'

SCREEN_WIDTH = 430
SCREEN_HEIGHT = 720 + 120

module ZOrder
  BACKGROUND, FOOD, PLAYER, UI = *0..3
end


class Rider
  attr_accessor :score, :image, :minus, :plus, :vel_x, :vel_y, :angle, :x, :y

  def initialize()
    @image = Gosu::Image.new("media/rider.png")
    @minus = Gosu::Sample.new("sounds/minus.wav")
    @plus = Gosu::Sample.new("sounds/plus.wav")
    @vel_x = @vel_y = 3.0
    @x = @y = @angle = 0.0
    @score = 0
  end
end


def warp(rider, x, y)
  rider.x, rider.y = x, y
end

def move_left rider
  if (rider.x > 25)
    rider.x -= rider.vel_x
    rider.x %= SCREEN_WIDTH
  end

end

def move_right rider
  if (rider.x < SCREEN_WIDTH - 25)
    rider.x += rider.vel_x
    rider.x %= SCREEN_WIDTH
  end
end

def move_up rider
  if (rider.y > 70)
    rider.y -= rider.vel_y
    rider.y %= SCREEN_HEIGHT
  end
end

def move_down rider
  if (rider.y < 670)
    rider.y += rider.vel_y
    rider.y %= SCREEN_HEIGHT
  end
end

def draw_rider rider
  rider.image.draw_rot(rider.x, rider.y, ZOrder::PLAYER, rider.angle)
end

def collect_food(all_food, rider)
  all_food.reject! do |food|
    if Gosu.distance(rider.x, rider.y, food.x, food.y) < 75 
        rider.score += 1
        rider.plus.play
    else
        false
    end
  end
end

def met_object(all_object, rider)
  all_object.reject! do |object|
    if Gosu.distance(rider.x, rider.y, object.x, object.y) < 75 
        rider.score += -1
        rider.minus.play
    else
        false
    end
  end
end

class Food

  attr_accessor :x, :y, :image, :vel_x, :vel_y, :angle, :score, :type

  def initialize(image, type)
    @type = type
    @image = Gosu::Image.new(image)
    @vel_x = rand(-2 .. 2) 
    @vel_y = rand(-2 .. 2)
    @angle = 0.0
    @x = rand * 380
    @y = rand * SCREEN_HEIGHT - 120
    @score = 0
  end
end

def move food
  food.y += food.vel_y
  food.y %= SCREEN_HEIGHT - 120
end

def draw_food food
  food.image.draw_rot(food.x, food.y, ZOrder::FOOD, food.angle)
end

class Object
  attr_accessor :x, :y, :image, :vel_x, :vel_y, :angle, :score, :type

  def initialize(image, type)
    @type = type
    @image = Gosu::Image.new(image)
    @vel_y = rand(-2 .. 2)
    @vel_x = rand(-2 .. 2)
    @angle = 0.0
    @x = rand * SCREEN_WIDTH 
    @y = rand * SCREEN_HEIGHT - 120
    @score = 0
  end
end

def move object
  object.y += object.vel_y
  object.y %= SCREEN_HEIGHT - 120
end

def lv3_move object
  object.y += object.vel_y + 5
  object.y %= SCREEN_HEIGHT - 120
  object.x += object.vel_x
  object.x %= SCREEN_WIDTH
end 

def change_direction object
  object.vel_y = rand(-3 .. 3)
end

def draw_object object
  object.image.draw_rot(object.x, object.y, ZOrder::FOOD, object.angle)
end

class Notifications
  attr_accessor :x, :y, :image, :angle, :color, :scale_x, :scale_y

  def initialize(image)
    @image = Gosu::Image.new(image)
    @angle = 0.0
    @color = Gosu::Color.new(255, 255, 255, 255)
    @x = SCREEN_WIDTH - 215
    @y = SCREEN_HEIGHT - 60
    @scale_y = 1.0
    @scale_x = 1.0
  end
end

def draw_notification notification
  notification.image.draw_rot(notification.x, notification.y, ZOrder::UI, notification.angle, 0.5, 0.5, notification.scale_x, notification.scale_y, notification.color, mode=:default)
end

class Endscreen
  attr_accessor :x, :y, :image, :angle, :color, :scale_x, :scale_y

  def initialize()
    @x = 220
    @y = 350
    @image = Gosu::Image.new('media/endscreen.png')
    @angle = 0.0
    @color = Gosu::Color.new(255, 255, 255, 255)
    @scale_y = 1.0
    @scale_x = 1.0
  end
end

def draw_endscreen(endscreen)
  endscreen.image.draw_rot(endscreen.x, endscreen.y, ZOrder::UI, endscreen.angle, 0.5, 0.5, endscreen.scale_x, endscreen.scale_y, endscreen.color, mode=:default)
end

def update_end(endscreen)
  endscreen.color.alpha -= 1000
end

class RockRiderGame < (Example rescue Gosu::Window)
  def initialize
    super SCREEN_WIDTH, SCREEN_HEIGHT
    self.caption = "Rock Rider Extended"
    
    @background_image = Gosu::Image.new("media/background.png", :tileable => true)
    @background_music = Gosu::Song.new("sounds/bgmusic.mp3")
    @all_food = Array.new

    @all_object = Array.new
    # Food is created later in generate-food
    @all_notification = Array.new
    @endscreen = Endscreen.new()
    @player = Rider.new()

    warp(@player, SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)

    @font = Gosu::Font.new(20)
  end

def update
    if @player.score < 5
      if Gosu.button_down? Gosu::KB_LEFT or Gosu.button_down? Gosu::GP_LEFT
      move_left @player
      end
      if Gosu.button_down? Gosu::KB_RIGHT or Gosu.button_down? Gosu::GP_RIGHT
      move_right @player
      end
      if Gosu.button_down? Gosu::KB_UP or Gosu.button_down? Gosu::GP_BUTTON_0
      move_up @player
      end
      if Gosu.button_down? Gosu::KB_DOWN or Gosu.button_down? Gosu::GP_BUTTON_9
      move_down @player
      end
    else
      if Gosu.button_down? Gosu::KB_LEFT or Gosu.button_down? Gosu::GP_LEFT
        move_right @player
      end
      if Gosu.button_down? Gosu::KB_RIGHT or Gosu.button_down? Gosu::GP_RIGHT
        move_left @player
      end
      if Gosu.button_down? Gosu::KB_UP or Gosu.button_down? Gosu::GP_BUTTON_0
        move_down @player
      end
      if Gosu.button_down? Gosu::KB_DOWN or Gosu.button_down? Gosu::GP_BUTTON_9
        move_up @player
      end
    end
    @all_food.each { |food| move food }
    @all_object.each { |object| move object}
    if @player.score >= 10
      @all_object.each{ |object| move object}
    end
    if rand(300) < 4
      @all_object.each{ |object| change_direction object}
    end
    self.remove_food 
    @background_music.play
    collect_food(@all_food, @player)
    met_object(@all_object, @player)
    # the following will generate new food and object randomly as update is called each timestep
    @all_notification.push(generate_noti)

   if rand(500) < 4 and @all_food.size < 4
    @all_food.push(generate_food)
   end

   if rand(500) < 4 and @all_object.size < 7
    @all_object.push(generate_object)
   end
end
   # change the food randomly:

  def draw
    @background_image.draw(0, 0, ZOrder::BACKGROUND)
    draw_rider @player
    @all_notification.each{ |notification| draw_notification notification}
    @all_food.each { |food| draw_food food }
    @all_object.each { |object| draw_object object}
    if @player.score < 5
      @font.draw("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
      @background_image = Gosu::Image.new("media/background.png", :tileable => true)
    else
      @font.draw("Score: #{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
      @background_image = Gosu::Image.new("media/background2.jpg", :tileable => true)
      @background_image.draw(0, 0, ZOrder::BACKGROUND)
    end
    if @player.score >= 15
      draw_endscreen(@endscreen)
    end 
  end

  def generate_food
    case rand(3)
    when 0
      Food.new("media/food.png", 'food')
    when 1
      Food.new("media/food2.png", 'food')
    when 2
      Food.new("media/food3.png", 'food')
    end
  end

def generate_object
  return Object.new('media/object.png', 'object')
end

def generate_noti
  if @player.score < 0 or @player.score > 0 or @player.score = 0 and @player.score < 5
    Notifications.new('media/noti1.png')
  elsif @player.score >= 5 and @player.score < 10
    Notifications.new('media/noti2.png')
  else 
    Notifications.new('media/noti3.png')
  end
end

  def remove_food
    @all_food.reject! do |food|
      if food.x > SCREEN_WIDTH || food.y > SCREEN_HEIGHT || food.x < 0 || food.y < 0
        true
      else
        false
      end
    end
  end

  def button_down(id)
    if id == Gosu::KB_E
      close
    end
    if id == Gosu::KB_P
      update_end(@endscreen)
    end 
  end
end

RockRiderGame.new.show if __FILE__ == $0
