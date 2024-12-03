require_relative 'RetryExecutor'

RSpec.describe RetryExecutor do
  let(:error_message) { "Випадкова помилка" }

  context "коли блок завершується без помилок" do
    it "виконує блок один раз" do
      executor = RetryExecutor.new(retries: 3)
      expect { |b| executor.execute(&b) }.to yield_control.exactly(1).times
    end
  end

  context "коли блок кілька разів викликає помилку, але зрештою завершується успішно" do
    it "повторює виконання до успіху" do
      attempts = 0
      executor = RetryExecutor.new(retries: 5)
      expect {
        executor.execute do
          attempts += 1
          raise error_message if attempts < 3
        end
      }.not_to raise_error
      expect(attempts).to eq(3)
    end
  end

  context "коли блок викликає помилку більше допустимої кількості спроб" do
    it "кидає помилку після вичерпання всіх спроб" do
      executor = RetryExecutor.new(retries: 2)
      expect {
        executor.execute { raise error_message }
      }.to output(/Усі спроби вичерпано./).to_stdout
    end
  end

  context "коли блок обробляє тільки певні типи винятків" do
    it "не повторює, якщо виняток не входить у список дозволених" do
      executor = RetryExecutor.new(retries: 3, exceptions: [ZeroDivisionError])
      expect {
        executor.execute { raise StandardError, error_message }
      }.to raise_error(StandardError, error_message)
    end
  end
end
