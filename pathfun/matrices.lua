local path = (...):gsub("[^%.]*$", "")
local M = require(path .. 'master')
local Matrix, row_mt
Matrix = M.class({
  __init = function(self, num_rows, num_cols, default_value)
    self.num_rows, self.num_cols, self.default_value = num_rows, num_cols, default_value
    self.matrix = { }
  end,
  __index = function(m, row)
    if type(row) == 'number' then
      assert(row >= 1 and row <= m.num_rows, "indices out of range")
      return setmetatable({
        parent = m,
        row = row
      }, row_mt)
    end
  end
})
M.Matrix = Matrix
M.SymmetricMatrix = M.class({
  __extends = Matrix,
  __init = function(self, num_rows, default_value)
    self.symmetric = true
    return Matrix.__init(self, num_rows, num_rows, default_value)
  end
})
row_mt = {
  __index = function(r, col)
    local parent = r.parent
    local num_cols = parent.num_cols
    local symmetric = parent.symmetric
    local row = r.row
    assert(col >= 1 and col <= num_cols, "indices out of range")
    local idx
    if symmetric and col < row then
      idx = col * num_cols + row
    else
      idx = row * num_cols + col
    end
    return parent.matrix[idx] or parent.default_value
  end,
  __newindex = function(r, col, value)
    local parent = r.parent
    local num_cols = parent.num_cols
    local symmetric = parent.symmetric
    local row = r.row
    assert(col >= 1 and col <= num_cols, "indices out of range")
    local idx
    if symmetric and col < row then
      idx = col * num_cols + row
    else
      idx = row * num_cols + col
    end
    parent.matrix[idx] = value
  end
}
