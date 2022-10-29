import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAccount, useConnect, useDisconnect } from "wagmi";
import { InjectedConnector } from "wagmi/connectors/injected";
import { db } from "../../utils/firebase"
import { onValue, ref, set, push, remove, update} from "firebase/database";
import "./SpacePreview.scss"

interface SpacePreviewProps{
    imageUrl: string,
    name: string,
    users: number,
    id: number
}
interface JoinButtonProps{
    id:number;
}

function JoinedButton(props: JoinButtonProps){
    const [joinedText, setJoinedText] =useState("Joined")

    const joinedToQuit = () => {
        setJoinedText("Quit")
    }
    const quitToJoin = () => {
        setJoinedText("Joined")
    }

    const leaveSpace = (e: React.MouseEvent<HTMLElement>) => {
        e.stopPropagation();
        let query = ref(db, `Users/me/joined/`)
        let data:any;
        onValue(query, (snapshot) => {
            data = snapshot.val()
            console.log(data)
            let values = Object.entries(data).filter((obj)=> {
                return obj[1]== props.id ? 0 : 1
            })
            data = Object.fromEntries(values)
            update(query, data)
        })

        
    }
    return(
    <div className="border-hovering" onMouseEnter={joinedToQuit} onMouseLeave={quitToJoin} onClick={e => leaveSpace(e)}>{joinedText}</div>
    )
}



function JoinButton(props:JoinButtonProps){
    const [buttonText, setButtonText] = useState("Join");
    const { address, isConnected } = useAccount();
    const { connect } = useConnect({
        connector: new InjectedConnector(),
      });

    const handleJoin = (e:React.MouseEvent<HTMLElement>) => {
        e.stopPropagation();
        
        console.log("test")
        if(!isConnected)
        connect()
        if(isConnected){
            const query = ref(db, `Users/me/joined`)
            push(query, props.id)
        }
    }
    
    return(
        <div id="join-button" className="border-hovering" onClick={e => handleJoin(e)}>Join</div>
    )
}

export default function SpacePreview(props:SpacePreviewProps){
    const [joined, setJoined] = useState<boolean>()
    const navigate = useNavigate();
    
    useEffect(() => {
        const query = ref(db, `Users/me/joined`)
        return(onValue(query, (snapshot) => {
            const data = snapshot.val()
            setJoined(Object.values(data).includes(props.id) ? true: false)
          }))
    }, [])


    return(
    <div id="space-preview-container" className="border-hovering" onClick={() => navigate(`/space/${props.id}`)}>
        {/*open space on click*/}
        {props.imageUrl != "" ? <img id="space-image" src={props.imageUrl}/>: <div id="space-image"/>}
        <h2>{props.name}</h2>
        <p>{Math.floor(props.users/100)}k members</p>
        {joined ? <JoinedButton id={props.id}/>: <JoinButton id={props.id}/>}
    </div>)
}