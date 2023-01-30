{ pkgs ? import <nixpkgs> { } }:

{
  modules = import ./nixos; # NixOS modules
}
