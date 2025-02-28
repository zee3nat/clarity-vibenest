import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can transfer playlist ownership",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    const wallet_2 = accounts.get("wallet_2")!;
    
    // Create playlist
    let block = chain.mineBlock([
      Tx.contractCall("vibenest", "create-playlist", 
        [types.utf8("My Playlist"), types.utf8("Awesome playlist")],
        wallet_1.address
      )
    ]);
    
    // Transfer ownership
    block = chain.mineBlock([
      Tx.contractCall("vibenest", "transfer-playlist-ownership",
        [types.uint(1), types.principal(wallet_2.address)],
        wallet_1.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk();
  },
});

// Include original tests...
