// ---------- CPU model (mirrors the verified SystemVerilog exactly) ----------

class CPU {
  constructor() { this.reset(); }

  reset() {
    this.pc = 0;
    this.acc = 0;
    this.regs = new Array(8).fill(0);
    this.zflag = 0;
    this.cflag = 0;
    this.outData = 0;
    this.outValid = false; // out_data is combinational — only meaningful the cycle OUT runs
    this.halted = false;
    this.inData = 0;
  }

  step(memory) {
    if (this.halted) return null;
    const instrByte = memory[this.pc];
    if (instrByte === null || instrByte === undefined) {
      this.halted = true;
      return {
        halted: true,
        reason: `PC reached address ${this.pc}, which was never loaded with a program byte. ` +
                `On the real hardware this reads as undefined (X) and corrupts CPU state from ` +
                `here on — this is exactly the bug class found debugging the real RTL, so the ` +
                `simulator stops instead of pretending it's fine.`
      };
    }

    const opcode = (instrByte >> 4) & 0xF;
    const operand = instrByte & 0xF;
    const regAddr = operand & 0x7;          // hardware only wires the low 3 bits to the reg file
    const jumpTarget = operand;             // {4'b0000, operand} — only addresses 0-15 reachable

    this.outValid = false;
    let nextPc = (this.pc + 1) & 0xFF;
    let log = '';

    switch (opcode) {
      case 0x0:
        log = 'NOP';
        break;
      case 0x1:
        this.acc = this.regs[regAddr];
        log = `LOAD R${regAddr}  (A ← R${regAddr} = ${this.acc})`;
        break;
      case 0x2:
        this.regs[regAddr] = this.acc;
        log = `STORE R${regAddr}  (R${regAddr} ← A = ${this.acc})`;
        break;
      case 0x3: {
        const raw = this.acc + this.regs[regAddr];
        this.acc = raw & 0xFF;
        this.zflag = this.acc === 0 ? 1 : 0;
        this.cflag = raw > 0xFF ? 1 : 0;
        log = `ADD R${regAddr}  (A ← A + R${regAddr} = ${this.acc})`;
        break;
      }
      case 0x4: {
        const a = this.acc, b = this.regs[regAddr];
        this.acc = (a - b) & 0xFF;
        this.zflag = this.acc === 0 ? 1 : 0;
        this.cflag = a >= b ? 1 : 0;
        log = `SUB R${regAddr}  (A ← A - R${regAddr} = ${this.acc})`;
        break;
      }
      case 0x5:
        this.acc = this.acc & this.regs[regAddr];
        this.zflag = this.acc === 0 ? 1 : 0;
        this.cflag = 0;
        log = `AND R${regAddr}  (A ← A & R${regAddr} = ${this.acc})`;
        break;
      case 0x6:
        this.acc = this.acc | this.regs[regAddr];
        this.zflag = this.acc === 0 ? 1 : 0;
        this.cflag = 0;
        log = `OR R${regAddr}  (A ← A | R${regAddr} = ${this.acc})`;
        break;
      case 0x7:
        this.acc = this.acc ^ this.regs[regAddr];
        this.zflag = this.acc === 0 ? 1 : 0;
        this.cflag = 0;
        log = `XOR R${regAddr}  (A ← A ^ R${regAddr} = ${this.acc})`;
        break;
      case 0x8:
        this.acc = (~this.acc) & 0xFF;
        this.zflag = this.acc === 0 ? 1 : 0;
        this.cflag = 0;
        log = `NOT  (A ← ~A = ${this.acc})`;
        break;
      case 0x9:
        this.cflag = (this.acc >> 7) & 1;
        this.acc = (this.acc << 1) & 0xFF;
        this.zflag = this.acc === 0 ? 1 : 0;
        log = `SHL  (A ← A << 1 = ${this.acc}, C=${this.cflag})`;
        break;
      case 0xA:
        this.cflag = this.acc & 1;
        this.acc = this.acc >> 1;
        this.zflag = this.acc === 0 ? 1 : 0;
        log = `SHR  (A ← A >> 1 = ${this.acc}, C=${this.cflag})`;
        break;
      case 0xB:
        nextPc = jumpTarget;
        log = `JMP ${jumpTarget}`;
        break;
      case 0xC:
        if (this.zflag) { nextPc = jumpTarget; log = `JZ ${jumpTarget}  (Z=1, taken)`; }
        else log = `JZ ${jumpTarget}  (Z=0, not taken)`;
        break;
      case 0xD:
        if (this.cflag) { nextPc = jumpTarget; log = `JC ${jumpTarget}  (C=1, taken)`; }
        else log = `JC ${jumpTarget}  (C=0, not taken)`;
        break;
      case 0xE:
        this.acc = this.inData & 0xFF;
        log = `IN  (A ← input = ${this.acc})`;
        break;
      case 0xF:
        this.outData = this.acc;
        this.outValid = true;
        log = `OUT  (output ← A = ${this.acc})`;
        break;
    }

    const prevPc = this.pc;
    this.pc = nextPc & 0xFF;
    return { halted: false, prevPc, opcode, operand, log };
  }
}

