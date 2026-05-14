import express from "express";
import cors from "cors";
import { authRouter } from "./routes/auth";
import { itemsRouter } from "./routes/items";
import { usersRouter } from "./routes/users";
import { errorHandler } from "./middleware/errorHandler";
import { logger } from "./utils/logger";

const app = express();
const PORT = process.env.PORT || 8080;

app.use(cors());
app.use(express.json());

// Routes
app.use("/api/auth", authRouter);
app.use("/api/users", usersRouter);
app.use("/api/items", itemsRouter);

// Health check
app.get("/api/health", (_req, res) => {
  res.json({ status: "ok", version: "2.3.1", uptime: process.uptime() });
});

// Error handling
app.use(errorHandler);

app.listen(PORT, () => {
  logger.info(`Server running on port ${PORT}`);
});

export default app;
