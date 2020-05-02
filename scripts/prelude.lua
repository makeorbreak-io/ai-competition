getcount = (
  function (n, error)
    local counter = 0

    debug.sethook(
      function ()
        counter = counter + 1
        if counter >= n then
          error("timeout")
        end
      end,
      "",
      1)

    return function () return counter end
  end
)(limit, error)

debug = nil
xpcall = nil
pcall = nil
assert = nil
error = nil

math.randomseed(0)
