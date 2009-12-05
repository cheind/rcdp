#
# Project:: Ruby-Snippets
# 
# Author:: Christoph Heindl  (mailto:christoph.heindl@gmail.com)
# Homepage:: http://cheind.wordpress.com
#
# == Overview
# 
# Implements generation of UUIDs based on
# - A web-service <tt>UUID.from_url</tt>
# - Platform dependant API's <tt>UUID.from_os</tt>
#
# Currently only windows platforms are supported 

require 'net/http'
require 'uri/http'
#
require 'ext/reverse_merge.rb'
require 'ext/join.rb'
require 'ext/breakup.rb'

# Provides generation of universal unique identifiers (UUID) or more
# commonly known as GUIDs. 
class UUID
  
  # Generates an UUID string by using
  # the web-services provided by http://www.fileformat.info
  # at http://www.fileformat.info/tool/guid.htm
  #
  # Options
  # - <tt>:format</tt> should always be :text
  # - <tt>:uppercase</tt> sets all letters to uppercase if set
  # - <tt>:hyphen</tt> uses '-' between groups if set
  # - <tt>:bracket</tt> wrap UUID in courly brackets if set
  # - <tt>:count</tt> number of UUIDs to receiver.
  #
  #  UUID.from_url # => "{F4C77E3A-F1C3-45BD-B740-7DD61B889AD9}"
  #
  #  UUID.from_url(:count => 2)
  #  # => ["{44351F05-8CCC-4408-9FE0-CE41864F03CE}", 
  #        "{3730EA6C-986B-4A4A-A942-ED4C1192D713}]
  #
  def UUID.from_url(options={})
    options = UUID.default_options(options)
    # Replace all instances of TrueClass to 'Y' for web-service
    options.each { |k,v| options[k] = 'Y' if v.instance_of?(TrueClass) }
    # Build URI
    uri = URI::HTTP.build(
      :host => 'www.fileformat.info',
      :path => '/tool/guid.htm',
      :query => options.join('&', '=')
    )
    # Query
    uuids = Net::HTTP.get(uri)
    # Split lines if multiple uuids and
    uuids.split($/).breakup
  end
  
  # Following block provides platform dependant UUID generation
  if RUBY_PLATFORM =~ /mswin/
    # Windows platform...
    require 'Win32API'
    
    @@api = Win32API.new('rpcrt4', 'UuidCreate', 'P', 'L')
    
    # Generates an UUID string using Win32API.
    #
    # This is based on code from Brad Wilson posted in 2005 at
    # http://www.agileprogrammer.com/dotnetguy/archive/2005/10/27/8991.aspx
    #
    # Options
    # - <tt>:uppercase</tt> sets all letters to uppercase if set
    # - <tt>:hyphen</tt> uses '-' between groups if set
    # - <tt>:bracket</tt> wrap UUID in courly brackets if set
    # - <tt>:count</tt> number of UUIDs to receiver.
    #
    #  UUID.from_os # => "{F4C77E3A-F1C3-45BD-B740-7DD61B889AD9}"
    #
    #  UUID.from_os(:count => 2)
    #  # => ["{44351F05-8CCC-4408-9FE0-CE41864F03CE}", 
    #        "{3730EA6C-986B-4A4A-A942-ED4C1192D713}]
    #
    def UUID.from_os(options={})
      options = UUID.default_options(options)
      # Setup format string based on options
      format = options[:hyphen] ? '{' : ''
      format += options[:bracket] ? 
        '%04X%04X-%04X-%04X-%04X-%04X%04X%04X' :
        '%04X%04X%04X%04X%04X%04X%04X%04X'
      format += options[:hyphen] ? '}' : ''
      # Invoke API
      uuids = []
      options[:count].times do 
        buffer = ' ' * 16
        @@api.call(buffer)
        a, b, c, d, e, f, g, h = buffer.unpack('SSSSSSSS')
        uuid = sprintf(format, a, b, c, d, e, f, g, h)
        uuid.upcase! if options[:uppercase]
        uuids << uuid
      end
      uuids.breakup
    end
  end
  
  private
  
  # Plugin default options if not already specified in options hash
  def UUID.default_options(options)
    raise "Generating zero UUIDs makes really no sense..." if options[:count] == 0
    options.reverse_merge(
      :format => :text,
      :uppercase => true,
      :hyphen => true,
      :bracket => true,
      :count => 1
    )
  end
end