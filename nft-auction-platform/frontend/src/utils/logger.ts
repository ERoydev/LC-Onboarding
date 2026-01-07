import log from "loglevel";

// Set the default log level (adjust based on environment)
log.setLevel(process.env.NODE_ENV === "production" ? "warn" : "debug");

// Export the logger instance
export const logger = log;

// Example usage
// logger.info("Logger initialized successfully");
// logger.error("This is an error message");
// logger.warn("This is a warning message");
// logger.debug("This is a debug message");