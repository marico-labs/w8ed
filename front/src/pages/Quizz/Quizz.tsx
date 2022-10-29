import React, { useEffect, useRef, useState } from "react";
import { questions } from "./questions";
import "./Quizz.scss";
import { useSignMessage } from "wagmi";
import { useNavigate } from "react-router-dom";

const setProp = (ref: any, prop: string, value: string) =>
  ref?.current?.style.setProperty(prop, value);

let time = 20000;
let countDown = 3;
var interval: any;

export default function Quizz() {
  const navigate = useNavigate();
  const [state, setState] = useState<number>(-1);
  const [text, setText] = useState<string>("Click anywhere if you are ready");
  const [choices, setChoices] = useState<string[] | null>(null);
  const [responses, setResponses] = useState<string>("");
  const containerRef = useRef<HTMLDivElement | null>(null);
  const [time, setTime] = useState(10000);
  const [questionIndex, setQuestionIndex] = useState(0);

  const { data, isError, isLoading, isSuccess, signMessage } = useSignMessage({
    message: responses,
    onSuccess(data) {
        navigate("/")
      },
  });

  useEffect(() => {
    // setProp(responseContainerRef, '--nbResp', 1/2)
  }, []);

  const finish = () => {
    setChoices([]);
    setText("Sign your responses to proceed.");
    setTime(0);
    setState(1);
    console.log("finished", responses);
  };

  const chronometerFn = () => {
    interval = setInterval(() => {
      if (time > 0) setTime((old) => old - 10);
      else {
        newQuestion();
      }
    }, 10);
  };

  const newQuestion = () => {
    if (questionIndex === questions.length) finish();
    else {
      clearInterval(interval);
      setTime(10000);
      setText(questions[questionIndex].question);
      setChoices(questions[questionIndex].choices);
      setProp(
        containerRef,
        "--nbResp",
        `calc(100vw * ${1 / questions[questionIndex].choices.length})`
      );
      chronometerFn();
      setQuestionIndex(questionIndex + 1);
    }
  };

  const countDownFn = () => {
    setText(countDown.toString());
    countDown--;
    if (countDown >= 0) setTimeout(countDownFn, 1000);
    else {
      newQuestion();
    }
  };

  const onContainerClick = () => {
    if (state == -1 && text === "Click anywhere if you are ready") {
      countDownFn();
    }
  };

  const chooseResponse = (index: number) => {
    const chosenResponse = questions[questionIndex - 1].choices[index];
    console.log(chosenResponse);
    let resp = responses;
    resp += " " + chosenResponse;
    setResponses(resp);
    console.log(resp);
    newQuestion();
  };

//   const signMessageAndQuit = async () => {
//     await signMessage();
//     console.log(isSuccess)
//     if (isSuccess) {
//         navigate("/")
//     }
//   };

  return (
    <div id="quizz-container" onClick={onContainerClick} ref={containerRef}>
      <div id="chronometer">
        <div style={{ width: `${(time * 100) / 10000}%` }} />
      </div>
      <h1 id="main-text">{text}</h1>
      {choices && (
        <div id="choices-container">
          {choices.map((e, index) => {
            return (
              <div key={index} onClick={() => chooseResponse(index)}>
                <h2>{e}</h2>
              </div>
            );
          })}
        </div>
      )}
      {state == 1 && <h2 onClick={() => signMessage()}>SIGN</h2>}
    </div>
  );
}
