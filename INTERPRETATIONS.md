# Activation Curve: Time-to-First-Meaningful-Action
**Business question:** "How fast do new signups become real users, and how has that changed cohort-over-cohort?"

**Interpretations:**
-  7-day activation climbed from 10% to a peak of 22% (week of May 18), then fell for three straight weeks to 8.8% by June 8 , a real, recent decline worth investigating (channel mix, onboarding changes, etc.)
-   Median time-to-activate is dropping even as the activation rate falls, suggesting the remaining activators are high-intent "easy converts," while a growing share of new signups aren't engaging at all in their first week.

**PM Action:** 
 Investigate what changed in the week of May 25, 2026 -the exact inflection point where activation rate began its three-week slide from 22% to 8.8%. 
Specifically: 
-  pull paid marketing channel/spend mix for May 25–June 8 and compare to the May 11–18 mix, since a shift toward lower-intent traffic would show up as exactly this pattern
- check the deploy log for any onboarding, homepage, or checkout-entry changes shipped in that window, since a UX regression would produce the same signature.


# Checkout Funnel Drop-off by Entry Channel
**Business question:** "Where is checkout leaking, and is the leak the same across paid social vs organic search?"

**Interpretations:**
- Affiliate has the highest address-step drop (4.2%) and referral the highest shipping/final drops (2.3%/8.3%)
- The leak pattern is consistent across channels, not channel-specific: address (~3.3-4.2%), shipping (~1.3-2.4%), and payment (~1.2-1.6%) drop-offs are all in tight ranges regardless of whether traffic is organic, paid, referral, email, or affiliate
- Final step (payment → purchase) is the biggest leak everywhere, roughly double the address-step drop

**PM Action**
- pull session recordings for the ~1,600 sessions site-wide that reached add_payment but never completed purchase in the most recent 2-week window, segmented evenly across organic and paid (the two highest-volume channels)


# Cohort Retention Curve (Weekly, Behavioral)
**Business question:** "Of users who signed up in week W, what fraction came back and did *something meaningful* in week W+1, W+2, W+3, W+4?"

**Interpretations:**
- Cohorts April 13 – May 4 are fully observed and show healthy, stable retention. W1 retention runs 25–36%, and W4 doesn't collapse relative to W1
- W4 doesn't collapse relative to W1 — it's often flat or even higher (April 20: 30.3% → 36.6%; April 13: 24.8% → 36.4%). No sign of a habit-formation drop-off in the reliable data.
- w0_active < cohort_size is expected, not a bug: cohort_size counts every signup that week, while w0_active only counts those who took a meaningful action (product_view/add_to_cart/purchase) in that same week. The gap is real customers who signed up but didn't engage meaningfully in week 0 they still bounced, browsed without viewing a product, or never returned at all

**PM Action**
- Neither the activation-bottleneck nor the habit-formation fix applies — W1 is well above the 20% threshold (25–36%) and W4 doesn't collapse in any fully-observed cohort.


# PDP Engagement: High-View, Low-Cart Products
**Business question:** "Which products attract eyeballs but don't get added to cart? Those are either pricing problems, image problems, or stock problems."

**Interpretations:**
- all 10 products sit ~28-32 points below their category median ATC rate, despite spanning Makeup, Smartwatch, Bedding, Jackets, and Jeans — this uniformity suggests a common cross-category friction (e.g., a PDP template issue, generic pricing display problem, or checkout-adjacent UX issue) rather than category-specific pricing or stock problems.
- Smartwatch shows up twice in the top 10 (Silverbirch Vital Hybrid, BassForge Kids Smartwatch) — worth checking if this category has a specific issue (e.g., sizing/compatibility confusion, price sensitivity) beyond the general pattern.

**PM Action**
- Hand to merchandising with per-SKU hypotheses — Makeup items → image (shade accuracy), Smartwatches → price (comparison shopping), Jackets → stock (size-level availability), Tops/Kitchen → image (fit/scale uncertainty), Jeans → price. Given the consistent gap size across categories, also flag a shared root cause (e.g., PDP template/image pipeline) as worth ruling out before treating each SKU independently



# Cart Abandonment by Cart Value Bucket
**Business question:** "Cart abandonment is 70% overall — but is it the same for ₹500 carts as ₹15,000 carts? Where do we lose the most rupees?"

**Interpretations:**
- Abandonment rate rises with cart value: 63% for ₹15,000+ carts vs. 53% for sub-₹500 carts — bigger baskets abandon more, which points to payment friction
- GMV loss is heavily concentrated at the top: the ₹15,000+ and ₹5,000-14,999 buckets together account for ~₹22.7 Cr of roughly ₹25.4 Cr total lost GMV — so fixing high-value cart abandonment (financing options, trust badges, saved-cart reminders) would recover far more revenue than optimizing low-value buckets, even though those buckets have fewer sessions.

