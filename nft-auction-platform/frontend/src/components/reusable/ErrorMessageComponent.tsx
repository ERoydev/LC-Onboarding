import React, { useState, useEffect } from "react";
import { logger } from "../../utils/logger";
interface ErrorProps {
  message: string;
  duration?: number; // Duration in milliseconds before the error disappears
}

const ErrorMessageComponent: React.FC<ErrorProps> = ({ message, duration = 5000 }) => {
  const [visible, setVisible] = useState<boolean>(false); // State to track visibility
  const [currentMessage, setCurrentMessage] = useState<string>(""); // To keep track of the current message

  logger.info("Error Message: ", message)

  // Whenever the message changes, reset visibility and message state
  useEffect(() => {
    // If message changes, show the error and reset it after the duration
    setVisible(true);
    setCurrentMessage(message); // Update the message to be shown

    const timer = setTimeout(() => {
      setVisible(false); // Hide after the specified duration
    }, duration);

    return () => clearTimeout(timer); // Cleanup the timer on unmount or when message changes
  }, [message, duration]); // Dependency on message to re-trigger effect on message change

  if (!visible) return null; // If not visible, return null to hide the component

  return (
    <div
      key={currentMessage} // Using currentMessage as key to ensure it's re-rendered every time message changes
      className="fixed bottom-4 right-4 bg-red-500 text-white px-4 py-2 rounded-lg shadow-lg animate-slide-in"
    >
      <p>{currentMessage}</p>
    </div>
  );
};

export default ErrorMessageComponent;
