{pkgs}: let
  lib = pkgs.lib;
in rec {
  isSupported = pkg: (builtins.tryEval pkg).success;

  pathParts = nameOrPath:
    if builtins.isList nameOrPath
    then nameOrPath
    else lib.splitString "." nameOrPath;

  require = name:
    if builtins.hasAttr name pkgs && isSupported (builtins.getAttr name pkgs)
    then builtins.getAttr name pkgs
    else throw "Missing required package in nixpkgs: ${name}";

  pickOptional = name:
    if builtins.hasAttr name pkgs && isSupported (builtins.getAttr name pkgs)
    then builtins.getAttr name pkgs
    else null;

  pickOptionalPath = nameOrPath: let
    parts = pathParts nameOrPath;
    candidate = lib.attrByPath parts null pkgs;
  in
    if lib.hasAttrByPath parts pkgs && candidate != null && isSupported candidate
    then candidate
    else null;

  pickOptionalPaths = names:
    builtins.map pickOptionalPath names;

  pickFirstRequired = shellName: names: let
    found = builtins.filter (name: builtins.hasAttr name pkgs && isSupported (builtins.getAttr name pkgs)) names;
  in
    if found == []
    then throw "${shellName}: missing one required package from set: ${lib.concatStringsSep ", " names}"
    else builtins.getAttr (builtins.head found) pkgs;

  pickFirstOptional = names: let
    found = builtins.filter (name: builtins.hasAttr name pkgs && isSupported (builtins.getAttr name pkgs)) names;
  in
    if found == []
    then null
    else builtins.getAttr (builtins.head found) pkgs;

  filterPresent = packages:
    lib.filter (pkg: pkg != null) packages;

  missingOptionalPaths = names:
    builtins.filter (name: pickOptionalPath name == null) names;
}
