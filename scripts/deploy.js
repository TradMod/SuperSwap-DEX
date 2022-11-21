const {ethers} = require("hardhat");

async function main() {
  const SuperSwapContract = await ethers.getContractFactory("SuperSwap");
  const deployedSuperSwap = await SuperSwapContract.deploy();
  await deployedSuperSwap.deployed();
  console.log(`SuperSwap Contract Address: ${deployedSuperSwap.address}`);

    console.log("Waiting for block confirmations & Verifying.....")
    await deployedSuperSwap.deployTransaction.wait(5)
    await verify(deployedSuperSwap.address, [])
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