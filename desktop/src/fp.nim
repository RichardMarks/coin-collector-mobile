type
  FP = proc(x,y,z:int)

  Foo = object
    f1: FP

proc foo(x,y,z:int) =
  echo "" & $x & $y & $z

when isMainModule:
  let f = Foo(f1: foo)

  f.f1(5,6,7)
