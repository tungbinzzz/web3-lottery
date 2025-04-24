import { useState, useEffect } from 'react'
import { createAppKit, useAppKitProvider, useAppKitAccount, useAppKit } from '@reown/appkit/react'
import { EthersAdapter } from '@reown/appkit-adapter-ethers'
import { arbitrum, mainnet, sepolia } from '@reown/appkit/networks'
import { BrowserProvider, Contract, formatEther, parseEther, InfuraProvider } from "ethers";
import './assets/App.css'
import LuckyFloaters from "./LuckyFloaters.jsx";
import { shortenAddress } from './lib/utils.js'
import { CONTRACT_ADDRESS, CONTRACT_ABI } from "./contract/contractData.js";
import { toast } from 'react-toastify';

// 1. Get projectId
const projectId = import.meta.env.VITE_WALLET_ID

// 2. Set the networks
const networks = [arbitrum, mainnet, sepolia]

// 3. Create a metadata object - optional
const metadata = {
  name: 'Donate to My Website',
  description: 'My Website helps you donate to your favorite creators.',
  url: 'https://mywebsite.com', // origin must match your domain & subdomain
  icons: ['https://avatars.mywebsite.com/']
}

// 4. Create a AppKit instance
createAppKit({
  adapters: [new EthersAdapter()],
  networks,
  metadata,
  projectId,
  features: {
    analytics: true // Optional - defaults to your Cloud configuration
  }
})

