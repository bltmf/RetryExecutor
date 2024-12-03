class RetryExecutor
    def initialize(retries: 3, exceptions: [StandardError])
      @retries = retries
      @exceptions = exceptions
    end
  
    def execute
      attempts = 0
      begin
        yield
      rescue *@exceptions => e
        attempts += 1
        puts "Помилка: #{e.message}. Спроба №#{attempts}..."
        retry if attempts < @retries
        puts "Усі спроби вичерпано."
      end
    end
  end
  
  executor = RetryExecutor.new(retries: 5, exceptions: [StandardError, ZeroDivisionError])
  executor.execute do
    puts "Спроба виконання блоку..."
    raise "Випадкова помилка" if rand < 0.7
    puts "Блок успішно виконано!"
  end
  