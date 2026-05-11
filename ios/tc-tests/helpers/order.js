/** Shared Mobilewright helpers for Milliways ordering flows. */
const SIGN_IN_TAGLINE = /Sign in to order from the restaurant at the end of the universe/;

async function isVisible(screen, expect, locator, timeoutMs) {
  try {
    await expect(locator).toBeVisible({ timeout: timeoutMs });
    return true;
  } catch {
    return false;
  }
}

/**
 * Reach the sign-in screen without `terminateApp`: dismiss delivery, pop navigation, or sign out from welcome.
 */
export async function ensureOnSignInScreen(screen, expect) {
  for (let step = 0; step < 16; step++) {
    if (await isVisible(screen, expect, screen.getByText(SIGN_IN_TAGLINE), 900)) return;

    if (await isVisible(screen, expect, screen.getByLabel('Close').first(), 450)) {
      await screen.getByLabel('Close').first().tap();
      continue;
    }
    if (await isVisible(screen, expect, screen.getByLabel('Back').first(), 450)) {
      await screen.getByLabel('Back').first().tap();
      continue;
    }
    const newOrder = screen.getByText('New Order');
    if (await isVisible(screen, expect, newOrder, 600)) {
      await openAccount(screen);
      const signOut = screen.getByText('Sign Out');
      if (await isVisible(screen, expect, signOut, 5_000)) await signOut.tap();
      continue;
    }
    if (await isVisible(screen, expect, screen.getByText('Create Account'), 450)) {
      await screen.getByLabel('Back').first().tap();
      continue;
    }
  }
  await expect(screen.getByText(SIGN_IN_TAGLINE)).toBeVisible({ timeout: 30_000 });
}

export async function navigateToMenu(screen, expect) {
  await screen.getByLabel('New Order').tap();
  await expect(screen.getByText('MAIN DISHES')).toBeVisible();
}

export async function signInForDemo(screen, expect, user) {
  await ensureOnSignInScreen(screen, expect);
  await expect(screen.getByText(SIGN_IN_TAGLINE)).toBeVisible({ timeout: 30_000 });
  await screen.getByLabel('Email').fill(user.email);
  await screen.getByLabel('Password').fill(user.password);
  await screen.getByText('Sign In').tap();
  await screen.getByText('Not Now').tap({ timeout: 3000 }).catch(() => {});
  await expect(screen.getByLabel('New Order')).toBeVisible({ timeout: 25_000 });
}

/** @param {number} extraPlusTaps taps on + after opening detail (0 = qty 1) */
export async function addItemToCart(screen, expect, itemName, extraPlusTaps = 0) {
  await screen.getByText(itemName).scrollIntoViewIfNeeded();
  await screen.getByText(itemName).tap();
  for (let i = 0; i < extraPlusTaps; i++) {
    await screen.getByLabel('+').tap();
  }
  await screen.getByLabel('Add to Order').tap();
}

export async function openCart(screen) {
  await screen.getByLabel('Shopping Cart').tap();
}

export function parsePrice(text) {
  return parseFloat(String(text).replace('₭', ''));
}

export async function openAccount(screen) {
  await screen.getByLabel('person.circle').tap();
}
