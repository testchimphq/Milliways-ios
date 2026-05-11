/** Android Compose: prefer text where no explicit accessibility label exists. */
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
 * Reach the sign-in screen without `terminateApp` (normal for mobile E2E): dismiss delivery, pop navigation, or sign out from welcome.
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
    if (await isVisible(screen, expect, screen.getByLabel('New Order'), 600)) {
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
  await expect(screen.getByLabel('New Order')).toBeVisible({ timeout: 25_000 });
}

export async function addItemToCart(screen, expect, itemName, extraPlusTaps = 0) {
  await screen.getByText(itemName).scrollIntoViewIfNeeded();
  await screen.getByText(itemName).tap();
  for (let i = 0; i < extraPlusTaps; i++) {
    await screen.getByLabel('+').tap();
  }
  await screen.getByLabel('Add to Order').tap();
  await expect(screen.getByLabel('Close')).not.toBeVisible({ timeout: 20_000 });
}

export async function openCart(screen) {
  await screen.getByLabel('Shopping Cart').tap();
}

export function parsePrice(text) {
  return parseFloat(String(text).replace('₭', ''));
}

export async function openAccount(screen) {
  await screen.getByLabel('Account').tap();
}
