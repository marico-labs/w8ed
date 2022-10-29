import React, { useState } from "react";
import "./Home.scss";
import SpacePreview from "../Space/SpacePreview";
import Topbar from "@components/Topbar/Topbar";
import Sidebar from "@components/Sidebar/Sidebar";
import { spaces } from "../Space/spaces";

export default function Home() {
  const [search, setSearch] = useState("");

  const changeSearch = (e: React.ChangeEvent<HTMLInputElement>) => {
    setSearch(e.target.value)
  }

  console.log(search.toLowerCase())
  return (
    <div id="home-wrapper">
      <Topbar />
      <Sidebar/>

      <div id="search-wrapper">
        <div id="search-bar-container" className="border-hovering">
          <input type="text" placeholder="Search" onChange={changeSearch}/>
        </div>
        <div id="category-container" className="border-hovering">
          <div>Category</div>
        </div>
      </div>
      <div id="space-previews-tab">
        {spaces.map((object) => (
        object.name.toLowerCase().includes(search.toLowerCase()) ?
          <SpacePreview
            imageUrl={object.imageUrl}
            name={object.name}
            users={object.users}
          /> : <></>
        ))}
      </div>
    </div>
  );
}
