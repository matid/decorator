module Decorator
  def decorate(method_name, options = {})
    before = options.delete(:before) || proc {}
    after = options.delete(:after) || proc {}

    method = self.instance_method(method_name)
    define_method(method_name) do |*args|
      _method = method.bind(self)
      before.call(_method, *args)
      result = _method.call(*args)
      after.call(_method, result)
      result
    end
  end
end

module Logger
  def self.extended(base)
    base.extend(Decorator)
  end

  def debug
    log(*instance_methods)
  end

  def log(*methods)
    methods.each do |method|
      decorate(method, :before => proc { |method, *args|
        puts "#{method} called with #{args}"
      }, :after => proc { |method, result|
        puts "#{method} returned #{result}"
      })
    end
  end
end

class A
  extend Logger

  def square x; return x**2, x**3; end

  def hello; "Hello, world!" end

  # log :hello

  def self.hello; "Hello" end

  # debug

  class << self
    extend Logger
    debug
  end
end

a = A.new
puts a.square(2)
puts a.hello
puts A.hello