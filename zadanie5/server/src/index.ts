import { Elysia } from "elysia";

interface User {
  id: number;
  username: string;
  password: string;
  firstName: string;
  lastName: string;
}

interface OAuthToken {
  id: string;
  token: string;
  provider: string;
  createdAt: Date;
}

const users: User[] = [
  {
    id: 1,
    username: "admin",
    password: "admin123",
    firstName: "Admin",
    lastName: "User",
  },
];

const oauthTokens: OAuthToken[] = [];

const categoriesData = [
  { id: 1, name: "Kitchen", info: "Essentials for your kitchen" },
  { id: 2, name: "Sports & Outdoors", info: "Useful gear for activities" },
  { id: 3, name: "Home Office", info: "Essentials for your home office" },
  { id: 4, name: "Pet Supplies", info: "Supplies for your pets" },
];

const productsData = [
  // Kitchen (category_id: 1)
  { id: 1, name: "Cast Iron Skillet", price: 45.99, category_id: 1 },
  { id: 2, name: "Cutting Board", price: 24.99, category_id: 1 },
  { id: 3, name: "Coffee Maker", price: 32.5, category_id: 1 },
  { id: 4, name: "Knife Set", price: 89.0, category_id: 1 },
  // Sports & Outdoors (category_id: 2)
  { id: 5, name: "Yoga Mat", price: 28.99, category_id: 2 },
  { id: 6, name: "Hiking Backpack", price: 119.0, category_id: 2 },
  { id: 7, name: "Resistance Bands", price: 18.5, category_id: 2 },
  { id: 8, name: "Hammock", price: 54.99, category_id: 2 },
  // Home Office (category_id: 3)
  { id: 9, name: "PC Mouse", price: 49.99, category_id: 3 },
  { id: 10, name: "LED Desk Lamp", price: 36.0, category_id: 3 },
  { id: 11, name: "Headphones", price: 199.99, category_id: 3 },
  { id: 12, name: "Desk Converter", price: 249.0, category_id: 3 },
  // Pet Supplies (category_id: 4)
  { id: 13, name: "Pet Feeder", price: 67.99, category_id: 4 },
  { id: 14, name: "Dog Bed", price: 42.0, category_id: 4 },
  { id: 15, name: "Interactive Cat Toy", price: 15.99, category_id: 4 },
  { id: 16, name: "Grooming Kit", price: 29.5, category_id: 4 },
];

const ordersData = [
  {
    id: 1,
    final_price: 192.48,
    created_date: "2024-03-15",
    status: "PROCESSING",
    products: [1, 3, 5, 9],
  },
  {
    id: 2,
    final_price: 285.99,
    created_date: "2024-04-22",
    status: "SHIPPED",
    products: [6, 11, 14],
  },
  {
    id: 3,
    final_price: 136.48,
    created_date: "2024-05-10",
    status: "SEND",
    products: [2, 7, 13, 15],
  },
];

const app = new Elysia()
  // Authentication
  .post("/login", ({ body, set }) => {
    const { username, password } = body as {
      username: string;
      password: string;
    };

    const user = users.find(
      (u) => u.username === username && u.password === password
    );

    if (!user) {
      set.status = 401;
      return { error: "Invalid credentials" };
    }

    return {
      firstName: user.firstName,
      lastName: user.lastName,
      username: user.username,
    };
  })

  .post("/register", ({ body, set }) => {
    const { username, password, first_name, last_name } = body as {
      username: string;
      password: string;
      first_name: string;
      last_name: string;
    };

    // Check if user exists
    if (users.find((u) => u.username === username)) {
      set.status = 400;
      return { error: "User already exists" };
    }

    const newUser: User = {
      id: users.length + 1,
      username,
      password,
      firstName: first_name,
      lastName: last_name,
    };

    users.push(newUser);

    set.status = 201;
    return {
      firstName: newUser.firstName,
      lastName: newUser.lastName,
      username: newUser.username,
    };
  })

  // Store OAuth token
  .post("/token", ({ body, set }) => {
    const { id, token, provider } = body as {
      id: string;
      token: string;
      provider?: string;
    };

    // Remove existing token for this user/provider
    const existingIndex = oauthTokens.findIndex((t) => t.id === id);
    if (existingIndex !== -1) {
      oauthTokens.splice(existingIndex, 1);
    }

    const newToken: OAuthToken = {
      id,
      token,
      provider: provider || "unknown",
      createdAt: new Date(),
    };

    oauthTokens.push(newToken);

    console.log(`Stored OAuth token for user: ${id}, provider: ${provider}`);
    console.log(`Total stored tokens: ${oauthTokens.length}`);

    set.status = 201;
    return { success: true };
  })

  // Get stored tokens (for debugging)
  .get("/tokens", () => {
    return oauthTokens.map((t) => ({
      id: t.id,
      provider: t.provider,
      createdAt: t.createdAt,
      tokenPreview: t.token.substring(0, 10) + "...",
    }));
  })

  .get("/categories", () => categoriesData)

  .get("/category/:categoryId/products", ({ params: { categoryId } }) => {
    const id = parseInt(categoryId);
    return productsData.filter((product) => product.category_id === id);
  })

  .get("/orders", () => ordersData)

  .post("/product", ({ body, set }) => {
    try {
      const { name, price, category_id } = body as {
        name: string;
        price: number;
        category_id: number;
      };

      const newProduct = {
        id: productsData.length + 1,
        name,
        price,
        category_id,
      };

      productsData.push(newProduct);

      set.status = 201;
      return newProduct.id;
    } catch (e) {
      set.status = 500;
      return { error: String(e) };
    }
  })

  .listen(3000);

console.log(
  `🦊 Elysia is running at ${app.server?.hostname}:${app.server?.port}`
);
console.log(`📦 Shop API ready`);
console.log(`🔐 Auth API ready`);

