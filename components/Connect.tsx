import React from 'react'
import { ethers } from 'ethers';
import { Button } from './ui/button';

type connectProps = {
    account: string
    setAccount: string
}

function Connect( connectProps ) {
    const connectHandler = async () => {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        const account = ethers.utils.getAddress(accounts[0]);
        setAccount(account);
    };
    
    return (
    <div>
       {account ? (
              <Button
                variant="outline"
                aria-label="connect wallet"
              >
                {account.slice(0, 6) + '...' + account.slice(38, 42)}
              </Button>
            ) : (
              <Button
                variant="outline"
                aria-label="connect wallet"
                onClick={connectHandler}
              >
                Connect
              </Button>
            )}
    </div>
  )
}

export default Connect