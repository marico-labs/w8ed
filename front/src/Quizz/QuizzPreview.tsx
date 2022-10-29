import "./QuizzPreview.scss";

export default function QuizzPreview() {
  return (
    <div id="quizz-preview-container">
      <div id="proposal-sender">
        <div id="pfp"></div>
        <div>0x23..00</div>
      </div>
      <div id="quizz-description">
        <h1>This is a title</h1>
        <p>4m to do</p>
      </div>
    </div>
  );
}
