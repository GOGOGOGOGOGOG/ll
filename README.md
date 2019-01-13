# ll

[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/r-medina/ll/blob/master/LICENSE) 

This project implements a thread-safe linked list for the C language. The API is intended
to be intuitive and simple as well as robust and useful. The data in the linked-list is
stored as a `void *`. The user is not exposed to any of the underlying implementation (no
access to nodes). The mutex on a linked-list, however, is exposed, so the user has access
to that if need be.

## Installing

Running

```bash
$ git clone https://github.com/r-medina/ll.git && cd ./ll/ && make o && cd ..
```

will download this project and build the object code in `ll/obj/`, which can then be
linked or whatever.

`make exec` will build the executable that has the tests.

## Examples

## API

The `include/ll.h` documents all the features to which a user has access.

### Data Structure

The data structure that governs this project is a simple singly-linked-list with a
reader/writer mutex. The two functional attributes help the user print their linked list
and deconstruct the elements.

```c
// linked list
struct ll {
    // running length
    int len;

    // pointer to the first node
    ll_node_t *hd;

    // mutex for thread safety
    pthread_rwlock_t m;

    // a function that is called every time a value is deleted
    // with a pointer to that value
    gen_fun_t val_teardown;

    // a function that can print the values in a linked list
    gen_fun_t val_printer;
};
```

### Functions

```c
// returns a pointer to an allocated linked list.
// needs a taredown function that is called with
// a pointer to the value when it is being deleted.
ll_t *ll_new(gen_fun_t val_teardown);

// traverses the linked list, deallocated everything (including `list`)
void ll_delete(ll_t *list);

// inserts a value into the linked list at position `n`. acceptable values for n are `0`
// (puts it in first) to `list->len` (puts it in last).
// returns the new length of the linked list if successful, -1 otherwise
int ll_insert_n(ll_t *list, void *val, int n);

// puts a value at the front of the linked list.
// returns the new length of the linked list if successful, -1 otherwise
int ll_insert_first(ll_t *list, void *val);

// puts a value at the end of the linked list.
// returns the new length of the linked list if successful, -1 otherwise
int ll_insert_last(ll_t *list, void *val);

// removes the value at position n of the linked list.
// returns the new length of the linked list if successful, -1 otherwise
int ll_remove_n(ll_t *list, int n);

// removes the value at the front of the linked list.
// returns the new length of the linked list if successful, -1 otherwise
int ll_remove_first(ll_t *list);

// given a function that tests the values in the linked list, the first element that
// satisfies that function is removed.
// returns the new length of the linked list if successful, -1 otherwise
int ll_remove_search(ll_t *list, int cond(void *));

// returns a pointer to the `n`th value in the linked list.
// returns `NULL` if unsuccessful
void *ll_get_n(ll_t *list, int n);

// returns a pointer to the first value in a linked list.
// `NULL` if empty
void *ll_get_first(ll_t *list);

// runs f on all values of list
void ll_map(ll_t *list, gen_fun_t f);

// goes through all the values of a linked list and calls `list->val_printer` on them
void ll_print(ll_t list);

// a generic taredown function for values that don't need anything done
void ll_no_teardown(void *n);
```

## Testing

```bash
$ make test
```

---

## Add `test.c` (ref: [concurrent-ll](https://github.com/jserv/concurrent-ll))

### Enviornments
```
$ cat <(echo "CPU:    " `lscpu | grep "Model name" | cut -d':' -f2 | sed "s/  //"`) <(echo "OS:     " `lsb_release -d | cut -f2`) <(echo "Kernel: " `uname -a | cut -d' ' -f1,3,14`) <(echo "gcc:    " `gcc --version | head -n1`)
CPU:     Intel(R) Xeon(R) CPU E5520 @ 2.27GHz
OS:      Ubuntu 16.04.5 LTS
Kernel:  Linux 4.15.0-43-generic x86_64
gcc:     gcc (Ubuntu 5.4.0-6ubuntu1~16.04.11) 5.4.0 20160609
```

### Result
```
(gdb) make clean all
building object files...
gcc -g -O1 -Wall -Werror -Wextra -Wunused -std=gnu99 -D_GNU_SOURCE -pthread -fno-strict-aliasing -D_REENTRANT -pedantic -I"include" -o obj/ll.o -MMD -MF obj/ll.o.d -c src/ll.c
building object files...
gcc -g -O1 -Wall -Werror -Wextra -Wunused -std=gnu99 -D_GNU_SOURCE -pthread -fno-strict-aliasing -D_REENTRANT -pedantic -I"include" -o obj/test.o -MMD -MF obj/test.o.d -c src/test.c
building binary...
gcc -g -O1 -Wall -Werror -Wextra -Wunused -std=gnu99 -D_GNU_SOURCE -pthread -fno-strict-aliasing -D_REENTRANT -pedantic -I"include" -o bin/test obj/ll.o obj/test.o
(gdb) run
`/home/itlab/Desktop/ll/bin/test' has changed; re-reading symbols.
Starting program: /home/itlab/Desktop/ll/bin/test -n\ 3
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".
[New Thread 0x7ffff77ef700 (LWP 5021)]
[New Thread 0x7fffeefee700 (LWP 5022)]
[New Thread 0x7ffff6fee700 (LWP 5023)]
Thread 0
  #operations   : 101973
  #inserts   : 10321
  #removes   : 10320
Thread 1
  #operations   : 100374
  #inserts   : 10184
  #removes   : 10183
Thread 2
  #operations   : 103057
  #inserts   : 10447
  #removes   : 10446
Duration      : 1000 (ms)
#txs     : 305404 (305404.000000 / s)
Expected size: 1026 Actual size: 1026
[Thread 0x7ffff6fee700 (LWP 5023) exited]
[Thread 0x7fffeefee700 (LWP 5022) exited]
[Thread 0x7ffff77ef700 (LWP 5021) exited]
[Inferior 1 (process 5014) exited normally]
```