import React from 'react';
import ReactDOM from 'react-dom/client';
import { createBrowserRouter, RouterProvider } from "react-router-dom";

import Home from './pages/Home/Home';
import Profile from './pages/Profile/Profile';
import NotFound404 from '@pages/NotFound404/NotFound404';

import './index.css'

const router = createBrowserRouter([
  {
    path: "/",
    element: <Home />,
    // loader: appLoader,
    // children: [
      // {
        // path: "child",
        // element: <Child />,
        // loader: childLoader,
      // },
    // ],
  },
  {
    path: "/profile",
    element: <Profile />,
    // loader: appLoader,
    // children: [
      // {
        // path: "child",
        // element: <Child />,
        // loader: childLoader,
      // },
    // ],
  },
  {
    path: "/404",
    element: <NotFound404 />,
    // loader: appLoader,
    // children: [
      // {
        // path: "child",
        // element: <Child />,
        // loader: childLoader,
      // },
    // ],
  },
]);


ReactDOM.createRoot(document.getElementById("root") as HTMLElement).render(
  <RouterProvider router={router} />
);