// ---------- Assembler ----------

const OPCODES = {
  NOP:   { code: 0x0, arg: 'none' },
  LOAD:  { code: 0x1, arg: 'reg' },
  STORE: { code: 0x2, arg: 'reg' },
  ADD:   { code: 0x3, arg: 'reg' },
  SUB:   { code: 0x4, arg: 'reg' },
  AND:   { code: 0x5, arg: 'reg' },
  OR:    { code: 0x6, arg: 'reg' },
  XOR:   { code: 0x7, arg: 'reg' },
  NOT:   { code: 0x8, arg: 'none' },
  SHL:   { code: 0x9, arg: 'none' },
  SHR:   { code: 0xA, arg: 'none' },
  JMP:   { code: 0xB, arg: 'addr' },
  JZ:    { code: 0xC, arg: 'addr' },
  JC:    { code: 0xD, arg: 'addr' },
  IN:    { code: 0xE, arg: 'none' },
  OUT:   { code: 0xF, arg: 'none' },
};

function assemble(source) {
  const rawLines = source.split('\n');
  const cleaned = [];
  for (const raw of rawLines) {
    const line = raw.split(';')[0].trim();
    if (line) cleaned.push(line);
  }

  const labels = {};
  const instrLines = [];
  let addr = 0;
  for (let line of cleaned) {
    const m = line.match(/^(\w+):\s*(.*)$/);
    if (m) {
      const label = m[1];
      if (labels.hasOwnProperty(label)) throw new Error(`Duplicate label "${label}"`);
      labels[label] = addr;
      line = m[2].trim();
    }
    if (line) { instrLines.push({ addr, text: line }); addr++; }
  }
  if (addr > 256) throw new Error(`Program is ${addr} instructions, but instruction memory only holds 256 bytes.`);

  const memory = new Array(256).fill(null);
  for (const { addr, text } of instrLines) {
    const parts = text.split(/\s+/);
    const mnemonic = parts[0].toUpperCase();
    const info = OPCODES[mnemonic];
    if (!info) throw new Error(`Unknown instruction "${mnemonic}" at address ${addr}`);

    let operand = 0;
    if (info.arg === 'reg') {
      const m = (parts[1] || '').toUpperCase().match(/^R([0-7])$/);
      if (!m) throw new Error(`"${mnemonic}" at address ${addr} needs a register operand R0-R7, got "${parts[1] || ''}"`);
      operand = parseInt(m[1], 10);
    } else if (info.arg === 'addr') {
      const arg = parts[1];
      if (!arg) throw new Error(`"${mnemonic}" at address ${addr} needs a jump target`);
      let target;
      if (labels.hasOwnProperty(arg)) target = labels[arg];
      else if (/^0x[0-9a-fA-F]+$/.test(arg)) target = parseInt(arg, 16);
      else if (/^\d+$/.test(arg)) target = parseInt(arg, 10);
      else throw new Error(`"${mnemonic}" at address ${addr}: unknown label or address "${arg}"`);
      if (target < 0 || target > 15) throw new Error(`"${mnemonic}" at address ${addr}: jump target ${target} is out of range — this ISA's operand field is only 4 bits, so JMP/JZ/JC can only reach addresses 0-15 (a real hardware limitation, not a simulator restriction).`);
      operand = target;
    }
    memory[addr] = ((info.code & 0xF) << 4) | (operand & 0xF);
  }
  return { memory, length: addr };
}

// ---------- ISA reference + example programs ----------

