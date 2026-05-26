import express from "express";
import cors from "cors";
import cookieParser from "cookie-parser";
import helmet from "helmet";
import dotenv from "dotenv";
import authRoutes from "./routes/authRoutes.js";
import profileRoutes from "./routes/profileRoutes.js";
import activityRoutes from "./routes/activityRoutes.js";
import progressRoutes from "./routes/progressRoutes.js";
import rankingRoutes from "./routes/rankingRoutes.js";
import badgeRoutes from "./routes/badgeRoutes.js";
import milestoneRoutes from "./routes/milestoneRoutes.js";
import adminRoutes from "./routes/adminRoutes.js";
import { errorHandler, notFound } from "./middleware/errorHandler.js";

dotenv.config();

const allowedOrigins = new Set([
  "http://localhost:5173",
  "http://localhost:5174",
  "http://127.0.0.1:5173",
  "http://127.0.0.1:5174",
  "http://202.10.44.139:5173",
  "http://202.10.44.139:5174",
  "http://carbongo.site",
  "https://carbongo.site",
  process.env.FRONTEND_URL,
  process.env.DASHBOARD_URL,
].filter(Boolean));

function isAllowedOrigin(origin) {
  if (!origin) return true;
  if (allowedOrigins.has(origin)) return true;

  try {
    const url = new URL(origin);
    const isLocalDevHost = ["localhost", "127.0.0.1"].includes(url.hostname);
    const isViteDevPort = Number(url.port) >= 5173 && Number(url.port) <= 5199;
    return isLocalDevHost && isViteDevPort;
  } catch {
    return false;
  }
}

const app = express();

app.use(helmet());
app.use(cors({
  origin: function (origin, callback) {
    if (isAllowedOrigin(origin)) {
      return callback(null, true);
    }
    return callback(new Error("Not allowed by CORS"));
  },
  credentials: true,
}));

app.use(express.json());
app.use(cookieParser());

app.get("/api/health", (req, res) => res.json({ status: "ok" }));
app.use("/api/auth", authRoutes);
app.use("/api/profile", profileRoutes);
app.use("/api", activityRoutes);
app.use("/api/progress", progressRoutes);
app.use("/api/rankings", rankingRoutes);
app.use("/api/badges", badgeRoutes);
app.use("/api/milestones", milestoneRoutes);
app.use("/api/admin", adminRoutes);

app.use(notFound);
app.use(errorHandler);

export default app;
