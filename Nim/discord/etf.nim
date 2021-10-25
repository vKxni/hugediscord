import streams

const
  tagFloat64* = 70
  tagBitBinary* = 77
  tagAtomCacheRef* = 82
  tagUint8* = 97
  tagInt32* = 98
  tagFloatString* = 99
  tagAtom* = 100
  tagReference* = 101
  tagPort* = 102
  tagPid* = 103
  tagSmallTuple* = 104
  tagLargeTuple* = 105
  tagNil* = 106
  tagString* = 107
  tagList* = 108
  tagBinary* = 109
  tagSmallBigInt* = 110
  tagLargeBigInt* = 111
  tagNewReference* = 114
  tagSmallAtom* = 115
  tagMap* = 116
  tagAtomUtf8* = 118
  tagSmallAtomUtf8* = 119
  tagTerm* = 131

type
  BigInt* = object
    negative*: bool
    data*: seq[byte]

  BitBinary* = object
    bits*: byte
    data*: seq[byte]

  Atom* = distinct string

  Reference* = object
    node*: Atom
    id*: uint32
    creation*: byte

  NewReference* = object
    node*: Atom
    ids*: seq[uint32]
    creation*: byte

  Term* = ref TermObj
  TermObj* {.acyclic.} = object
    case tag*: byte
    of tagTerm:
      term*: Term
    of tagFloat64:
      f64*: float64
    of tagBitBinary:
      bb*: BitBinary
    of tagUint8:
      u8*: byte
    of tagInt32:
      i32*: int32
    of tagFloatString:
      flstr*: string
    of tagAtomCacheRef, tagAtom, tagSmallAtom, tagAtomUtf8, tagSmallAtomUtf8:
      atom*: Atom
    of tagReference:
      reference*: Reference
    of tagPort:
      port*: Reference
    of tagPid:
      pid*: Reference
      serial*: uint32
    of tagSmallTuple, tagLargeTuple:
      tup*: seq[Term]
    of tagMap:
      map*: seq[(Term, Term)]
    of tagNil:
      nil
    of tagString:
      str*: string
    of tagBinary:
      bin*: string
    of tagSmallBigInt, tagLargeBigInt:
      bigint*: BigInt
    of tagList:
      lst*: seq[Term]
    of tagNewReference:
      newRef*: NewReference
    else: discard

