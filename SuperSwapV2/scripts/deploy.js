const {ethers} = require("hardhat");

async function main() {
  const SuperSwapV2FactoryContract = await ethers.getContractFactory("SuperSwapV2Factory");
  const deployedSuperSwapV2Factory = await SuperSwapV2FactoryContract.deploy();
  await deployedSuperSwapV2Factory.deployed();
  console.log(`SuperSwapV2Factory Contract Address: ${deployedSuperSwapV2Factory.address}`);

    console.log("Waiting for block confirmations & Verifying.....")
    await deployedSuperSwapV2Factory.deployTransaction.wait(5)
    await verify(deployedSuperSwapV2Factory.address, [])
}

const verify = async (contractAddress, args) => {
  console.log("Verifying contract.....")
  try {
    await run("verify:verify", {
      address: contractAddress,
      constructorArguments: args,
    })
  } catch (e) {
    if (e.message.toLowerCase().includes("already verified")) {
      console.log("Already Verified!")
    } else {
      console.log(e)
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });