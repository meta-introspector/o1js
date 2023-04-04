import {
  Field,
  declareState,
  declareMethods,
  State,
  PrivateKey,
  SmartContract,
  isReady,
  shutdown,
  addCachedAccount,
  Mina,
  verify,
  AccountUpdate,
  UInt32,
} from 'snarkyjs';

await isReady;
const zkappTargetBalance = 10_000_000_000;
const initialBalance = zkappTargetBalance;
const transactionFee = 10_000_000;
const initialState = Field(1);

class SimpleZkapp extends SmartContract {
  constructor(address) {
    super(address);
    this.x = State();
  }

  init() {
    super.init();
    this.x.set(initialState);
  }

  update(y) {
    let x = this.x.get();
    this.x.assertEquals(x);
    y.assertGt(0);
    this.x.set(x.add(y));
  }
}
// note: this is our non-typescript way of doing what our decorators do
declareState(SimpleZkapp, { x: Field });
declareMethods(SimpleZkapp, { update: [Field] });

// parse command line; for local testing, use random keys as fallback
let [command, zkappKeyBase58, feePayerKeyBase58, feePayerNonce] =
  process.argv.slice(2);
zkappKeyBase58 ||= PrivateKey.random().toBase58();
feePayerKeyBase58 ||= PrivateKey.random().toBase58();
feePayerNonce ||= command === 'update' ? '1' : '0';
console.log(
  `simple-zkapp.js: Running "${command}" with zkapp key ${zkappKeyBase58}, fee payer key ${feePayerKeyBase58} and fee payer nonce ${feePayerNonce}`
);

let zkappKey = PrivateKey.fromBase58(zkappKeyBase58);
let zkappAddress = zkappKey.toPublicKey();

if (command === 'deploy') {
  // snarkyjs part
  let feePayerKey = PrivateKey.fromBase58(feePayerKeyBase58);
  let feePayerAddress = feePayerKey.toPublicKey();
  addCachedAccount({
    publicKey: feePayerKey.toPublicKey(),
    nonce: UInt32.from(feePayerNonce),
  });

  let { verificationKey } = await SimpleZkapp.compile();
  let tx = await Mina.transaction(
    { sender: feePayerAddress, fee: transactionFee },
    () => {
      let senderUpdate = AccountUpdate.fundNewAccount(feePayerAddress);
      let zkapp = new SimpleZkapp(zkappAddress);
      zkapp.deploy({ verificationKey });
      senderUpdate.send({ to: zkapp, amount: initialBalance });
    }
  );
  tx.sign([zkappKey, feePayerKey]);
  let zkappCommandJson = tx.toJSON();
  console.log(zkappCommandJson);
}

if (command === 'update') {
  // snarkyjs part
  let feePayerKey = PrivateKey.fromBase58(feePayerKeyBase58);
  let { verificationKey } = await SimpleZkapp.compile();
  addCachedAccount({
    publicKey: zkappAddress,
    zkapp: { appState: [initialState, 0, 0, 0, 0, 0, 0, 0], verificationKey },
  });
  let transaction = await Mina.transaction(() => {
    new SimpleZkapp(zkappAddress).update(Field(2));
  });
  let [proof] = await transaction.prove();
  transaction.sign([feePayerKey]);
  let zkappCommandJson = transaction.toJSON();

  let ok = await verify(proof, verificationKey.data);
  if (!ok) throw Error('verification failed');

  console.log(zkappCommandJson);
}

shutdown();