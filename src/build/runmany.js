#!/usr/bin/env node
import minimist from 'minimist';
import { buildAndImport, buildOne } from './build-example.js';

let {
  _: [filePath],
  main,
  default: runDefault,
  keep,
  bundle,
} = minimist(process.argv.slice(2));

if (!filePath) {
  console.log(`Usage:
npx snarky-run [file]`);
  process.exit(0);
}
if (!bundle) {
  let absPath = await buildOne(filePath);
  console.log(`running ${absPath}`);
  let module = await import(absPath);
    if (main) {
	console.log(`await main`);
	await module.main();
    }
    if (runDefault) {
	console.log(`await default`);
	await module.default();
    }
} else {
    console.log(`running2 ${absPath}`);
  let module = await buildAndImport(filePath, { keepFile: !!keep });
  if (main) await module.main();
  if (runDefault) await module.default();
}
