#
# 
#

class String
  CLEAR     = "\e[0m"
  BOLD      = "\e[1m"

  @@cli_colors = 
  { 
    black:      "\e[30m",
    red:        "\e[31m",
    green:      "\e[32m",
    yellow:     "\e[33m",
    blue:       "\e[34m",
    magenta:    "\e[35m",
    cyan:       "\e[36m",
    white:      "\e[37m",
    bg_red:     "\033[41m",
    bg_green:   "\033[42m",
    bg_yellow:  "\033[43m",
    bg_blue:    "\033[44m",
    bg_magenta: "\033[45m",
    bg_cyan:    "\033[46m",
  }

  def method_missing(meth, *args, &block)
    color = @@cli_colors[meth.to_sym]
    if color
      color + self + (((not args[0]) and CLEAR) or '')
    else
      super.method_missing(meth, args, block)
    end
  end

  def bold
    BOLD + self
  end

  def clear
    self + CLEAR
  end

  def wrap(width=80)
    self.split("\n").collect do |line|
      line.length > width ? line.gsub(/(.{1,#{width}})(\s+|$)/, "\\1\n").strip : line
    end * "\n"
  end

end # String
