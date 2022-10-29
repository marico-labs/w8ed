import { useNavigate } from "react-router-dom";
import { useAccount, useConnect, useDisconnect } from "wagmi";
import { InjectedConnector } from "wagmi/connectors/injected";
import "./SpacePreview.scss"

interface SpacePreviewProps{
    imageUrl: string,
    name: string,
    users: number
}

export default function SpacePreview(props:SpacePreviewProps){
    const navigate = useNavigate();
    const { address, isConnected } = useAccount();
    const { connect } = useConnect({
      connector: new InjectedConnector(),
    });
    
    const handleJoin = () => {
        if(!isConnected)
            connect()
    }
    return(
    <div id="space-preview-container" className="border-hovering" onClick={() => navigate("/space/1")}>
        {/*open space on click*/}
        {props.imageUrl != "" ? <img id="space-image" src={props.imageUrl}/>: <div id="space-image"/>}
        <h2>{props.name}</h2>
        <p>{props.users/100}k members</p>
        <div id="join-button" className="border-hovering" onClick={handleJoin}>Join</div>
    </div>)
}