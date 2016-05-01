def attribute(arg, &block)
  name = arg
  @hash_vars = {} unless instance_variable_defined? :@hash_vars

  if arg.is_a? Hash
    name = arg.keys[0]
    instance_variable_set( :"@#{name}", arg[name] )
    @hash_vars[:"@#{name}"] = arg[name]
  end

  attr_reader name.to_sym
  attr_writer name.to_sym

  define_method :"#{name}?" do
    send(:"#{name}")
  end

  define_method :initialize do
    if self.class.instance_variable_get(:@hash_vars)
      self.class.instance_variable_get(:@hash_vars).each do |var, val|
        instance_variable_set(var, val)
      end
    end
    send( :"#{name}=", instance_eval(&block) ) if block
  end

  define_method :inherited do |subclass|
    instance_variables.each do |var|
      val = instance_variable_get(var)
      subclass.instance_variable_set(var, val)
    end
  end

  define_singleton_method :included do |subclass|
    instance_variables.each do |var|
      val = instance_variable_get(var)
      subclass.instance_variable_set(var, val)
    end
  end
end