should = require('chai').should()
csv = require('../csv')()

describe 'parseCsv() tests', ->
  it 'should return all parsed data', ->
    expected = [['q', 'w', 'e'], ['a', 's', 'd']]
    result = csv.parseCsv('q,w,e\na,s,d')
    result.should.deep.equal(expected)
    
describe 'parseLine() tests', ->
  it 'should return all fields', -> csv.parseLine('q,",w",e').should.deep.equal(['q', ',w', 'e'])
  
describe 'getNextLine() tests', ->
  it 'should return NULL for empty input',    -> should.not.exist(csv.getNextLine('', 0))
  it 'should return first line',              -> csv.getNextLine('qwe\r\nasd', 0).result.should.equal('qwe')
  it 'should return offset after found line', -> csv.getNextLine('qwe\r\nasd', 0).pos.should.equal(5)
  it 'should return next line from offset',   -> csv.getNextLine('qwe\r\nasd\r\n', 5).result.should.equal('asd')
  it 'should return NULL after end of line',  -> should.not.exist(csv.getNextLine('qwe\rn', 500))

describe 'getNextField() tests', ->
  it 'should return NULL for empty input',       -> should.not.exist(csv.getNextField('', 0))
  it 'should return first field',                -> csv.getNextField('qwe,asd', 0).result.should.equal('qwe')
  it 'should return offset after found field',   -> csv.getNextField('qwe,asd', 0).pos.should.equal(4)
  it 'should return next field from offset',     -> csv.getNextField('qwe,asd', 4).result.should.equal('asd')
  it 'should respect brackets',                  -> csv.getNextField('"q,w,e,","asd"', 0).result.should.equal('q,w,e,')
  it 'should respect brackets with offset',      -> csv.getNextField('"q,w,e,","asd"', 9).result.should.equal('asd')
  it 'should respect escaped (double) brackets', -> csv.getNextField('"q""we"', 0).result.should.equal('q"we')
  it 'should return NULL after end of line',     -> should.not.exist(csv.getNextField('qwe', 500))

describe 'setting options', ->
  tsv = require('../csv')({
    fieldSeparator: '\t',
    lineSeparators: ['\0'],
    quote: '`'
  })
  it 'should parse TSV', ->
    expected = [['q', 'w', 'e'], ['a', 's', 'd']]
    result = tsv.parseCsv('q\t`w`\te\0a\ts\td')
    result.should.deep.equal(expected)