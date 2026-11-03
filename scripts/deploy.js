// Deploy do contrato Turing (ethers v6, hardhat-toolbox 6).
// Uso:  npx hardhat run scripts/deploy.js --network localhost
const fs = require("fs");
const path = require("path");
const hre = require("hardhat");

async function main() {
  const { ethers, network } = hre;

  if (network.name === "hardhat") {
    console.warn(
      "Voce esta fazendo deploy na rede interna do Hardhat (some ao fim do script).\n" +
        "Use: npx hardhat run scripts/deploy.js --network localhost"
    );
  }

  const [deployer] = await ethers.getSigners();
  console.log("Deploy com a conta:", deployer.address);

  const saldo = await ethers.provider.getBalance(deployer.address);
  console.log("Saldo:", ethers.formatEther(saldo), "ETH");

  const Turing = await ethers.getContractFactory("Turing");
  const turing = await Turing.deploy();
  await turing.waitForDeployment();

  const address = await turing.getAddress();
  console.log("Turing implantado em:", address);

  saveFrontendConfig(address);
}

// Grava o endereco em frontend/config.js (lido pelo index.html)
function saveFrontendConfig(address) {
  const dir = path.join(__dirname, "..", "frontend");
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(
    path.join(dir, "config.js"),
    `// gerado por scripts/deploy.js - nao edite\nconst ADDRESS = "${address}";\n`
  );
  console.log("Endereco salvo em frontend/config.js");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
