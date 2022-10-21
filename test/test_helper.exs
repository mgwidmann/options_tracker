ExUnit.configure(exclude: :pending)
ExUnit.start()
# Without the sleep Ecto gets failures checking out a connection
# Something is starting up out of order but its unclear what. Since
# it only seems to affect the test environment, this is the best fix found so far
:timer.sleep(1000)
Ecto.Adapters.SQL.Sandbox.mode(OptionsTracker.Repo, :manual)
