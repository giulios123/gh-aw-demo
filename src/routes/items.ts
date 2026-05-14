import { Router, Request, Response } from "express";
import { db } from "../store";

export const itemsRouter = Router();

// GET /api/items
itemsRouter.get("/", (_req: Request, res: Response) => {
  const allItems = db.items.findAll();
  res.json({ data: allItems, count: allItems.length });
});

// GET /api/items/:id
itemsRouter.get("/:id", (req: Request, res: Response) => {
  const id = req.params.id as string;
  const item = db.items.findById(id);

  if (!item) {
    res.status(404).json({ error: { message: "Item not found" } });
    return;
  }

  res.json({ data: item });
});

// POST /api/items
itemsRouter.post("/", (req: Request, res: Response) => {
  const { title, description, ownerId } = req.body;

  if (!title) {
    res.status(400).json({ error: { message: "title is required" } });
    return;
  }

  const item = db.items.create(
    title,
    description || "",
    ownerId || "anonymous"
  );

  res.status(201).json({ data: item });
});

// PUT /api/items/:id
itemsRouter.put("/:id", (req: Request, res: Response) => {
  const { title, description } = req.body;
  const updated = db.items.update(req.params.id as string, { title, description });

  if (!updated) {
    res.status(404).json({ error: { message: "Item not found" } });
    return;
  }

  res.json({ data: updated });
});

// DELETE /api/items/:id
itemsRouter.delete("/:id", (req: Request, res: Response) => {
  const deleted = db.items.delete(req.params.id as string);

  if (!deleted) {
    res.status(404).json({ error: { message: "Item not found" } });
    return;
  }

  res.status(204).send();
});
