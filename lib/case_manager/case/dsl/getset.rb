# DSL#get and DSL#set
module DSL
  # Read param pOption from [running, config or global] Hash data
  def get(option)
    @config.get(option)
  end

  def set(key, value)
    @config.set(key, value)
  end
end