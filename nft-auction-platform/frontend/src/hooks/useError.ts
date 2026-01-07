import { useState } from "react";

/*
Used for form errors

Usage:
  {errorMessage && (
    <p className="text-red-500 text-sm mt-2">{errorMessage}</p>
  )}
*/

export function useError() {
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const showError = (message: string) => {
    setErrorMessage(message);
  };

  const clearError = () => {
    setErrorMessage(null);
  };

  return { errorMessage, showError, clearError };
}