[<< back](README.md)

# Target weight

* Changing default target weight:

```ruby
# File: network.rb

group "Using file: network" do
  target "Update computer name with #{get(:hostname)}"
  run "hostname", on: :host1
  expect_one get(:hostname)

  target "Ensure DNS Server is working", weight: 2.0
  run "host www.google.es", on: :host1
  expect "www.google.es has address "
end
```

```
❯ teuton check examples/07-target_weight

+--------------------------+
| GROUP: Using file: users |
+--------------------------+
(001) target      Create user get(username)
      weight      1.0
      run         'id get(username)' on host1
      expect      get(username) (String)

+----------------------------+
| GROUP: Using file: network |
+----------------------------+
(002) target      Update computer name with get(hostname)
      weight      1.0
      run         'hostname' on host1
      expect_one  get(hostname) (String)

(003) target      Ensure DNS Server is working
      weight      2.0
      run         'host www.google.es' on host1
      expect      www.google.es has address  (String)
```
