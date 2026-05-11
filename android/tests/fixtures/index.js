/**
 * SmartTests entry: merge domain fixtures, then wrap with TestChimp (`installTestChimp`).
 * TrueCoverage / ExploreChimp / `markScreenState` — use `@testchimp/playwright` + `TESTCHIMP_PROJECT_TYPE=android`.
 *
 *   import { test as auth } from './auth.fixture.js';
 *   export const test = installTestChimp(auth);
 */
import { installTestChimp } from '@testchimp/playwright/runtime';
import { test as auth } from './auth.fixture.js';

export const test = installTestChimp(auth);
export { expect } from '@mobilewright/test';
