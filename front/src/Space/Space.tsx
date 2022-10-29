import { useState } from "react";
import ProposalPreview from "../Proposal/ProposalPreview";
import QuizzPreview from "../Quizz/QuizzPreview";
import "./Space.scss";
import SpacePreview from "./SpacePreview";

export default function Space() {
    const [showQuizz, setShowQuizz] = useState(true);
    const [showProposal, setShowProposal] = useState(true);
  return (
    <div id="space-container">
      <SpacePreview
        imageUrl="https://i.pinimg.com/originals/4b/52/17/4b5217cc5d784890f44aeb01a5ad7db6.png"
        name="pepe"
        users={70000}
      />
      <div id="actions-container">
        <hr/>
        <h1>Live</h1>
        <div id="sp1" className="border-hovering space-actions" onClick={() => setShowQuizz(!showQuizz)}>Quizz</div>
        {showQuizz && <QuizzPreview />}
        <div id="sp2" className="border-hovering space-actions" onClick={() => setShowProposal(!showProposal)}>Proposals</div>
        {showProposal && <ProposalPreview description="Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus mi ipsum, facilisis a dapibus ut, interdum quis magna. Nunc vel purus ligula. Nam a dignissim nibh, aaaaaaaaaaaaaaaaVivamus vulputate ornare arcu ut facilisis. Morbi nec mi pretium, lacinia metus vel, euismod sapien. Aliquam erat volutpat ." />}
        <hr/>
        <h1>Historic</h1>
      </div>
    </div>
  );
}
