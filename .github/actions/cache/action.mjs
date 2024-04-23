import { getInput, getMultilineInput } from "@actions/core";
import { restoreCache as restoreGithubCache, saveCache as saveGithubCache } from "@actions/cache";
import { cpSync, existsSync, mkdirSync, readdirSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const path = getInput("path", { required: true });
const key = getInput("key", { required: true });
const restoreKeys = getMultilineInput("restore-keys");
const cacheDir = getInput("cache-dir") || join(tmpdir(), ".github", "cache");

export async function restoreCache() {
  console.log("Restoring cache...");

  if (isGithubHosted()) {
    console.log("Using GitHub cache...");
    try {
      return await restoreGithubCache([path], key, restoreKeys);
    } catch (error) {
      console.error("Failed to restore cache:", error);
      return null;
    }
  }

  console.log("Using local cache...");
  if (!existsSync(cacheDir)) {
    console.log("Cache directory does not exist, creating it...", cacheDir);
    try {
      mkdirSync(cacheDir, { recursive: true });
    } catch (error) {
      console.error("Failed to create cache directory:", error);
      return null;
    }
  }

  const targetDir = join(cacheDir, key);
  if (existsSync(targetDir)) {
    console.log("Found cache directory, restoring...", targetDir, "(hit)");
    try {
      copyFiles(targetDir, path);
      return {
        cacheHit: true,
        cacheKey: key,
      };
    } catch (error) {
      console.error("Failed to restore cache:", error);
    }
  }

  for (const dirname of readdirSync(cacheDir)) {
    if (!dirname.startsWith(key)) {
      continue;
    }

    const targetDir = join(cacheDir, dirname);
    console.log("Found cache directory, restoring...", targetDir, "(miss)");
    try {
      copyFiles(targetDir, path);
      return {
        cacheHit: false,
        cacheKey: dirname,
      };
    } catch (error) {
      console.error("Failed to restore cache:", error);
    }
  }

  return null;
}

export async function saveCache() {
  console.log("Saving cache...");

  if (isGithubHosted()) {
    console.log("Using GitHub cache...");
    try {
      return await saveGithubCache([path], key);
    } catch (error) {
      console.error("Failed to save cache:", error);
      return false;
    }
  }

  console.log("Using local cache...");
  if (!existsSync(cacheDir)) {
    console.log("Cache directory does not exist, creating it...", cacheDir);
    try {
      mkdirSync(cacheDir, { recursive: true });
    } catch (error) {
      console.error("Failed to create cache directory:", error);
      return false;
    }
  }

  const targetDir = join(cacheDir, key);
  console.log("Copying files to cache...", targetDir);
  try {
    copyFiles(path, targetDir);
  } catch (error) {
    console.error("Failed to copy files to cache:", error);
    return false;
  }

  return true;
}

function copyFiles(src, dst) {
  cpSync(src, dst, {
    recursive: true,
    force: true,
    preserveTimestamps: true,
  });
}

function isGithubHosted() {
  return process.env.RUNNER_ENVIRONMENT === "github-hosted";
}
