import { Router, Request, Response } from "express";
import { db } from "../store";

export const usersRouter = Router();

// GET /api/users/me
// In a real app this would use JWT middleware
usersRouter.get("/me", (req: Request, res: Response) => {
  const authHeader = req.headers.authorization;

  if (!authHeader?.startsWith("Bearer demo-token-")) {
    res.status(401).json({ error: { message: "Unauthorized" } });
    return;
  }

  const userId = authHeader.replace("Bearer demo-token-", "");
  const user = db.users.findById(userId);

  if (!user) {
    res.status(404).json({ error: { message: "User not found" } });
    return;
  }

  res.json({
    id: user.id,
    email: user.email,
    name: user.name,
    createdAt: user.createdAt,
  });
});
