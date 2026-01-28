-- CreateEnum
CREATE TYPE "Category" AS ENUM ('AI_TOOLS', 'DATA_SCIENCE', 'STOCK_MARKET', 'PERSONAL_FINANCE', 'BUSINESS_PRODUCTIVITY', 'WEB_DEVELOPMENT', 'OTHER');

-- CreateEnum
CREATE TYPE "ResourceType" AS ENUM ('VIDEO', 'ARTICLE', 'COURSE', 'BOOK', 'PODCAST', 'DOCUMENTATION');

-- CreateTable
CREATE TABLE "Resource" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "description" TEXT,
    "category" "Category" NOT NULL,
    "type" "ResourceType" NOT NULL,
    "tags" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "aiSummary" TEXT,
    "aiKeyPoints" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "aiSkillLevel" TEXT,
    "aiEstimatedTime" TEXT,
    "userId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Resource_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Resource_userId_idx" ON "Resource"("userId");

-- CreateIndex
CREATE INDEX "Resource_category_idx" ON "Resource"("category");

-- CreateIndex
CREATE INDEX "Resource_type_idx" ON "Resource"("type");

-- CreateIndex
CREATE INDEX "Resource_userId_category_idx" ON "Resource"("userId", "category");

-- CreateIndex
CREATE INDEX "Resource_userId_type_idx" ON "Resource"("userId", "type");
