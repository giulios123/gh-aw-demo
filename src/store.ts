import { v4 as uuidv4 } from "uuid";

export interface User {
  id: string;
  email: string;
  name: string;
  passwordHash: string;
  createdAt: string;
}

export interface Item {
  id: string;
  title: string;
  description: string;
  ownerId: string;
  createdAt: string;
  updatedAt: string;
}

// In-memory store — no database needed for the demo
const users: Map<string, User> = new Map();
const items: Map<string, Item> = new Map();

// Seed some data
const seedUser: User = {
  id: uuidv4(),
  email: "admin@example.com",
  name: "Admin User",
  passwordHash: "hashed_password_placeholder",
  createdAt: new Date().toISOString(),
};
users.set(seedUser.id, seedUser);

export const db = {
  users: {
    findByEmail: (email: string): User | undefined =>
      Array.from(users.values()).find((u) => u.email === email),

    findById: (id: string): User | undefined => users.get(id),

    create: (email: string, name: string, passwordHash: string): User => {
      const user: User = {
        id: uuidv4(),
        email,
        name,
        passwordHash,
        createdAt: new Date().toISOString(),
      };
      users.set(user.id, user);
      return user;
    },
  },

  items: {
    findAll: (): Item[] => Array.from(items.values()),

    findById: (id: string): Item | undefined => items.get(id),

    findByOwner: (ownerId: string): Item[] =>
      Array.from(items.values()).filter((i) => i.ownerId === ownerId),

    create: (title: string, description: string, ownerId: string): Item => {
      const item: Item = {
        id: uuidv4(),
        title,
        description,
        ownerId,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      };
      items.set(item.id, item);
      return item;
    },

    update: (id: string, data: Partial<Pick<Item, "title" | "description">>): Item | undefined => {
      const item = items.get(id);
      if (!item) return undefined;
      const updated = { ...item, ...data, updatedAt: new Date().toISOString() };
      items.set(id, updated);
      return updated;
    },

    delete: (id: string): boolean => items.delete(id),
  },
};
