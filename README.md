# J in Nim

Inspired by [first version of J using 42 lines of C](https://code.jsoftware.com/wiki/Essays/Incunabulum) and [a port to Rust](https://github.com/zserge/odetoj). Adds support for variables and numbers longer than 1 character, and has a slightly better display for boxes. Has some safety, but not too much to stay close to original source. For example, verbs are still kept in an array, permitting segmentation faults. Better solution would be a `case` statement.

## Usage

```
nimble test
nimble run jj
```

Some things to try:

```j
+10
{10
~10
#10
#~10
x=1,2
1+2
x+5,5
1,2,3
1{5,7,9
shp=2,3
shp#~10
#shp#~10
```
