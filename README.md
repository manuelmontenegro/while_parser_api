# WhileParser API

A web-based interface and API for the [while_parser](https://github.com/manuelmontenegro/while_parser) library.

### Web-based interface

It is already deployed in the following address:

```
http://dalila.sip.ucm.es:4000/
```

Open this address in a web browser to access the web interface.

### API

It accessible from the following URL:

```
POST http://dalila.sip.ucm.es:4000/api/parse
```

The body of the HTTP request has to contain the parameter `while_code` associated with the source code of the while program to be parsed.
Optionally, a `cfg` parameter can be set to `true` in obtain a Control Flow Graph of the main program. If `cfg` is not set (or set to a value different from `true`) the AST of the whole program would be returned.

It returns a JSON object with the following fields:

* `ok`: It takes the value `true` of `false` and indicates whether the parsing was successful or not.
* `body`: In the case in which `ok` takes the value `true`, this field contains the JSON representation of the program (see the description below)
* `start_label`: If the `cfg` parameter is set to `true`, this field would contain the label of the initial block of the program.
* `msg`: In the case in which `ok` is bound to `false`, this field contains a string with the corresponding parser error.
* `line_no`: In the case in which `ok` is bound to `false`, this field contains the line number in the input source code in which parsing failed.

### Example

The following function shows how to issue a request to the API from Python 3.

```python
import http.client
import urllib.parse
import json

SERVER_NAME = 'dalila.sip.ucm.es:4000'
API_URL = '/api/parse'


def send_request(while_code, *, cfg=False):
  conn = http.client.HTTPConnection(SERVER_NAME)
  params = urllib.parse.urlencode({
    'while_code': while_code,
    'cfg': 'true' if cfg else 'false'
  })
  headers = {
    'Content-type': 'application/x-www-form-urlencoded',
    'Accept': 'application/json'
  }

  conn.request('POST', API_URL, params, headers)
  response = conn.getresponse()
  result_json = json.loads(response.read())
  return (response.status, result_json)
```

For example, to obtain the AST of a program:
  
```python 
status, parsed_program = send_request("""
    function fib(x :: int) ret (y :: int)
      if x <= 0 then
        y := 0
      else
        if x <= 1 then
          y := 1
        else
          begin
            var f1 := 0;
            var f2 := 0;
            f1 := fib(x - 1);
            f2 := fib(x - 2);
            y := f1 + f2;
          end
        end
      end
    end
    z := fib(4);
  """)

print('Status code:', status)
  
if parsed_program['ok']:
  print(parsed_program['body'])
else:
  print('Error at line {}: {}'.format(
      		parsed_program['line_no'],
      		parsed_program['msg'])
  )
```

If you want to obtain a CFG from a program, you can call `send_request` as follows:

```python
status, parsed_program = send_request("""
    c := 10;
    y := 1;
    while 1 <= c do
      y := y * c;
      c := c - 1;
    end;
    res := y;
  """, cfg=True)

print('Status code:', status)
  
if parsed_program['ok']:
  print(parsed_program['body'])
  print(parsed_program['start_label'])
else:
  print('Error at line {}: {}'.format(parsed_program['line_no'], parsed_program['msg']))
```


### JSON-based AST representation

Please read the [textual representation](https://github.com/manuelmontenegro/while_parser/blob/master/Syntax.md) first.

Each node in the abstract syntax tree is represented as a JSON object containing four fields:

* `category`: It is a string containing the syntactic category of the node. It can be one of `exp` (expression), `stm` (statement), `program`, `declaration`, or `type`. 
* `category_sub`: It contains the subcategory of the node. For example, inside the `stm` category this field may contain the values `if` (conditional statement), `funapp` (function call), `assignment`, etc.
* `line`: An integer containing the line number corresponding to that node in the source code given as input.
* `options`. A JSON object with the parameters specific to each subcategory. For example, in an `assignment` we have two options, `lhs` and `rhs`, which respectively denote the variable being assigned to, and the expression that occurs at the right-hand side of the `:=` sign.

The following table summarizes the different syntactic categories, with the options supported by each.

| Category      | Subcategory        | Description                                     | Supported options                                            |
| ------------- | ------------------ | ----------------------------------------------- | ------------------------------------------------------------ |
| `exp`         | `literal`          | An integer or boolean literal                   | `number` or `boolean` associated with the corresponding value. |
| `exp`         | `variable`         | A variable.                                     | `name` of the variable.                                      |
| `exp`         | `add`              | Addition: `lhs + rhs`                           | `lhs`, `rhs` denoting each operand.                          |
| `exp`         | `sub`              | Subtraction: `lhs - rhs`                        | `lhs`, `rhs` denoting each operand.                          |
| `exp`         | `mul`              | Multiplication: `lhs * rhs`                     | `lhs`, `rhs` denoting each operand.                          |
| `exp`         | `leq`              | Comparison: `lhs <= rhs`                        | `lhs`, `rhs` denoting each operand.                          |
| `exp`         | `eq`               | Comparison: `lhs == rhs`                        | `lhs`, `rhs` denoting each operand.                          |
| `exp`         | `and`              | Conjunction: `lhs && rhs`                       | `lhs`, `rhs` denoting each operand.                          |
| `exp`         | `or`               | Disjunction: `lhs || rhs`                       | `lhs`, `rhs` denoting each operand.                          |
| `exp`         | `conditional`      | Conditional expression: `condition ? if : else` | `condition`, `if`, `else`                                    |
| `exp`         | `tuple`            | Tuple construction: `(exp1, ..., expn)`         | `components` with a list of subexpressions.                  |
| `exp`         | `hd`               | Head of a list: `l.hd`                          | `lhs` with the operand.                                      |
| `exp`         | `tl`               | Tail of a list: `l.tl`                          | `lhs` with the operand.                                      |
| `exp`         | `cons`             | List construction `[head|tail]`                 | `head`, `tail`                                               |
| `stm`         | `skip`             | No operation: `skip`                            |                                                              |
| `stm`         | `assignment`       | Assignment: `x := e`                            | `lhs` (variable), `rhs` (expression)                         |
| `stm`         | `tuple_assignment` | Assignment: `(x1, ..., xn) := e`                | `lhs` (list of variables), `rhs` (expression)                |
| `stm`         | `fun_app`          | Assignment: `x := f(e1, ..., en)`               | `lhs` (variable), `fun_name` (string), `args`(list of expressions). |
| `stm`         | `if`               | Conditional                                     | `condition` (expression), `then` (list of statements), `else` (list of statements). |
| `stm`         | `while`            | Loop                                            | ` condition` (expression), `body` (list of statements).      |
| `stm`         | `block`            | Scoped block (`begin`...`end`)                  | `decls` (list of variable declarations), `body` (list of statements) |
| `stm`         | `ifnil`            | Conditional for lists                           | `variable` (string), `then` (list of statements), `else` (list of statements). |
| `program`     | `program`          | Top-level program                               | `functions` (list of function declarations), `main_stm` (list of statements) |
| `declaration` | `fun_decl`         | Function declaration                            | `function_name` (string), `params` (list of parameter declarations), `returns` (singleton list of variable declarations), `body` (list of statements) |
| `declaration` | `var_decl`         | Variable declaration                            | `lhs` (string), `rhs` (expression), `type` (type, optional)  |
| `declaration` | `param_decl`       | Parameter declaration                           | `variable` (string), `type` (type, optional).                |
| `type`        | `int`              |                                                 |                                                              |
| `type`        | `bool`             |                                                 |                                                              |
| `type`        | `tuple`            | Tuple of types `(t1, ..., tn)`                  | `components` (list of types)                                 |
| `type`        | `list`             | List type `[t]`                                 | `elements` (type)                                            |
| `type`        | `non_empty_list`   | Non-empty list type `[t]+`                      | `elements` (type)                                            |

### JSON-based CFG representation

If `cfg` is set to `true`, the `result` field contains a list of CFG blocks. Each block contains four fields:

* `type`: determines the contents of the block. It may be `"assignment"`, `"skip"`, or `"condition"`.
* `label`: an integer number that identifies the block.
* `succs`: list of integer numbers that contains the labels of the successors of the block.
* `contents`: contents of the block (see table below).


| Type         | `contents` field |
| ------------ | ---------------- |
| `skip`       | empty object     |
| `assignment` | object with two fields: `lhs` (variable being assigned to) and `rhs` (expression AST) |
| `condition`  | object with one field: `condition` (which is an AST) |