const ISA_INFO = [
  ['0000', 'NOP',      'no operation'],
  ['0001', 'LOAD Rn',  'A ← R[n]'],
  ['0010', 'STORE Rn', 'R[n] ← A'],
  ['0011', 'ADD Rn',   'A ← A + R[n]'],
  ['0100', 'SUB Rn',   'A ← A − R[n]'],
  ['0101', 'AND Rn',   'A ← A & R[n]'],
  ['0110', 'OR Rn',    'A ← A | R[n]'],
  ['0111', 'XOR Rn',   'A ← A ^ R[n]'],
  ['1000', 'NOT',      'A ← ~A'],
  ['1001', 'SHL',      'A ← A << 1'],
  ['1010', 'SHR',      'A ← A >> 1'],
  ['1011', 'JMP addr', 'PC ← addr (0–15)'],
  ['1100', 'JZ addr',  'PC ← addr if Z=1'],
  ['1101', 'JC addr',  'PC ← addr if C=1'],
  ['1110', 'IN',       'A ← input'],
  ['1111', 'OUT',      'output ← A'],
];

const EXAMPLES = {
    addition: {
    name: 'Adding two numbers (start here)',
    source: `; ADDING TWO NUMBERS, the simplest possible program.
;
; This CPU has one main "workspace" called the accumulator (ACC). Almost
; everything happens by moving a value into ACC, then doing something to it.
;
; Steps that happen in the CPU:
;   1. Read the first number in from the Input box into ACC
;   2. Save it into register R0, since ACC is about to be overwritten
;   3. Read the second number in from the Input box into ACC
;   4. Add R0 (the first number) to ACC (the second number)
;   5. Send ACC to the Output
;
; You try it: set Input value to 3, click Step (executes the first IN), then
; set Input value to 5 and click Step three more times. After ADD R0,
; ACC should read 08 — and OUT will show 08 too. Note that the output is in
; hexadecimal, so if your result is >10 (like 5 + 7), it will show in hexadecimal
; but the answer will still be correct. Search "## hexadecimal to decimal" and 
; you'll see the answer you were looking for.

IN          ; ACC = first number (from Input value)
STORE R0    ; R0 = ACC   (save the first number so it isn't lost)
IN          ; ACC = second number (from Input value)
ADD R0      ; ACC = ACC + R0   (this is the actual addition!)
OUT         ; send ACC to Output`
  },
  first: {
    name: 'First verified program (LOAD/STORE/ADD/OUT/NOT)',
    source: `; The very first program this CPU ran correctly end-to-end.
; Set Input value to 5, Step through the first IN, then set it to 7
; before stepping past the second IN, to match the original trace.
LOAD R0
STORE R0
LOAD R0
STORE R1
IN
ADD R1
OUT
NOT`
  },
  sub: {
    name: 'SUB across the nibble boundary (0x10 - 0x01)',
    source: `; This is the exact case that caught a real bug in the SystemVerilog:
; the subtractor's borrow-out from the low nibble wasn't wired into the
; high nibble's borrow-in. Set Input value to 1, step past the first IN,
; then set Input value to 16 (0x10) before stepping past the second IN.
IN
STORE R1
IN
SUB R1
OUT`
  },
  branch: {
    name: 'JZ / JC branch test',
    source: `; Exercises JZ taken, JZ not-taken, JC taken, and JC not-taken.
; Set Input value to anything nonzero (e.g. 5) before stepping past the IN.
        SUB R0
        JZ landing
        NOP
        NOP
        NOP
landing:
        IN
        ADD R0
        JZ skip
        JC skip
        SUB R0
        JC finish
skip:   NOP
        NOP
finish: OUT`
  },
  full: {
    name: 'Full instruction set (AND/OR/XOR/NOT/SHL/SHR/JMP)',
    source: `; Runs every remaining opcode once. Set Input value to 165 (0xA5) for
; the first IN, then 15 (0x0F) for the next four, then 129 (0x81) for
; the last two, stepping between each change.
start:
        IN
        STORE R0
        IN
        AND R0
        IN
        OR R0
        IN
        XOR R0
        IN
        NOT
        IN
        SHL
        IN
        SHR
        NOP
        JMP start`
  }
};

// ---------- Datapath diagram ----------

const DP_BLOCKS = {
  pc:      { x: 20,  y: 20,  w: 90,  h: 46, label: 'PC' },
  imem:    { x: 150, y: 20,  w: 110, h: 46, label: 'Instr Mem' },
  decode:  { x: 300, y: 20,  w: 90,  h: 46, label: 'Decode' },
  ctrl:    { x: 300, y: 100, w: 90,  h: 46, label: 'Ctrl Unit' },
  regfile: { x: 20,  y: 170, w: 110, h: 46, label: 'Reg File' },
  alu:     { x: 170, y: 170, w: 90,  h: 46, label: 'ALU' },
  flags:   { x: 300, y: 170, w: 70,  h: 46, label: 'Flags' },
  acc:     { x: 410, y: 170, w: 90,  h: 46, label: 'Accum' },
  out:     { x: 540, y: 170, w: 80,  h: 46, label: 'Output' },
};

