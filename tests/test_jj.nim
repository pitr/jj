import unittest, jj, tables

suite "jj":
  test "eval":
    var env = newTable[string, Arr]()
    # Atoms
    check $eval(parse(""), env) == ""
    check $eval(parse("1"), env) == "1"
    check $eval(parse("123"), env) == "123"
    expect(Exception): discard eval(parse("abc"), env)
    # Monads
    check $eval(parse("+10"), env) == "10"
    check $eval(parse("{10"), env) == "1"
    check $eval(parse("~10"), env) == "0 1 2 3 4 5 6 7 8 9"
    check $eval(parse("#10"), env) == ""
    check $eval(parse("#~10"), env) == "10"
    # Dyads
    check $eval(parse("x=1,2"), env) == "1 2"
    check $eval(parse("1+2"), env) == "3"
    check $eval(parse("x+5,5"), env) == "6 7"
    check $eval(parse("1,2,3"), env) == "1 2 3"
    check $eval(parse("1{5,7,9"), env) == "7"
    check $eval(parse("5#~1000"), env) == "0 1 2 3 4"
    check $eval(parse("5#3,4"), env) == "3 4 3 4 3"
    check $eval(parse("shp=2,3"), env) == "2 3"
    check $eval(parse("shp#~10"), env) == "0 1 2 3 4 5"
    check $eval(parse("#shp#~10"), env) == "2 3"
    # Variables
    check $eval(parse("a=3"), env) == "3"
    check $eval(parse("b=4"), env) == "4"
    check $eval(parse("d=1+c=a+b"), env) == "8"
    check $eval(parse("d+c"), env) == "15"
