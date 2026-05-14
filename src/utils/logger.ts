const LOG_LEVELS = ["debug", "info", "warn", "error"] as const;
type LogLevel = (typeof LOG_LEVELS)[number];

const currentLevel: LogLevel = (process.env.LOG_LEVEL as LogLevel) || "info";

function shouldLog(level: LogLevel): boolean {
  return LOG_LEVELS.indexOf(level) >= LOG_LEVELS.indexOf(currentLevel);
}

function formatMessage(level: LogLevel, message: string): string {
  const timestamp = new Date().toISOString();
  return `[${timestamp}] ${level.toUpperCase()} ${message}`;
}

export const logger = {
  debug: (msg: string) => shouldLog("debug") && console.log(formatMessage("debug", msg)),
  info: (msg: string) => shouldLog("info") && console.log(formatMessage("info", msg)),
  warn: (msg: string) => shouldLog("warn") && console.warn(formatMessage("warn", msg)),
  error: (msg: string) => shouldLog("error") && console.error(formatMessage("error", msg)),
};
