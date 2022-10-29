import React from "react";
import logo from "./logo.svg";
import "./App.css";
import Home from "./Home/Home";
import TopBar from "./Bar/TopBar";
import { WagmiConfig, createClient } from "wagmi";
import { getDefaultProvider } from "ethers";
import Space from "./Space/Space";


const client = createClient({
  autoConnect: true,
  provider: getDefaultProvider(),
})

function App() {
  return (
    <div className="App">
      <WagmiConfig client={client}>
        <TopBar />
        {/* <Home /> */}
        <Space/>
      </WagmiConfig>
    </div>
  );
}

export default App;