function App() {
  //Lib state
  const { open } = useAppKit()
  const { address, isConnected, caipAddress, status, embeddedWalletInfo } = useAppKitAccount()
  console.log("🚀 ~ App ~ address:", address)
  const { walletProvider } = useAppKitProvider("eip155");

  //App state
  const [amountETH, setAmountETH] = useState(0)
  const [participants, setParticipants] = useState([])
  const [winner, setWinner] = useState({ address: "", balance: "" })
  console.log("🚀 ~ App ~ winner:", winner)
  const [isLoading, setIsLoading] = useState(false)
  const [loadingTransaction, setLoadingTransaction] = useState(false)
  const [txHash, setTxHash] = useState(null)


  //Function to get the balance of the connected wallet
  const getEthBalance = async () => {
    try {
      if (!isConnected || !walletProvider || !address) {
        throw new Error("Wallet not connected or address not available");
      }

      const provider = new BrowserProvider(walletProvider);
      const balanceBigInt = await provider.getBalance(address);
      const balanceFormatted = formatEther(balanceBigInt); // format từ wei → ETH

      return balanceFormatted;
    } catch (err) {
      console.error("❌ Failed to fetch ETH balance:", err);
    }
  }

  const onInputAmountChange = (e) => {
    const value = e.target.value;
    console.log("🚀 ~ onInputAmountChange ~ value:", value)
    setAmountETH(Number(value));
  }

  const handleParticipate = async () => {
    setIsLoading(true);
    setLoadingTransaction(true);
    try {
      if (!walletProvider) {
        showToast("info", "Please connect your wallet to fund the contract.");
        return;
      }

      if (amountETH < 0.01 || isNaN(amountETH)) {
        showToast("error", "Please enter a valid amount.");
        return;
      }

      const balance = await getEthBalance();
      console.log("🚀 ~ handleParticipate ~ balance:", balance)
      if (Number(balance) < Number(amountETH)) {
        showToast("error", "Insufficient balance to fund the contract.");
        return;
      }
      const provider = new BrowserProvider(walletProvider);
      const signer = await provider.getSigner();
      const contract = new Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer);

      const tx = await contract.enterLottery({ value: parseEther(amountETH.toString()) });
      setTxHash(tx.hash);
      setLoadingTransaction(true);
      await tx.wait();

      showToast("success", "Transaction successful!");
      fetchContractData();
    } catch (err) {
      console.error("❌ Error funding contract:", err);
      showToast("error", `Transaction failed: ${err?.reason || err?.message}`);
    } finally {
      setIsLoading(false);
      setLoadingTransaction(false);
    }
  };

  const fetchContractData = async () => {
    let ethersProvider;
    if (!walletProvider) {
      ethersProvider = new InfuraProvider("sepolia", import.meta.env.SEPOLIA_RPC_KEY);
    } else {
      ethersProvider = new BrowserProvider(walletProvider);
    }
    try {
      const contract = new Contract(CONTRACT_ADDRESS, CONTRACT_ABI, ethersProvider);
      const participantsLength = await contract.getPlayersLength();
      const winner = await contract.getRecentWinner();
      const winnerBalance = await contract.getWinnerBalance(winner);
      let participants = [];
      for (let i = 0; i < participantsLength; i++) {
        const participant = await contract.getPlayerByIndex(i);
        participants.push(participant);
      }
      setWinner({ address: winner, balance: winnerBalance });
      setParticipants(participants);
    } catch (error) {
      console.error("❌ fetchContractData error:", error);
      showToast("error", "Failed to fetch contract data.");
    }

  };

  const handleClaimPrize = async () => {
    setIsLoading(true);
    setLoadingTransaction(true);
    try {
      const provider = new BrowserProvider(walletProvider);
      const signer = await provider.getSigner();
      const contract = new Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer);

      const tx = await contract.windrawReward();
      await tx.wait();
      showToast("success", "Đã nhận giải thưởng!");
      fetchContractData(); // refresh lại data
    } catch (err) {
      console.error("❌ Lỗi khi nhận giải:", err);
      showToast("error", "Không thể nhận giải.");
    } finally {
      setIsLoading(false);
      setLoadingTransaction(false);
    }
  }

  const showToast = (type, message) => {
    toast[type](message, {
      position: "top-center",
      autoClose: 5000,
      hideProgressBar: false,
      closeOnClick: false,
      pauseOnHover: true,
      draggable: true,
      progress: undefined,
      theme: "light",
    });
  };

  useEffect(() => {
    fetchContractData();
  }, [walletProvider, isLoading]);


  return (
    <>
      <LuckyFloaters />
      <div className="relative z-10 w-full max-w-4xl ...">
        <div className="w-full max-w-4xl bg-[#1a1a2e] rounded-2xl p-8 neon-border">
          <h1 className="text-4xl font-bold text-center neon-text text-[#00fff2] mb-8">🎲 Lottery Sepolia</h1>
          <p className="text-center text-sm text-[#7fffd4] mb-4 italic animate-float glow-text">
            "Try your luck – where every block could be a jackpot!"
          </p>

          <p className="text-center text-xs text-[#00fff2] mb-8">
            📜 Contract: <a href={`https://sepolia.etherscan.io/address/${CONTRACT_ADDRESS}`} target="_blank" rel="noopener noreferrer" className="underline hover:text-[#00c9b7] transition">{CONTRACT_ADDRESS}</a>
          </p>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="space-y-4">
              <button className="w-full bg-[#00fff2] text-black font-semibold py-2 rounded-xl hover:bg-[#00c9b7] transition cursor-pointer"
                onClick={() => open()}>🔗 {isConnected ? "Connected" : "Connect wallet"}</button>

              <div id="walletAddress" className="bg-[#0f0f1b] p-3 rounded-md text-[#00fff2] neon-border text-sm">
                {isConnected ? address : "Connect wallet to see your address"}
              </div>

              <input id="amountInput" type="number" placeholder="Enter 0.01 SEPOLIA ETH"
                className="w-full p-3 bg-[#0f0f1b] text-[#00fff2] rounded-md neon-border outline-none"
                onChange={onInputAmountChange} />

              <button
                className={
                  `w-full bg-[#00fff2] text-black font-semibold py-2 rounded-xl hover:bg-[#00c9b7] transition
                   ${isLoading ? "opacity-50 cursor-not-allowed " : "cursor-pointer"}`
                }
                onClick={() => handleParticipate()}
              >
                🎟️ {loadingTransaction ? "Loading..." : "Participate"}
              </button>
            </div>


            <div>
              <h2 className="text-xl font-semibold mb-3 text-[#00fff2] neon-text">📋 Participates </h2>
              <ul id="participantList" className="space-y-2 text-sm max-h-64 overflow-y-auto bg-[#0f0f1b] p-3 rounded-md neon-border">
                {participants.length > 0 ? (
                  participants.map((participant, index) => (
                    <li key={index} className="text-[#00fff2] neon-text">
                      {shortenAddress(participant)}
                    </li>
                  ))
                ) : (
                  <li className="italic text-gray-400">No participates yet</li>
                )}
              </ul>
            </div>
          </div>

          <div className="mt-8 text-center">
            <h2 className="text-xl font-semibold text-[#00fff2] neon-text mb-2">💰 Total Prize</h2>
            <div className="bg-[#0f0f1b] p-3 rounded-md text-[#00fff2] neon-border text-sm">
              {winner.balance ? (
                <p>{parseFloat(formatEther(winner.balance))} SEPOLIA ETH</p>
              ) : (
                <p className="italic text-gray-400">Waiting for prize...</p>
              )}
            </div>
          </div>


          <div className="mt-8 text-center">
            <h2 className="text-xl font-semibold text-[#00fff2] neon-text mb-2">🏆 Winner</h2>
            <div id="winnerResult" className="bg-[#0f0f1b] p-3 rounded-md text-[#00fff2] neon-border text-sm">
              {winner.address ? (
                <>
                  <p className="mb-2">Address: {(winner.address)}</p>
                  <p>Win: {parseFloat(formatEther(winner.balance))} SEPOLIA ETH</p>
                </>
              ) : (
                <p className="italic text-gray-400">No winner yet</p>
              )}
            </div>
          </div>
          {winner.address && winner.address.toLowerCase() === address?.toLowerCase() && (
            <div className="mt-4 text-center">
              <button
                className={
                  `bg-[#00fff2] text-black font-semibold py-2 px-2 rounded-xl hover:bg-[#00c9b7] transition
                   ${isLoading ? "opacity-50 cursor-not-allowed " : "cursor-pointer"}`
                }
                onClick={() => handleClaimPrize()}
              >
                🎁{loadingTransaction ? "Claiming..." : "Claim prize"}
              </button>
            </div>
          )}

        </div>
      </div>
    </>
  )
}

export default App
