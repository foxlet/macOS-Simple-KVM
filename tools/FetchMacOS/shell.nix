{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  propagatedBuildInputs = with pkgs.python3Packages; [
    python
    requests
    click
  ];
}
