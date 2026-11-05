const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

// Execute QML JavaScript modules with the same explicit imports as Quickshell.
module.exports = function load(file) {
  const filename = path.resolve(__dirname, '..', file);
  const scope = vm.createContext({});
  const source = fs.readFileSync(filename, 'utf8').replace(
    /^\.import "([^"]+)" as (\w+)\s*$/gm,
    (_, dependency, name) => { scope[name] = module.exports(dependency); return ''; }
  );
  vm.runInContext(source, scope, {filename});
  return scope;
};
