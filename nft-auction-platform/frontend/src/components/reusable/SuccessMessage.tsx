import React, { useState, useEffect } from "react";

interface SuccessMessageProps {
  message: string;
  duration?: number; // Duration in milliseconds before the message disappears
}

const SuccessMessage: React.FC<SuccessMessageProps> = ({ message, duration = 5000 }) => {
  const [visible, setVisible] = useState(true);

  useEffect(() => {
    const timer = setTimeout(() => {
      setVisible(false);
    }, duration);

    return () => clearTimeout(timer); // Cleanup the timer on unmount
  }, [duration]);

  if (!visible) return null;

  return (
    <div className="fixed bottom-4 right-4 bg-green-500 text-white px-4 py-2 rounded-lg shadow-lg animate-slide-in">
      <p>{message}</p>
    </div>
  );
};

export default SuccessMessage;