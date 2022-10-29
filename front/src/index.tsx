import React from "react";
import ReactDOM from "react-dom/client";
import {
  createBrowserRouter,
  RouterProvider,
  useRouteError,
  Outlet
} from "react-router-dom";
import { WagmiConfig, createClient } from "wagmi";
import { getDefaultProvider } from "ethers";
import Home from "@pages/Home/Home";
import Profile from "./pages/Profile/Profile";
import NotFound404 from "@pages/NotFound404/NotFound404";
import Space from "@pages/Space/Space";
import Quizz from "@pages/Quizz/Quizz";
import Proposal from "@pages/Proposal/Proposal";
import "./index.scss";
import SideBar from "@components/Sidebar/Sidebar";
import TopBar from "@components/Topbar/Topbar";
import { spaces } from "@pages/Space/spaces";
import { error } from "console";

function ErrorBoundary() {
  let error = useRouteError();
  console.error(error);
  // Uncaught ReferenceError: path is not defined
  return <NotFound404 />;
}

const Layout = () => (
  <>
    <TopBar />
    <SideBar />
    <Outlet/>
  </>
);
const router = createBrowserRouter([
  {
    element: <Layout />,
    children: [
      {
        path: "/",
        element: <Home />,
      },
      {
        path: "/profile",
        element: <Profile />,
      },
      {
        path: "/404",
        element: <NotFound404 />,
      },
      {
        path: "/space/:id",
        loader: ({ params }) => {},
        errorElement: <ErrorBoundary />,
        element: <Space />,
      },
      {
        path: "/quizz/:id",
        loader: ({ params }) => {},
        errorElement: <ErrorBoundary />,
        element: <Quizz />,
      },
      {
        path: "/proposal/:id",
        loader: ({ params }) => {},
        errorElement: <ErrorBoundary />,
        element: <Proposal />,
      },
    ]
  }
]);

const client = createClient({
  autoConnect: true,
  provider: getDefaultProvider(),
});

ReactDOM.createRoot(document.getElementById("root") as HTMLElement).render(
  <WagmiConfig client={client}>
    <RouterProvider router={router} />
  </WagmiConfig>
);