**PM Action**
-  GMV loss is clearly concentrated in the top two buckets, not the bottom one — so per the brief's framework, prioritize checkout reliability work, not free-shipping thresholds.Focus the payment-step investigation (from E2) specifically on high-cart-value sessions first -pull session recordings filtered to carts ≥₹5,000 that reached add_payment but didn't purchase


# Monthly MRR Movement Decomposition
**Business question:** "How did MRR change last month — and what drove the change? New, expansion, contraction, or churn?"

**Interpretations:**
- Churn spiked sharply in January and March (-₹9,506 and -₹13,821) — roughly 2-3x the typical monthly churn of -₹1,500 to -₹4,900
- New MRR consistently dominates the mix and is trending up: it's 10-15x larger than churn in most months and grew from ~₹12-18K (mid-2025) to ~₹20-24K (Feb-May 2026), so despite the March churn spike, the underlying new-business engine looks healthy

**PM Action**
- Cut March 2026's churned accounts by signup cohort month — pull the account_ids behind that cancelled event total and group by when they originally signed up. This tells you whether the spike is a small number of large/old accounts churning together v/s a specific signup cohort churning at an elevated rate


# Trial-to-Paid Conversion by Cohort
**Business question:** "Of accounts that started a trial in week W, what fraction converted to paid by day 14, 30, 60?"

**Interpretations:**
- Weekly volumes are too small to trust individual week-over-week rates (many weeks have just 1-4 trials), so rates swing from 0% to 100% week-to-week purely from small-sample noise
- recent cohorts (Feb-May 2026) still land in a similar 25-100% range as cohorts from a year ago, suggesting trial-to-paid conversion has been roughly stable rather than trending in either direction

**PM Action**
- Pick October 7 & 14, 2024 as the worst cohorts (tied for highest-volume complete failure). Cut those 8 trial accounts by acquisition/lead source — if they cluster around one channel (e.g., a specific paid campaign or partner referral), that's a marketing/lead-quality problem; if they're spread across sources but cluster on company size or plan trialed, that points to a product-fit problem

# Gross Revenue Churn and Net Revenue Retention by Cohort
**Business question:** "Of the MRR we had from a given monthly cohort 12 months ago, how much did we keep (gross retention) and how much did we keep INCLUDING expansion (net retention)?"

**Interpretations:**
- NRR is strong and often above 100% through most of 2023-early 2025 (peaking near 194% in Sept 2023, consistently 120-190% in many months
- May 2025 cohort has GRR of just 42% and NRR of 58%, and June 2025 is 49%/79% — both far below the 70-95% GRR range typical of earlier cohorts. This is the headline finding and worth investigating immediately

**PM Action**
- This is the GRR-below-80% world, not just in the recent cohorts but as a recurring pattern across most of the dataset-meaning retention, not growth spend, is the company's biggest lever


# Feature Adoption vs Retention
**Business question:** "Which product features predict 90-day retention? Which are red herrings?"

**Interpretations:**
- Six features show zero adoption in the 14-day window (IP Allowlisting, API Access, Reports, CSV Import, Priority Support, Custom Fields) — this is either a genuine "nobody touches these in onboarding" signal worth investigating
-  most features have only 1-18 adopters out of a 900-account base

**PM Action**
- API Bulk Operations has the largest credible lift by sample size (18 adopters, 100% retention vs. 98% baseline) — but given the near-zero headroom above baseline and the obvious selection-bias risk (bulk-ops users are likely already your most committed, technical accounts), this deserves deeper investigation first, not a discoverability push

# Expansion Revenue: Who's Upgrading and Why
**Business question:** "Of accounts that expanded MRR in the last 6 months, what's the dominant expansion vector — seats added, plan upgrade, or add-on attach?"

**Interpretations:**
- Plan upgrades are the dominant expansion vector: 94 accounts and 103 events drove ~₹10,954 in expansion MRR — more than double seat-adds and vastly more than add-ons
- Seat-adds expand faster and bigger per account: seat-add accounts contribute ~₹186/account (vs. ~₹117 for plan upgrades) and happen much earlier in the account lifecycle (median account age ~75 days vs. ~417 days for plan upgrades)

**PM Action**
- Put the bigger push behind making plan upgrades easier to find and choose - clearer pricing pages, in-app prompts nudging people to the next tier- since that's the slightly bigger and more common of the two