const DP_WIRES = [
  ['pc', 'imem'], ['imem', 'decode'], ['decode', 'ctrl'],
  ['ctrl', 'regfile'], ['ctrl', 'alu'], ['ctrl', 'flags'], ['ctrl', 'acc'], ['ctrl', 'pc'],
  ['regfile', 'alu'], ['acc', 'alu'], ['alu', 'acc'], ['alu', 'flags'], ['acc', 'out'],
];

function buildDatapath() {
  const svg = document.getElementById('datapath');
  svg.innerHTML = '';
  const ns = 'http://www.w3.org/2000/svg';
  const center = b => [b.x + b.w / 2, b.y + b.h / 2];

  for (const [fromId, toId] of DP_WIRES) {
    const [ax, ay] = center(DP_BLOCKS[fromId]);
    const [bx, by] = center(DP_BLOCKS[toId]);
    const line = document.createElementNS(ns, 'line');
    line.setAttribute('x1', ax); line.setAttribute('y1', ay);
    line.setAttribute('x2', bx); line.setAttribute('y2', by);
    line.setAttribute('class', 'dp-wire');
    svg.appendChild(line);
  }

  for (const [id, b] of Object.entries(DP_BLOCKS)) {
    const rect = document.createElementNS(ns, 'rect');
    rect.setAttribute('x', b.x); rect.setAttribute('y', b.y);
    rect.setAttribute('width', b.w); rect.setAttribute('height', b.h);
    rect.setAttribute('rx', 8);
    rect.setAttribute('class', 'dp-block');
    rect.setAttribute('id', 'dp-' + id);
    svg.appendChild(rect);

    const [cx, cy] = center(b);
    const text = document.createElementNS(ns, 'text');
    text.setAttribute('x', cx); text.setAttribute('y', cy + 4);
    text.setAttribute('class', 'dp-label');
    text.textContent = b.label;
    svg.appendChild(text);
  }
}

function highlightDatapath(opcode) {
  const always = ['pc', 'imem', 'decode', 'ctrl'];
  let extra = [];
  if (opcode === 0x1 || opcode === 0x2) extra = ['regfile', 'acc'];
  else if ([0x3, 0x4, 0x5, 0x6, 0x7].includes(opcode)) extra = ['regfile', 'alu', 'flags', 'acc'];
  else if ([0x8, 0x9, 0xA].includes(opcode)) extra = ['alu', 'flags', 'acc'];
  else if ([0xB, 0xC, 0xD].includes(opcode)) extra = ['pc'];
  else if (opcode === 0xE) extra = ['acc'];
  else if (opcode === 0xF) extra = ['acc', 'out'];

  const activeSet = new Set([...always, ...extra]);
  for (const id of Object.keys(DP_BLOCKS)) {
    document.getElementById('dp-' + id).classList.toggle('active', activeSet.has(id));
  }
}

// ---------- UI wiring ----------

let cpu = new CPU();
let memory = new Array(256).fill(null);
let running = false;
let runTimer = null;

const el = {
  asmSource: document.getElementById('asm-source'),
  assembleBtn: document.getElementById('assemble-btn'),
  assembleStatus: document.getElementById('assemble-status'),
  exampleSelect: document.getElementById('example-select'),
  resetBtn: document.getElementById('reset-btn'),
  stepBtn: document.getElementById('step-btn'),
  runBtn: document.getElementById('run-btn'),
  pauseBtn: document.getElementById('pause-btn'),
  speedSlider: document.getElementById('speed-slider'),
  inData: document.getElementById('in-data'),
  outValue: document.getElementById('out-value'),
  pcVal: document.getElementById('pc-val'),
  accVal: document.getElementById('acc-val'),
  zVal: document.getElementById('z-val'),
  cVal: document.getElementById('c-val'),
  regfile: document.getElementById('regfile'),
  currentInstr: document.getElementById('current-instr'),
  log: document.getElementById('log'),
  isaTableBody: document.getElementById('isa-table-body'),
  hexOutput: document.getElementById('hex-output'),
};

const hex2 = n => n.toString(16).padStart(2, '0');

