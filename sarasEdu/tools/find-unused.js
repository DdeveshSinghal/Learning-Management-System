const fs = require('fs');
const path = require('path');

function walk(dir, ext = '.jsx'){
  const files = [];
  for (const name of fs.readdirSync(dir)){
    const full = path.join(dir, name);
    const stat = fs.statSync(full);
    if (stat.isDirectory()){
      files.push(...walk(full, ext));
    } else if (stat.isFile() && full.endsWith(ext)){
      files.push(full);
    }
  }
  return files;
}

const src = path.resolve(__dirname, '..', 'src');
const componentsDir = path.join(src, 'components');
if (!fs.existsSync(componentsDir)){
  console.error('components dir not found:', componentsDir);
  process.exit(1);
}

const componentFiles = walk(componentsDir);
const allFiles = walk(src);

// Read all files into memory (should be OK for this repo)
const contents = {};
for (const f of allFiles){
  try{
    contents[f] = fs.readFileSync(f, 'utf8');
  }catch(e){ contents[f] = '' }
}

function countOccurrencesInAll(name){
  let count = 0;
  for (const f of allFiles){
    const c = contents[f];
    let idx = 0;
    while (true){
      const pos = c.indexOf(name, idx);
      if (pos === -1) break;
      count++;
      idx = pos + name.length;
    }
  }
  return count;
}

for (const f of componentFiles){
  const base = path.basename(f, '.jsx');
  const count = countOccurrencesInAll(base);
  console.log(`${base}|${count}|${f}`);
}
