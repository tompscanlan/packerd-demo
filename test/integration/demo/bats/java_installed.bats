#!/usr/bin/env bats

@test "java binary is found in PATH" {
  run which /opt/jdk/bin/java
  [ "$status" -eq 0 ]
}

