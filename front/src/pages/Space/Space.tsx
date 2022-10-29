import Topbar from "@components/Topbar/Topbar";
import Sidebar from "@components/Sidebar/Sidebar";
import { useEffect, useState } from "react";
import ProposalPreview from "../Proposal/ProposalPreview";
import QuizzPreview from "../Quizz/QuizzPreview";
import "./Space.scss";
import SpacePreview from "./SpacePreview";
import { useParams } from "react-router-dom";
import { db } from "../../utils/firebase"
import { onValue, ref } from "firebase/database";

export default function Space() {
    const { id } = useParams();
    const [showQuizz, setShowQuizz] = useState(true);
    const [showProposal, setShowProposal] = useState(true);
    const [space, setSpace] = useState<any>(null)

    useEffect(() => {
      console.log(id)
      const query = ref(db, `Spaces/${id}`)
      return(onValue(query, (snapshot) => {
        const data = snapshot.val()
        setSpace(data)
      }))
    }, [id])

  return (
    <div id="space-container">
      {space && <SpacePreview
        imageUrl={space.Image}
        name={space.Name}
        users={space.Users}
        id={id ? parseInt(id) : 0}
      />
      }
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
