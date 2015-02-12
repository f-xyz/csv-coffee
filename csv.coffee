module.exports = (settings) ->

  MODES =
    CHAR           : 'CHAR'
    FIELD_SEPARATOR: 'FIELD_SEPARATOR'
    LINE_SEPARATOR : 'LINE_SEPARATOR'
    ESCAPED        : 'ESCAPED'

  config =
    lineSeparators: ['\r', '\n']
    fieldSeparator: ',',
    quote: '"'

  if settings
    Object.keys(settings).forEach (key) ->
      config[key] = settings[key]

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
    return lines
    
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
    return fields

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
        if char in config.lineSeparators
          mode = MODES.LINE_SEPARATOR
        else
          result += char

      else if mode == MODES.LINE_SEPARATOR
        if char !in config.lineSeparators
          break

    return { result, pos: i }
    
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
        if char == config.quote
          if nextChar == config.quote
            result += char
            i += 2
          else
            mode = MODES.ESCAPED
        else if char == config.fieldSeparator
          mode = MODES.FIELD_SEPARATOR
        else
          result += char

      else if mode == MODES.ESCAPED
        if char == config.quote
          if nextChar == config.quote
            result += char
            i += 1
          else
            mode = MODES.CHAR
        else
          result += char

      else if mode == MODES.FIELD_SEPARATOR
        if char != config.fieldSeparator
          break

    return { result, pos: i }

  # 'instance'
  return {
    parseCsv,
    parseLine, 
    _getNextField: getNextField,
    _getNextLine: getNextLine
  }