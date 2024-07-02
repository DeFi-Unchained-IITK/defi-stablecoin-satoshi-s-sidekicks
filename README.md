**EXPLAINING THE FUNCTIONALITY OF DUNcore.sol**

DUNcore enables flexible and secure system for minting and managing stablecoin. At the central 
level DUNcore functions via overcollateralization. It allows users to deposit either WETH or WBTC. 
After this step. They are allowed to mint DUN tokens. The number of DUNs a user may mint is 
decided by the value of their collateral. This is dynamically calculated using Chainlink price feeds. 
Oracles provide WETH and WBTC real-time accurate price data. This data ensures the system always 
has up-to-date information. It keeps track of the value of the collateral.

It keeps track of a user's position through Users' position struct. This struct monitors how much 
WETH and WBTC the user has deposited as collateral. It also tracks how much DUN they have 
minted. This information is crucial. It maintains the system's health. It helps determine when a 
position might be at risk of undercollateralized.

Liquidation has been one of the main features of DUNcore. As delineated by the contract 
LIQUIDATION_THRESHOLD should always be above 150%. This indicates that user's position shall 
always be above 150% collateralized. For it to be regarded as healthy failure to not be above this 
threshold makes it liable for liquidation. At this point, other users come in. They act as liquidators. 
They can use liquidatePosition function. This allows them to liquidate an under-collateralized 
position. They receive LIQUIDATION_BONUS of 10%. This serves as incentive for their contribution 
towards maintaining the stability of system.

The contract has few key functions. Through these users can interact with the system. 
DepositCollateralAndMintDUN function is available. This allows user to provide collateral and mint 
DUN tokens in one transaction. On the other side an operation exists to burn DUN tokens. Users can 
redeem collateral too. Both functions have checks that ensure the health of user's position after the operation.

It has a getHealthFactor function that evaluates the health of user's position. It is given as a ratio of 
the total value of collateral of user to their minted DUN in percentage. The health factor above the 
LIQUIDATION_THRESHOLD shows healthy position. Anything below puts it at risk of liquidation.

The contract also has several safety measures. These ensure its stability and security. It uses 
OpenZeppelin's IERC20 interface for standardized token interactions. These are secure. Chainlink 
price feeds ensure manipulation resistance in price data. This is important for the correct valuation 
of collateral. Checks within all of its functions prevent actions. These would leave the position 
undercollateralized.





**EXPLAINING THE FUNCTIONALITY OF DUNcore.t.sol**

The following is an extensive unit test suite against a stablecoin contract called DUNcore. The test 
file DUNcoreTest, tests all aspects to make sure that DUNcore system works fine. What follows is a 
breakdown of what this test suite does and why it is quite important in ensuring reliability of the 
stablecoin contract.

The first step of the test suite is importing inherent contracts and libraries that will be used. The 
main DUNcore contract and DUN token contract are included. Mock ERC20 tokens including WETH 
and WBTC and mock price feed aggregators are also incorporated. These mock contracts give 
controlled test environments. We can simulate token balance. Individual price feeds are 
manipulated at will.

In the setUp function the testing environment is initialized. This function deploys all necessary 
contracts for DUN token itself. The mock WETH and WBTC tokens, the corresponding price feed 
mocks and DUNcore contract are also set. After that it fixes initial prices for WETH ($3000) and WBTC 
($50000) using mock price feeds. Furthermore, it mints test tokens to a user address. The DUNcore 
contract sets up the stage for further tests.

The first test function testDepositAndMint, assures the fundamental functionality of depositing 
collateral and minting DUN tokens. It simulates user who deposits 100 WETH and mints 200 DUN. 
This test ensures that the deposit has been implemented correctly and minting has been done 
correctly. The correct amount of DUN tokens has been received by the user.

The testBurnAndRedeem function tests the reverse process. This involves burning of DUN tokens 
and redeeming collateral. It first deposits and mints like in the previous test. Afterwards it burns 100 
DUN. It redeems 50 WETH. This test will make sure that the process of burning works as expected. 
Redemption also works with the right amount of DUN burned and WETH returned back to the user

One of the most interesting functions, testLiquidate sets up a case for testing the health factor 
calculation according to the system. This test simulates the following scenario. A user's position is 
undercollateralized due to the price drop of the collateral WETH. The steps in this function are as 
follows
A user deposits collateral and mints DUN.
It asserts the initial health factor of the position.
It then simulates a steep drop in the price of WETH from $3000 down to $1500.
Again health factor is checked on the change after the price drop.

Throughout these tests. The code makes heavy use of Forge's cheatcodes such as vm.startPrank and 
vm.stopPrank to simulate actions from different addresses. It also uses assertEq to ensure that 
something went as expected. This test suite provides a thorough check of the functionality of the 
DUNcore contract. It aims to bring out its reliability and stability before its deployment on a live 
network. The most important tests here are the operations that a user would execute. Critical 
scenarios like liquidations guarantee the long-term viability of the Stablecoin system.



