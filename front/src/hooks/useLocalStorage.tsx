import { useState } from 'react';

const useLocalStorage = (key: string, initialValue?: string):[Function, Function] => {
  const [storedValue, setStoredValue] = useState(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.log(error);
      return initialValue;
    }
  });
  
  const setValue = (value: Function) => {
    try {
      const valueToStore = value;
      setStoredValue(valueToStore);
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.log(error);
    }
  };
  
  return [storedValue, setValue];
};

export default useLocalStorage;