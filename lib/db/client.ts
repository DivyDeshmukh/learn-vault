import { PrismaClient } from "../generated/prisma/client";
import * as dotenv from "dotenv";
dotenv.config({ path: ".env.local" });

declare global {
    // allows us to store the instance globally to prevent
    // multiple instances during hot reloads in development
    var prisma: PrismaClient | undefined;
}

// use a global variable when not in production
// to preserve a single instance across
// hot reloads (in dev)
export const prisma = 
    global.prisma || 
    new PrismaClient({
        // we can also configure urls here but as we have added it in schema.prisma so not needed
        log: ["query", "warn", "error"]
    });

// assign to global object in dev for hot reloads
if (process.env.NODE_ENV !== "production") {
    global.prisma = prisma;
}    

