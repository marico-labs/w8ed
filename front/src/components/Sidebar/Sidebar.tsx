import React, { FC, useEffect, useState } from 'react';
import { useNavigate, useLocation, useHref } from 'react-router-dom';

import { FaBeer, FaBookOpen, FaHatWizard, FaFlask } from 'react-icons/fa';
import {MdExplore} from "react-icons/md"
import { GiFairyWand, GiThorHammer } from 'react-icons/gi';
import { spaces } from '@pages/Space/spaces';
import './Sidebar.scss';
import { db } from "../../utils/firebase"
import { onValue, ref } from "firebase/database";

interface SpellBarIconProps extends React.HTMLAttributes<HTMLElement> {
  icon?: React.ReactNode;
  tooltip: string;
  page: string;
}


const SpellBarIcon:FC<SpellBarIconProps> = ({icon, tooltip, page}) => {
  const navigate = useNavigate();
  const location = useLocation().pathname.substring(1);
  // const location = useLocation();

  const handleRedirect = (page: string) => {
    // console.log(page);
    navigate(page)
  }
  return (
    <div onClick={(event: React.MouseEvent<HTMLElement>) => handleRedirect(page)} className={`sidebar-icon ${location === page.slice(1, page.length) ? 'highlited' : ''}`}>
    {/* <div onClick={(event: React.MouseEvent<HTMLElement>) => handleRedirect(page)} className={`sidebar-icon group ${location === page ? 'highlited' : ''}`}> */}
      <div id="marker"/>
      {icon}
      <span className="sidebar-tooltip">
      {tooltip}
      </span> 
    </div>
  );
}

const SpellBar:FC = () => {
  const [joined, setJoined] = useState<any>()
  const [spaces, setSpaces] = useState<any>()  

  useEffect(() => {
    
    const query = ref(db, `Users/me/joined`)
    const queryObject = ref(db, `Spaces/`)
    onValue(queryObject, (snapshot) => {
      const data = snapshot.val()
      setSpaces(data)
    })
    return(onValue(query, (snapshot) => {
      const data = snapshot.val()
      setJoined(data)
    }))
  }, [])

  return (
    <div id="sidebar-wrapper">
    <div className="sidebar-container">
        <SpellBarIcon icon={<MdExplore/>} tooltip={"Discover"} page={"/"} />
        {joined && spaces && Object.keys(joined).map((index :any) => {
          const space = spaces[joined[index]]
          return space ? 
          <SpellBarIcon icon={<img className= "logo" src={space.Image}/>} tooltip={space.Name} page={`/space/${joined[index]}`}/>
          : <></>
        })}

    </div>

    </div>
  );
};
    
export default SpellBar;