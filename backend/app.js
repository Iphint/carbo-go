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
import { errorHandler, notFound } from "./middleware/errorHandler.js";

const allowedOrigins = [
  "http://localhost:5173",
  "http://202.10.44.139:5173",
  "http://carbongo.site",
  "https://carbongo.site",
];

dotenv.config();

const app = express();

app.use(helmet());
app.use(cors({
  origin: function (origin, callback) {
    if (!origin || allowedOrigins.includes(origin)) {
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

app.use(notFound);
app.use(errorHandler);

export default app;
