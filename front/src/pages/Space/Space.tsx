import Topbar from "@components/Topbar/Topbar";
import Sidebar from "@components/Sidebar/Sidebar";
import { useEffect, useState } from "react";
import ProposalPreview from "../Proposal/ProposalPreview";
import QuizzPreview from "../Quizz/QuizzPreview";
import "./Space.scss";
import SpacePreview from "./SpacePreview";
import { useParams } from "react-router-dom";
import { db } from "../../utils/firebase";
import { onValue, ref } from "firebase/database";

export default function Space() {
  const { id } = useParams();
  const [showQuizz, setShowQuizz] = useState(true);
  const [showProposal, setShowProposal] = useState(true);
  const [space, setSpace] = useState<any>(null);

  useEffect(() => {
    console.log(id);
    const query = ref(db, `Spaces/${id}`);
    return onValue(query, (snapshot) => {
      const data = snapshot.val();
      console.log(data);
      setSpace(data);
    });
  }, [id]);

  return (
    <div id="space-container">
      {space && (
        <SpacePreview
          imageUrl={space.Image}
          name={space.Name}
          users={space.Users}
          id={id ? parseInt(id) : 0}
        />
      )}
      <div id="actions-container">
        <h1>Live</h1>
        <div
          id="sp1"
          className="border-hovering space-actions"
          onClick={() => setShowQuizz(!showQuizz)}
        >
          <div>Quizz</div>
          
        </div>
        {showQuizz && <QuizzPreview />}
        <div
          id="sp2"
          className="border-hovering space-actions"
          onClick={() => setShowProposal(!showProposal)}
        >
          Proposals
        </div>
        {showProposal &&
          space &&
          space.Proposals &&
          Object.keys(space.Proposals).map((index: any) => {
            const proposal = space.Proposals[index];
            if (proposal.state !== "closed")
              return (
                <ProposalPreview
                  description={proposal.description}
                  title={proposal.title}
                  id={index}
                  space_id={parseInt(id ? id : "")}
                />
              );
            else return <></>;
          })}
        <hr />
        <h1>Historic</h1>
      </div>
    </div>
  );
}
