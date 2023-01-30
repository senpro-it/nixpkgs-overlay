{ pkgs ? import <nixpkgs> { } }:

{
  modules = import ./modules; # NixOS modules
}
