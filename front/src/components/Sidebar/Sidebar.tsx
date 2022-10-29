import React, { FC } from 'react';
import { useNavigate, useLocation, useHref } from 'react-router-dom';

import { FaBeer, FaBookOpen, FaHatWizard, FaFlask } from 'react-icons/fa';
import { GiFairyWand, GiThorHammer } from 'react-icons/gi';

import './Sidebar.scss';

interface SpellBarIconProps extends React.HTMLAttributes<HTMLElement> {
  icon: React.ReactNode;
  tooltip: string;
  page: string;
}


const SpellBarIcon:FC<SpellBarIconProps> = ({icon, tooltip, page}) => {
  // const navigate = useNavigate();
  // const location = useLocation().pathname.substring(1);
  // const location = useLocation();

  const handleRedirect = (page: string) => {
    console.log(page);
    // navigate(`/${page}`)
  }
  // console.log("location: ", location);

  return (
    <div onClick={(event: React.MouseEvent<HTMLElement>) => handleRedirect(page)} className={`sidebar-icon`}>
    {/* <div onClick={(event: React.MouseEvent<HTMLElement>) => handleRedirect(page)} className={`sidebar-icon group ${location === page ? 'highlited' : ''}`}> */}
      {icon}
      {/* <span className="sidebar-tooltip group-hover:scale-100">
        {tooltip}
      </span> */}
    </div>
  );
}
  
const SpellBar:FC = () => {

  return (
    <div className="spellbar-container">
      <div className="spellbar-subcontainer">
        <SpellBarIcon icon={<FaHatWizard/>} tooltip={"profile"} page={"profile"} />
        <SpellBarIcon icon={<FaBookOpen/>} tooltip={"quest"} page={"quest"} />
        <SpellBarIcon icon={<FaBeer/>} tooltip={"tavern"} page={"tavern"} />
        <SpellBarIcon icon={<FaFlask/>} tooltip={"potion"} page={"potion"} />
        <SpellBarIcon icon={<GiFairyWand/>} tooltip={"home"} page={""} />
        <SpellBarIcon icon={<GiThorHammer/>} tooltip={"forge"} page={"forge"} />
      </div>
    </div>
  );
};
    
export default SpellBar;