import { useEffect, useState } from "react";
import "./Proposal.scss";
import { AiOutlineCheck } from "react-icons/ai";
import { useAccount, useSignMessage } from "wagmi";
import { useNavigate, useParams } from "react-router-dom";
import { ethers } from "ethers";
const closed = false;
const description =
  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus mi ipsum, facilisis a dapibus ut, interdum quis magna. Nunc vel purus ligula. Nam a dignissim nibh, aaaaaaaaaaaaaaaaVivamus vulputate ornare arcu ut facilisis. Morbi nec mi pretium, lacinia metus vel, euismod sapien. Aliquam erat volutpat .";

export default function Proposal() {
  const navigate = useNavigate();
  const { id, prop_id } = useParams();
  const [chosen, setChosen] = useState<number>(-1);
  const { address, isConnected } = useAccount();
  const [message, setMessage] = useState<string>();
  const [voted, setVoted] = useState(false)
  const { data, isError, isLoading, isSuccess, signMessage } = useSignMessage({
    message: message,
    onSuccess(data) {
        setVoted(true)
    //   navigate(`/space/${prop_id}`);
    },
  });

  useEffect(() => {
    console.log(id, prop_id);
  }, []);

  const signVoteMessage = () => {
    if (chosen != -1) {
      signMessage();
    }
  };

  const vote = (choice: number) => {
    setChosen(choice);
    const pack = ethers.utils.solidityPack(
      ["address", "uint256"],
      [address, choice]
    );
    const mess = ethers.utils.solidityKeccak256(["bytes"], [pack]);
    setMessage(mess);
  };
  return (
    <div id="proposal-container">
      <h1>This is a Title</h1>
      <div id="proposal-sender">
        <div id="pfp"></div>
        <div>0x23..00</div>
      </div>
      <div id="state-container">
        {closed ? (
          <div id="closed" className="state">
            Closed
          </div>
        ) : (
          <div id="opened" className="state">
            Opened
          </div>
        )}
        <div>1000 votes</div>
      </div>
      <div id="description">{description}</div>
      <div id="discussion"></div>

      {!closed && !voted && (
        <div id="vote-container" className="border-hovering">
          <p>Give your opinion</p>
          <hr />
          <div
            className={`border-hovering proposal-choice ${
              chosen === 0 ? "chosen" : ""
            }`}
            onClick={() => vote(0)}
          >
            <AiOutlineCheck />
            <div>Yes</div>
          </div>
          <div
            className={`border-hovering proposal-choice ${
              chosen === 1 ? "chosen" : ""
            }`}
            onClick={() => vote(1)}
          >
            <AiOutlineCheck />

            <div>No</div>
          </div>
          <div
            className={`border-hovering proposal-choice ${
              chosen === 2 ? "chosen" : ""
            }`}
            onClick={() => vote(2)}
          >
            <AiOutlineCheck />
            <div>I dont know</div>
          </div>
          <div
            id="vote-button"
            className={chosen !== -1 ? "colored" : "uncolored"}
            onClick={signVoteMessage}
          >
            VOTE
          </div>
        </div>
      )}
      {voted &&         <div id="vote-container" className="border-hovering">
        <p>You voted successfully</p>
            </div>
    }
        </div>
  );
}