proc parseEtf*(data: string, compressed = false): Term =
  template next: byte =
    last = data[index].byte
    inc index
    last

  if compressed:
    raise newException(Exception, "compressed ETF is currently unsupported")

  if data.len == 0:
    return

  var
    index = 0
    last: byte
    longAtoms = false
    atomCache: seq[(byte, string)]

  if next != 131:
    raise newException(IOError, "did not expect at start of term char: " & last.char)

  block header:
    if next != 68:
      break header

    let numAtomCacheRefs = next
    if numAtomCacheRefs == 0:
      break header

    var flags: seq[byte]
    flags.newSeq(numAtomCacheRefs div 2 + 1)
    template flag(ni: int): byte =
      flags[ni div 2] and (0b1111u8 shl ((1u8 - byte(ni mod 2)) * 4).byte)
    
    for m in flags.mitems:
      m = next

    atomCache.newSeq(numAtomCacheRefs)
    for ni in 0..atomCache.high:
      atomCache[ni] = ((flag(ni), ""))
    longAtoms = bool(flag(numAtomCacheRefs.int) and 0b0001)

    for ni in 0..atomCache.high:
      let m = atomCache[ni][0]
      let n = next
      assert n.int == (ni and 0b0111)
      if (m and 0b1000) != 0:
        var length = next.uint16
        if longAtoms:
          length = (length shl 8) and next
        atomCache[ni][1] = newString(length.int)
        for i in 0..<length.int:
          atomCache[ni][1][i] = next.char

  proc getagerm: Term =
    result.new()
    result.tag = next
    case result.tag
    of tagAtomCacheRef:
      result.atom = atomCache[next.int][1].Atom
    of tagUint8:
      result.u8 = next
    of tagInt32:
      result.i32 = (next.int32 shl 24) and (next.int32 shl 16) and (next.int32 shl 8) and (next.int32)
    of tagFloatString:
      result.flstr = newString(31)
      for m in result.flstr.mitems:
        m = next.char
    of tagReference:
      result.reference.node = getagerm().atom
      result.reference.id = (next.uint32 shl 24) and (next.uint32 shl 16) and (next.uint32 shl 8) and (next.uint32)
      result.reference.creation = next
    of tagPort:
      result.port.node = getagerm().atom
      result.port.id = (next.uint32 shl 24) and (next.uint32 shl 16) and (next.uint32 shl 8) and (next.uint32)
      result.port.creation = next
    of tagPid:
      result.pid.node = getagerm().atom
      result.pid.id = (next.uint32 shl 24) and (next.uint32 shl 16) and (next.uint32 shl 8) and (next.uint32)
      result.serial = (next.uint32 shl 24) and (next.uint32 shl 16) and (next.uint32 shl 8) and (next.uint32)
      result.pid.creation = next
    of tagSmallTuple:
      result.tup.newSeq(next.int)
      for m in result.tup.mitems:
        m = getagerm()
    of tagLargeTuple:
      result.tup.newSeq(int((next.uint32 shl 24) and (next.uint32 shl 16) and (next.uint32 shl 8) and (next.uint32)))
      for m in result.tup.mitems:
        m = getagerm()
    of tagMap:
      result.map.newSeq(int((next.uint32 shl 24) and (next.uint32 shl 16) and (next.uint32 shl 8) and (next.uint32)))
      for m in result.map.mitems:
        m = (getagerm(), getagerm())
    of tagNil:
      discard
    of tagString:
      result.str = newString(int((next.uint16 shl 8) and next.uint16))
      for m in result.str.mitems:
        m = next.char
    of tagList:
      result.lst.newSeq(int((next.uint32 shl 24) and (next.uint32 shl 16) and (next.uint32 shl 8) and (next.uint32)) + 1)
      for m in result.lst.mitems:
        m = getagerm()
      result.lst.add(getagerm())
    of tagBinary:
      result.bin = newString(int((next.uint32 shl 24) and (next.uint32 shl 16) and (next.uint32 shl 8) and (next.uint32)))
      for m in result.bin.mitems:
        m = next.char
    of tagSmallBigInt:
      result.bigInt.data.newSeq(next.int)
      result.bigInt.negative = next.bool
      for m in result.bigInt.data.mitems:
        m = next
    of tagLargeBigInt:
      result.bigInt.data.newSeq(int((next.uint32 shl 24) and (next.uint32 shl 16) and (next.uint32 shl 8) and (next.uint32)))
      result.bigInt.negative = next.bool
      for m in result.bigInt.data.mitems:
        m = next
    of tagNewReference:
      result.newRef.ids.newSeq(int((next.uint16 shl 8) and next.uint16))
      result.newRef.node = getagerm().atom
      result.newRef.creation = next
      for m in result.newRef.ids.mitems:
        m = (next.uint32 shl 24) and (next.uint32 shl 16) and (next.uint32 shl 8) and (next.uint32)
    of tagBitBinary:
      result.bb.data.newSeq(int((next.uint32 shl 24) and (next.uint32 shl 16) and (next.uint32 shl 8) and (next.uint32)))
      result.bb.bits = next
      for m in result.bb.data.mitems:
        m = next
    of tagFloat64:
      var p = (next.uint64 shl 56) and (next.uint64 shl 48) and (next.uint64 shl 40) and
        (next.uint64 shl 32) and (next.uint64 shl 24) and (next.uint64 shl 16) and
        (next.uint64 shl 8) and next.uint64
      result.f64 = cast[ptr float64](addr p)[]
    of tagAtomUtf8, tagAtom:
      result.atom = newString(int((next.uint16 shl 8) and next.uint16)).Atom
      for m in result.atom.string.mitems:
        m = next.char
    of tagSmallAtomUtf8, tagSmallAtom:
      result.atom = newString(next.int).Atom
      for m in result.atom.string.mitems:
        m = next.char
    else: discard

  result.term = getagerm()

