MODES =
  CHAR           : 'CHAR'
  FIELD_SEPARATOR: 'FIELD_SEPARATOR'
  LINE_SEPARATOR : 'LINE_SEPARATOR'
  ESCAPED        : 'ESCAPED'

config = 
    

LINE_SEPARATORS = ['\r', '\n']
FIELD_SEPARATOR = ','
QUOTE = '"'

###
  @param {string} x
  @param {int} pos
  @returns {{ result: string, pos: int }}
###
getNextField = (x, pos) ->
  if pos >= x.length
    return null

  result = ''
  mode = MODES.CHAR

  for i in [pos...x.length]
    char = x[i]
    nextChar = x[i+1]

    if mode == MODES.CHAR
      if char == QUOTE
        if nextChar == QUOTE
          result += char
          i += 2
        else
          mode = MODES.ESCAPED
      else if char == FIELD_SEPARATOR
        mode = MODES.FIELD_SEPARATOR
      else
        result += char

    else if mode == MODES.ESCAPED
      if char == QUOTE
        if nextChar == QUOTE
          result += char
          i += 1
        else
          mode = MODES.CHAR
      else
        result += char

    else if mode == MODES.FIELD_SEPARATOR
      if char != FIELD_SEPARATOR
        break

  return { result, pos: i }

###
  @param {string} x
  @param {int} pos
  @returns {{ result: string, pos: int }}
###
getNextLine = (x, pos) ->
  if pos >= x.length
    return null

  result = ''
  mode = MODES.CHAR

  for i in [pos...x.length]
    char = x[i]

    if mode == MODES.CHAR
      if char in LINE_SEPARATORS
        mode = MODES.LINE_SEPARATOR
      else
        result += char

    else if mode == MODES.LINE_SEPARATOR
      if char !in LINE_SEPARATORS
        break

  return { result, pos: i }

###
  @param {string} x
  @returns {string[]}
###
parseLine = (x) ->
  fields = []
  i = 0
  while i < x.length
    field = getNextField(x, i)
    if field
      fields.push(field.result);
      i = field.pos
    else
      break
  return fields

###
  @param {string} csv
  @returns {string[string[]]}
###
parseCsv = (csv) ->
  lines = []
  i = 0
  while i < csv.length
    line = getNextLine(csv, i)
    if line
      fields = parseLine(line.result)
      lines.push(fields);
      i = line.pos
    else
      break
  return lines

module.exports = { getNextField, getNextLine, parseLine, parseCsv }