function populateIsaTable() {
  el.isaTableBody.innerHTML = ISA_INFO.map(([bits, mnem, effect]) =>
    `<tr><td>${bits}</td><td>${mnem}</td><td>${effect}</td></tr>`).join('');
}

function populateExamples() {
  for (const [key, ex] of Object.entries(EXAMPLES)) {
    const opt = document.createElement('option');
    opt.value = key;
    opt.textContent = ex.name;
    el.exampleSelect.appendChild(opt);
  }
}

function renderRegFile() {
  el.regfile.innerHTML = cpu.regs.map((v, i) =>
    `<div class="reg-box"><span class="reg-name"><a href="#term-register" class="term-link">R${i}</a></span><span class="reg-val">${hex2(v)}</span></div>`).join('');
}


function renderState() {
  el.pcVal.textContent = hex2(cpu.pc);
  el.accVal.textContent = hex2(cpu.acc);
  el.zVal.textContent = cpu.zflag;
  el.cVal.textContent = cpu.cflag;
  renderRegFile();

  if (cpu.outValid) {
    el.outValue.textContent = hex2(cpu.outData) + ' (live this step)';
    el.outValue.classList.add('live');
  } else {
    el.outValue.textContent = '00 (idle)';
    el.outValue.classList.remove('live');
  }

  const instrByte = memory[cpu.pc];
  if (cpu.halted) {
    el.currentInstr.textContent = 'halted';
  } else if (instrByte === null || instrByte === undefined) {
    el.currentInstr.textContent = `PC=${cpu.pc}: (no instruction loaded here)`;
  } else {
    const opcode = (instrByte >> 4) & 0xF;
    const operand = instrByte & 0xF;
    el.currentInstr.textContent =
      `PC=${cpu.pc}  ${instrByte.toString(2).padStart(8, '0')}  ` +
      `(opcode ${opcode.toString(2).padStart(4, '0')}, operand ${operand.toString(2).padStart(4, '0')})`;
  }
}

function appendLog(text, cls) {
  const line = document.createElement('div');
  if (cls) line.className = cls;
  line.textContent = text;
  el.log.appendChild(line);
  el.log.scrollTop = el.log.scrollHeight;
}

function doStep() {
  if (cpu.halted) { stopRun(); return; }
  cpu.inData = parseInt(el.inData.value, 10) || 0;
  const result = cpu.step(memory);
  if (!result) return;
  if (result.halted) {
    appendLog(result.reason, 'halted');
    stopRun();
    renderState();
    return;
  }
  const cls = result.log.includes('taken)') ? (result.log.includes('not taken') ? 'not-taken' : 'taken') : '';
  appendLog(`PC=${result.prevPc}: ${result.log}`, cls);
  highlightDatapath(result.opcode);
  renderState();
}

function doReset() {
  stopRun();
  cpu.reset();
  el.log.innerHTML = '';
  buildDatapath();
  renderState();
}

function startRun() {
  if (running) return;
  running = true;
  el.runBtn.disabled = true;
  el.pauseBtn.disabled = false;
  const delay = Math.max(20, 550 - el.speedSlider.value * 25);
  runTimer = setInterval(() => {
    if (cpu.halted) { stopRun(); return; }
    doStep();
  }, delay);
}

function stopRun() {
  running = false;
  el.runBtn.disabled = false;
  el.pauseBtn.disabled = true;
  if (runTimer) { clearInterval(runTimer); runTimer = null; }
}

function doAssemble() {
  try {
    const result = assemble(el.asmSource.value);
    memory = result.memory;
    el.assembleStatus.textContent = `Assembled ${result.length} instruction${result.length === 1 ? '' : 's'}.`;
    el.assembleStatus.className = 'ok';
    el.hexOutput.textContent = memory.slice(0, result.length).map(hex2).join(' ');
    doReset();
  } catch (e) {
    el.assembleStatus.textContent = e.message;
    el.assembleStatus.className = 'error';
  }
}

el.assembleBtn.addEventListener('click', doAssemble);
el.resetBtn.addEventListener('click', doReset);
el.stepBtn.addEventListener('click', () => { stopRun(); doStep(); });
el.runBtn.addEventListener('click', startRun);
el.pauseBtn.addEventListener('click', stopRun);
el.exampleSelect.addEventListener('change', () => {
  const key = el.exampleSelect.value;
  if (!key) return;
  el.asmSource.value = EXAMPLES[key].source;
  doAssemble();
});

populateIsaTable();
populateExamples();
el.asmSource.value = EXAMPLES.addition.source;
doAssemble();
