# Ordinary-player Combat Baseline Gate

Player Open Alpha E2E now applies the observer only to its mktemp isolated Runtime. Production is not patched.

The Human ordinary-player route obtains the Source-backed wooden sword, spars with the Source-backed child, and must produce non-empty actual-damage samples from Original receive_damage(). The samples are parsed into mean/P50/P95/min/max JSON. Missing or zero samples fail the test.

This is the natural level-1 baseline and validates the measurement path. It is not yet the Lv.50/100/150/200 balance matrix.

Next: create isolated ordinary-player profile fixtures without KING/Admin/Wizard runtime commands and repeat controlled fights at Lv.50/100/150/200.
