import { useNavigate } from "react-router-dom"
import "./ProposalPreview.scss"
interface ProposalPreviewProps{
    description: string
}
export default function PrposalPreview(props:ProposalPreviewProps){
    const navigate = useNavigate()
    return(
    <div id="proposal-preview-container" className="border-hovering" onClick={() => navigate("/proposal/1")}>
        <div id="proposal-sender">
            <div id="pfp"></div>
            <div>0x23..00</div>
        </div>
        <h1>This is a title</h1>
        <div id="description">{props.description}</div>
        <div>7 days left</div>
    </div>)
}