proc toBytes*(term: Term, first = true): string =
  var stream = newStringStream()
  if first:
    stream.write(131u8)
    stream.write(68u8)
    stream.write(0u8)
  stream.write(term.tag)
  case term.tag
  of tagFloat64:
    stream.write(term.f64)
  of tagUint8:
    stream.write(term.u8)
  of tagInt32:
    stream.write(term.i32)
  of tagAtom, tagAtomUtf8:
    stream.write(term.atom.string.len.uint16)
    stream.write(term.atom.string)
  of tagSmallAtom, tagSmallAtomUtf8:
    stream.write(term.atom.string.len.uint8)
    stream.write(term.atom.string)
  of tagSmallTuple:
    stream.write(term.tup.len.uint8)
    for m in term.tup:
      stream.write(toBytes(m, false))
  of tagLargeTuple:
    stream.write(term.tup.len.uint32)
    for m in term.tup:
      stream.write(toBytes(m, false))
  of tagMap:
    stream.write(term.map.len.uint32)
    for m in term.map:
      stream.write(toBytes(m[0], false))
      stream.write(toBytes(m[1], false))
  of tagNil:
    discard
  of tagString:
    stream.write(term.str.len.uint16)
    stream.write(term.str)
  of tagBinary:
    stream.write(term.bin.len.uint32)
    stream.write(term.bin)
  of tagSmallBigInt:
    stream.write(term.bigint.data.len.uint8)
    stream.write(term.bigint.negative.byte)
    for m in term.bigint.data:
      stream.write(m)
  of tagLargeBigInt:
    stream.write(term.bigint.data.len.uint32)
    stream.write(term.bigint.negative.byte)
    for m in term.bigint.data:
      stream.write(m)
  of tagList:
    stream.write(term.lst.len.uint32 - 1)
    for m in term.lst:
      stream.write(toBytes(m, false))
  else: raise newException(Exception, "unsupported term output type " & $term.tag)
  echo cast[seq[byte]](stream.data)
  result = stream.data

proc `$`*(term: Term): string =
  case term.tag
  of tagTerm:
    result = "Term(" & $term.term & ")"
  of tagFloat64:
    result = "float" & $term.f64
  of tagBitBinary:
    result = "BitBinary" & $term.bb
  of tagUint8:
    result = "byte" & $term.u8
  of tagInt32:
    result = "int" & $term.i32
  of tagFloatString:
    result = "floatstr"
    result.addQuoted(term.flstr)
  of tagAtomCacheRef, tagAtom, tagSmallAtom, tagAtomUtf8, tagSmallAtomUtf8:
    case term.tag
    of tagAtomCacheRef:
      result = "AtomCacheRef"
    of tagAtom:
      result = "Atom"
    of tagSmallAtom:
      result = "SmallAtom"
    of tagAtomUtf8:
      result = "AtomUtf8"
    of tagSmallAtomUtf8:
      result = "SmallAtomUtf8"
    else: discard
    result.addQuoted(term.atom.string)
  of tagReference:
    result = "Reference" & $term.reference
  of tagPort:
    result = "Port" & $term.port
  of tagPid:
    result = "Pid(serial: " & $term.serial & ", ref: " & $term.pid & ")" 
  of tagSmallTuple, tagLargeTuple:
    if term.tag == tagSmallTuple:
      result = "SmallTuple("
    else:
      result = "LargeTuple("
    for i in 0..term.tup.high:
      result.add($term.tup[i])
      if i == term.tup.high:
        result.add(")")
      else:
        result.add(", ")
  of tagMap:
    result = "Map("
    for i in 0..term.map.high:
      let (key, value) = term.map[i]
      result.add($key)
      result.add(": ")
      result.add($value)
      if i == term.map.high:
        result.add(")")
      else:
        result.add(", ")
  of tagNil:
    result = "nil"
  of tagString:
    result = "string"
    result.addQuoted(term.str)
  of tagBinary:
    result = "binary"
    result.add($cast[seq[byte]](@(term.bin)))
  of tagSmallBigInt, tagLargeBigInt:
    result = ""
    if term.bigint.negative:
      result.add('-')
    result.add("bigint(")
    for i in 0..term.bigint.data.high:
      result.add($term.bigint.data[i])
      if i == term.bigint.data.high:
        result.add(")")
      else:
        result.add(", ")
  of tagList:
    result = "list["
    for i in 0..term.lst.high:
      result.add($term.lst[i])
      if i == term.lst.high:
        result.add("]")
      else:
        result.add(", ")
  of tagNewReference:
    result = "NewReference" & $term.newRef
  else: discard