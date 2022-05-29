## A simple smart contract in Solidity for charity use case
#

## Description

The smart contract can work for single charity at a time. The deployer must provide *name*, *an address for releasing funds*, and *address of administrator*.

Only administrator can set charity target amount. 

The smart contract keeps track of donors and total donation amount(in Wei) for each donor. Each time donor makes donation, they can see the accumulated amount.

If charity target amount(in Wei) is reached or exceeded administrator can release funds to receiver address. Requests for releasing funds are rejected if smart contract balance is below target amount.

