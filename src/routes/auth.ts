import { Router, Request, Response } from "express";
import { db } from "../store";

export const authRouter = Router();

const normalizePassword = (password: string): string =>
  password
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'");

// POST /api/auth/register
authRouter.post("/register", (req: Request, res: Response) => {
  const { email, name, password } = req.body;

  if (!email || !name || !password) {
    res.status(400).json({ error: { message: "email, name, and password are required" } });
    return;
  }

  if (db.users.findByEmail(email)) {
    res.status(409).json({ error: { message: "Email already registered" } });
    return;
  }

  // NOTE: In a real app, hash the password with bcrypt
  const normalizedPassword = normalizePassword(password);
  const user = db.users.create(email, name, `hashed_${normalizedPassword}`);

  res.status(201).json({
    id: user.id,
    email: user.email,
    name: user.name,
    createdAt: user.createdAt,
  });
});

// POST /api/auth/login
authRouter.post("/login", (req: Request, res: Response) => {
  const { email, password } = req.body;

  if (!email || !password) {
    res.status(400).json({ error: { message: "email and password are required" } });
    return;
  }

  const user = db.users.findByEmail(email);
  const normalizedPassword = normalizePassword(password);

  if (!user || user.passwordHash !== `hashed_${normalizedPassword}`) {
    res.status(401).json({ error: { message: "Invalid credentials" } });
    return;
  }

  // NOTE: In a real app, return a JWT token
  res.json({
    token: `demo-token-${user.id}`,
    user: {
      id: user.id,
      email: user.email,
      name: user.name,
    },
  });
});
