module Jung::Drivers

  def self.load(name)
    require File.join('jung', 'drivers', name)
  end

end