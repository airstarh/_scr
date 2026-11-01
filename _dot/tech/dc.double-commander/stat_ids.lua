-- Double Commander bundles SysUtils natively
function ContentGetSupportedField(FieldIndex)
  if FieldIndex == 0 then return "UID", "", 8 end
  if FieldIndex == 1 then return "GID", "", 8 end
  return "", "", 0
end

function ContentGetValue(FileName, FieldIndex, UnitIndex, Flags)
  -- SysUtils gives a reliable cross-platform handle for file data attributes
  local handle = io.popen("stat -c '%u:%g' " .. string.format("%q", FileName))
  if not handle then return nil end

  local result = handle:read("*a")
  handle:close()

  if not result or result == "" then return nil end
  local uid, gid = string.match(result, "(%d+):(%d+)")

  if FieldIndex == 0 then return uid end
  if FieldIndex == 1 then return gid end
  return nil
end
