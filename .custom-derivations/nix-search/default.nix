with (import <nixpkgs> {} );

python3Packages.buildPythonPackage rec {
  pname = "nix-search";
  version = "0.0.1";

  src = /home/kai/.derivations/nix-search;
  buildInputs = [ python3Packages.pbr ];
  propagatedBuildInputs = with python3Packages; [
    pandas
    fuzzywuzzy
    numpy
  ];

  meta = {
    description = "A nix package search that doesn't suck";
  };
}
