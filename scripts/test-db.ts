import { prisma } from "../lib/db/client";

async function main() {
    console.log('Testing database connection...');

    try {
        // Try to query the database
        const result = await prisma.$queryRaw`SELECT 1`;
        console.log("Database connection successful!");
        console.log("Result: ", result);
    } catch (error) {
        console.error("Database connection failed: ", error);
    } finally {
        await prisma?.$disconnect();
    }
}

main()