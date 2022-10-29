import React, { useEffect, useState } from "react";
import "./Home.scss";
import SpacePreview from "../Space/SpacePreview";
import Topbar from "@components/Topbar/Topbar";
import Sidebar from "@components/Sidebar/Sidebar";
import { spaces } from "../Space/spaces";
import { db } from "../../utils/firebase";
import { onValue, ref } from "firebase/database";
import { BiDownArrow } from "react-icons/bi";

export default function Home() {
  const [search, setSearch] = useState("");
  const [projects, setProjects] = useState<any[] | null>(null);
  const changeSearch = (e: React.ChangeEvent<HTMLInputElement>) => {
    setSearch(e.target.value);
  };
  const [dropDown, setDropDown] = useState(false)

  useEffect(() => {
    const query = ref(db, "Spaces");
    return onValue(query, (snapshot) => {
      const data = snapshot.val();
      setProjects(data);
    });
  }, []);

  const dropDownChange = () => {
    console.log("test")
    setDropDown(!dropDown)
  }
  return (
    <div id="home-wrapper">
      <div id="search-wrapper">
        <div id="search-bar-container" className="border-hovering">
          <input type="text" placeholder="Search" onChange={changeSearch} />
        </div>
        <div id="category-container" className={`border-hovering ${dropDown? "dropdown" : ""}`}>
          <div id="category-header"  onClick={dropDownChange}>
            <div>Category</div>
            <BiDownArrow />
          </div>
          <div id="categories">

          </div>
        </div>
      </div>
      <div id="space-previews-tab">
        {projects &&
          projects.map((object: any, key: number) => {
            return object.Name.toLowerCase().includes(search.toLowerCase()) ? (
              <SpacePreview
                imageUrl={object.Image}
                name={object.Name}
                users={object.Users}
                id={key}
              />
            ) : (
              <></>
            );
          })}
        {/* {spaces.map((object) => (
        object.name.toLowerCase().includes(search.toLowerCase()) ?
          <SpacePreview
            imageUrl={object.imageUrl}
            name={object.name}
            users={object.users}
          /> : <></>
        ))} */}
      </div>
    </div>
  );
}
