{ pkgs ? import <nixpkgs> { } }:
let
  hello = pkgs.hello;
  world = "world";
in
{
  example = hello;
  greeting = "Hello ${world}";
}
