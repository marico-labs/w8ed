import "./ProposalPreview.scss"
interface ProposalPreviewProps{
    description: string
}
export default function PrposalPreview(props:ProposalPreviewProps){
    return(
    <div id="proposal-preview-container" className="border-hovering">
        <div id="proposal-sender">
            <div id="pfp"></div>
            <div>0x23..00</div>
        </div>
        <h1>This is a title</h1>
        <div id="description">{props.description}</div>
        <div>7 days left</div>
    </div>)
}