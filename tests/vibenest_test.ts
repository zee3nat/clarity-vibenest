import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Can create new playlist",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("vibenest", "create-playlist", 
        [types.utf8("My Playlist"), types.utf8("Awesome playlist")],
        wallet_1.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    
    // Verify playlist creation
    const result = block.receipts[0].result;
    result.expectOk().expectUint(1);
  },
});

Clarinet.test({
  name: "Can add songs to playlist",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("vibenest", "add-song",
        [types.uint(1), types.utf8("https://music.com/song1")],
        wallet_1.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk();
  },
});
