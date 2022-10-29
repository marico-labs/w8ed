import { useState } from "react";
import { useAccount, useConnect, useDisconnect } from "wagmi";
import { InjectedConnector } from "wagmi/connectors/injected";
import "./Topbar.scss";

export default function Topbar() {
  const { address, isConnected } = useAccount();
  const { connect } = useConnect({
    connector: new InjectedConnector(),
  });
  const { disconnect } = useDisconnect();

  const [connectedText, setConnectedText] = useState(`${address?.slice(0, 3)}...
  ${address?.slice(address.length - 4, address.length - 1)}`);

  const addressToDisconnect = () => {
    setConnectedText("Disconnect");
  };

  const disconnectToAddress = () => {
    setConnectedText(`${address?.slice(0, 3)}...
    ${address?.slice(address.length - 4, address.length - 1)}`);
  };
  return (
    <div id="top-bar-container">
      {!isConnected && (
        <div
          id="wallet-connect"
          className="border-hovering"
          onClick={() => connect()}
        >
          Connect Wallet
        </div>
      )}
      {isConnected && (
        <div id="connected-wrapper">
          <div
            id="wallet-connected"
            className="border-hovering"
            onMouseEnter={addressToDisconnect}
            onMouseLeave={disconnectToAddress}
            onClick={() => disconnect()}
          >
            {connectedText}
          </div>
        </div>
      )}
    </div>
  );
}
