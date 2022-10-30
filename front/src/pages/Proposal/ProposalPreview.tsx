import { useEffect, useState } from "react"
import { useNavigate } from "react-router-dom"
import { db } from "../../utils/firebase"
import { onValue, ref } from "firebase/database";
import "./ProposalPreview.scss"
interface ProposalPreviewProps{
    description: string,
    title: string,
    id: number,
    space_id: number
}
export default function PrposalPreview(props:ProposalPreviewProps){
    const navigate = useNavigate()
    const [proposal, setProposal] = useState();
    
    useEffect(() => {
        const query = ref(db, `Spaces/4/proposal/${props.id}`)
        return(onValue(query, (snapshot) => {
            const data = snapshot.val()
            console.log(data)
          setProposal(data)
        }))
    }, [props.id])
    return(
    <div id="proposal-preview-container" className="border-hovering" onClick={() => navigate(`/proposal/${props.id}`)}>
        <div id="proposal-sender">
            <div id="pfp"></div>
            <div>0x23..00</div>
        </div>
        <h1>This is a title</h1>
        <div id="description">Quisque quis bibendum risus. Cras hendrerit, lacus eget dictum blandit, leo tortor ullamcorper lacus, congue pharetra tellus magna sed odio. Cras sollicitudin mi quis placerat gravida. Sed et tempor ipsum, a gravida odio. Etiam porta finibus magna at gravida. Donec tellus ipsum, consequat eu nibh vitae, rutrum sagittis massa. Nulla facilisi. Curabitur quis turpis ligula. </div>
        <div>{`${Math.floor(Math.random() * 15)} days left`}</div>
    </div>)
}