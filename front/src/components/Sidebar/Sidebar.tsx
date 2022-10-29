import React, { FC } from 'react';
import { useNavigate, useLocation, useHref } from 'react-router-dom';

import { FaBeer, FaBookOpen, FaHatWizard, FaFlask } from 'react-icons/fa';
import { GiFairyWand, GiThorHammer } from 'react-icons/gi';
import { spaces } from '@pages/Space/spaces';
import './Sidebar.scss';

interface SpellBarIconProps extends React.HTMLAttributes<HTMLElement> {
  icon?: React.ReactNode;
  tooltip: string;
  page: string;
}


const SpellBarIcon:FC<SpellBarIconProps> = ({icon, tooltip, page}) => {
  const navigate = useNavigate();
  // const location = useLocation().pathname.substring(1);
  // const location = useLocation();

  const handleRedirect = (page: string) => {
    // console.log(page);
    navigate(page)
  }
  // console.log("location: ", location);

  return (
    <div onClick={(event: React.MouseEvent<HTMLElement>) => handleRedirect(page)} className={`sidebar-icon`}>
    {/* <div onClick={(event: React.MouseEvent<HTMLElement>) => handleRedirect(page)} className={`sidebar-icon group ${location === page ? 'highlited' : ''}`}> */}
      {icon}
      {/* <span className="sidebar-tooltip group-hover:scale-100"> */}
      {/* {tooltip} */}
      {/* // </span>  */}
    </div>
  );
}
  
const SpellBar:FC = () => {

  return (
    <div className="sidebar-container">
        <SpellBarIcon icon={<FaHatWizard/>} tooltip={"profile"} page={"/"} />
        <SpellBarIcon icon={<img src={spaces[0].imageUrl}/>} tooltip={"quest"} page={"/space/1"} />
        <SpellBarIcon icon={<img src={spaces[0].imageUrl}/>} tooltip={"tavern"} page={"/space/1"} />
        <SpellBarIcon icon={<img src={spaces[0].imageUrl}/>} tooltip={"potion"} page={"/space/1"} />
        <SpellBarIcon icon={<img src={spaces[0].imageUrl}/>} tooltip={"home"} page={"/space/1"} />
        <SpellBarIcon icon={<img src={spaces[0].imageUrl}/>} tooltip={"forge"} page={"/space/1"} />
    </div>
  );
};
    
export default SpellBar;