import { initializeApp } from "firebase/app";
import { getDatabase} from "firebase/database";
// require('dotenv').config();
console.log( process.env.REACT_APP_API_KEY,
  process.env.REACT_APP_AUTH_DOMAIN,
  process.env.REACT_APP_DB_URL,
  process.env.REACT_APP_PROJECT_ID,
  process.env.REACT_APP_STORAGE_BUCKET,
  process.env.REACT_APP_MESSAGING_SENDER_ID,process.env.REACT_APP_APP_ID,)
const firebaseConfig = {
  apiKey: process.env.REACT_APP_API_KEY,
  authDomain: process.env.REACT_APP_AUTH_DOMAIN,
  databaseURL: process.env.REACT_APP_DB_URL,
  projectId: process.env.REACT_APP_PROJECT_ID,
  storageBucket: process.env.REACT_APP_STORAGE_BUCKET,
  messagingSenderId: process.env.REACT_APP_MESSAGING_SENDER_ID,
  appId: process.env.REACT_APP_APP_ID,
};

const app = initializeApp(firebaseConfig);
export const db = getDatabase(app);
