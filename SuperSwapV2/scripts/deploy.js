const {ethers} = require("hardhat");

async function main() {
  const SuperSwapV2Contract = await ethers.getContractFactory("SuperSwapV2");
  const deployedSuperSwapV2 = await SuperSwapV2Contract.deploy();
  await deployedSuperSwapV2.deployed();
  console.log(`SuperSwapV2 Contract Address: ${deployedSuperSwapV2.address}`);

    console.log("Waiting for block confirmations & Verifying.....")
    await deployedSuperSwapV2.deployTransaction.wait(5)
    await verify(deployedSuperSwapV2.address, [])
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