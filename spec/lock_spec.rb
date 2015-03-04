module SandthornSequelProjection

  describe Lock do
    let(:db_connection) { Sequel.sqlite }
    let(:table_name) { ProcessedEventsTracker::DEFAULT_TABLE_NAME }
    let(:lock) { SandthornSequelProjection::Lock.new("foo", db_connection) }

    before(:each) do
      db_connection.create_table?(table_name) do
        String    :identifier
        DateTime  :locked_at, null: true
      end
      db_connection[table_name].insert(identifier: lock.identifier)
    end

    def null_lock
      db_connection[table_name].where(identifier: lock.identifier).update(locked_at: nil)
    end

    def set_lock(time = Time.now)
      db_connection[table_name].where(identifier: lock.identifier).update(locked_at: time)
    end

    def lock_row
      db_connection[table_name].where(identifier: lock.identifier).first
    end

    def lock_column
      lock_row[:locked_at]
    end

    describe "#locked?" do
      context "when the lock column is nulled" do
        it "should return false" do
          null_lock
          expect(lock.locked?).to be_falsey
        end
      end

      context "when the lock is locked" do
        it "should return true" do
          set_lock
          expect(lock.locked?).to be_truthy
        end
      end
    end

    describe "#unlocked" do
      context "when the lock column is nulled" do
        it "should return true" do
          expect(lock.unlocked?).to be_truthy
        end
      end
    end

    describe "#attempt_lock" do
      context "when there is no previous lock" do
        it "creates the lock" do
          null_lock
          expect(lock.attempt_lock).to be_truthy
          expect(lock.locked?).to be_truthy
        end
      end

      context "when there is a previous lock" do
        context "and it has not expired" do
          it "returns false and doesn't set the lock" do
            set_lock
            locked_at = lock_column
            expect(lock.attempt_lock).to be_falsey
            locked_at_after = lock_column
            expect(locked_at_after).to eq(locked_at)
          end
        end

        context "and it has expired" do
          it "returns true at sets a new lock" do
            set_lock(Time.now - lock.timeout)
            locked_at = lock_column
            expect(lock.attempt_lock).to be_truthy
            locked_at_after = lock_column
            expect(locked_at_after).to_not eq(locked_at)

          end
        end
      end
    end

    describe "#release" do
      it "releases the lock" do
        set_lock
        expect(lock.release).to be_truthy
        expect(lock_column).to be_nil
      end
    end

    describe "#aqcuire" do
      context "when the lock is unlocked" do
        it "executes the block" do
          null_lock
          expect { |b| lock.acquire(&b) }.to yield_control
        end

        it "has the lock during execution, and releases the lock afterwards" do
          null_lock
          lock.acquire do
            expect(lock.locked?).to be_truthy
          end
          expect(lock_column).to be_nil
        end
      end

      context "when the lock is locked" do
        it "doesn't yield" do
          set_lock
          expect { |b| lock.acquire(&b) }.to_not yield_control
        end
      end

      context "when an exception is raised" do
        MyMegaException = Class.new(StandardError)

        it "releases the lock" do
          begin
            lock.acquire do
              expect(lock.locked?).to be_truthy
              raise MyMegaException
            end
          rescue
          ensure
            expect(lock.locked?).to be_falsey
          end
        end

        it "reraises the exception" do
          expect { lock.acquire { raise MyMegaException } }.to raise_exception(MyMegaException)
        end
      end
    end
  end
end