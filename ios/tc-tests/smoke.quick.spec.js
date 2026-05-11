import { test, expect } from './fixtures/index.js';

/** Fast checks: env + project wiring (uses same merged `test` as full suite). */
test.describe('quick smoke', () => {
  test('TestChimp mobile project type is ios', async () => {
    expect(process.env.TESTCHIMP_PROJECT_TYPE?.toLowerCase()).toBe('ios');
  });

  test('bundle id matches Milliways iOS app', async ({ bundleId }) => {
    expect(bundleId).toBe('com.mobilenext.Milliways');
  });

  test('mobile project is active', async ({}, testInfo) => {
    expect(testInfo.project.name).toBe('mobile');
  });
});
