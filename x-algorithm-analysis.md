# X Algorithm Analysis: Engagement Optimization Guide

## Overview

The X "For You" feed uses a Grok-based transformer model that predicts engagement probabilities across 15+ action types. The algorithm combines in-network content (from accounts you follow) with out-of-network content discovered through ML similarity search.

## How the Algorithm Scores Content

The final score formula is:
```
Weighted Score = Σ (weight_i × P(action_i))
```

Where the model predicts probability of each action type:

### Positive Signals (Boost Your Content)
| Action | Description |
|--------|-------------|
| **Favorites/Likes** | Direct engagement signal |
| **Replies** | Conversation-driving content |
| **Reposts/Retweets** | Shareability indicator |
| **Quotes** | High-value engagement (adds commentary) |
| **Clicks** | Interest in expanded content |
| **Profile Clicks** | Author discovery signal |
| **Video Quality Views (VQV)** | Completion-based video engagement |
| **Photo Expand** | Visual content engagement |
| **Share (DM, Copy Link)** | Off-platform sharing intent |
| **Dwell Time** | Time spent viewing content |
| **Follow Author** | Strong relationship signal |

### Negative Signals (Suppress Your Content)
| Action | Description |
|--------|-------------|
| **Not Interested** | Explicit negative feedback |
| **Block Author** | Severe negative signal |
| **Mute Author** | Moderate negative signal |
| **Report** | Content policy concern |

---

## ✅ WHAT TO DO for Higher Engagement

### 1. **Maximize Reply Engagement**
- Ask questions that invite responses
- Create content that sparks conversation
- Replies are weighted heavily as they indicate community engagement

### 2. **Optimize for Dwell Time**
- Write compelling hooks that make people stop scrolling
- Use threads for longer content (keeps users engaged)
- The algorithm tracks continuous dwell time as a quality signal

### 3. **Encourage Shares and Quotes**
- Create content worth sharing (`SHARE_WEIGHT`, `SHARE_VIA_DM_WEIGHT`, `SHARE_VIA_COPY_LINK_WEIGHT`)
- Quote tweets count more than simple retweets (adds value)
- Shareable formats: insights, data, controversial takes, humor

### 4. **Drive Profile Visits**
- `PROFILE_CLICK_WEIGHT` and `FOLLOW_AUTHOR_WEIGHT` are tracked
- Build curiosity about who you are
- Consistent, niche-focused content builds follow-through

### 5. **Optimize Video Content**
- Video Quality View (VQV) only counts after `MIN_VIDEO_DURATION_MS`
- Hook viewers in the first 2-3 seconds
- Completion rate matters more than just views

### 6. **Use Visual Content Strategically**
- `PHOTO_EXPAND_WEIGHT` tracks image engagement
- High-quality images that require expansion get tracked
- Infographics and data visualizations drive clicks

### 7. **Post When Your Audience Is Active**
- The algorithm uses `age_filter.rs` to filter old content
- Fresh content from followed accounts is prioritized via Thunder (in-memory store)
- Recency matters for in-network distribution

### 8. **Build Genuine Engagement History**
- The transformer learns from your engagement sequences
- Consistent interaction patterns with your audience improve recommendations
- Your content is matched to users with similar engagement histories

### 9. **Leverage In-Network Strength First**
- Thunder handles in-network posts with sub-millisecond lookups
- Your followers see your content first - activate them
- High engagement from followers signals out-of-network expansion

---

## ❌ WHAT NOT TO DO (Avoid These Penalties)

### 1. **Don't Trigger "Not Interested" Actions**
- Avoid rage-bait that annoys more than engages
- Off-topic content from your usual niche triggers this
- Clickbait with no payoff leads to negative signals

### 2. **Don't Get Blocked or Muted**
- `BLOCK_AUTHOR_WEIGHT` and `MUTE_AUTHOR_WEIGHT` are negative multipliers
- Aggressive engagement farming backfires
- Spammy behavior accumulates blocks

### 3. **Don't Get Reported**
- `REPORT_WEIGHT` is a strong negative signal
- Content policy violations hurt your reach
- Even if not actioned, reports affect scoring

### 4. **Avoid Duplicate/Repetitive Content**
- `drop_duplicates_filter.rs` and `retweet_deduplication_filter.rs` exist
- Posting the same thing repeatedly gets filtered
- Retweet storms of the same content are deduplicated

### 5. **Don't Ignore the Deduplication System**
- `previously_seen_posts_filter.rs` hides recently viewed content
- `previously_served_posts_filter.rs` removes already-delivered content
- Recycled content won't resurface to the same users

### 6. **Avoid Muted Keywords**
- `muted_keyword_filter.rs` suppresses content with blocked terms
- Understand what keywords your target audience commonly mutes
- Polarizing political terms often get muted

### 7. **Don't Optimize for Vanity Metrics Alone**
- Likes alone aren't enough - replies, quotes, and shares matter more
- The weighted score combines ALL signals
- Gaming one metric while triggering negative signals backfires

### 8. **Don't Post and Disappear**
- The algorithm tracks your engagement sequences
- Not responding to replies reduces conversation depth
- Active participation in your own threads matters

---

## Key Technical Insights

### The Algorithm Has No Manual Rules
> "The system eliminates every single hand-engineered feature, relying on the transformer to learn from user engagement patterns."

This means:
- There's no secret "hack" - genuine engagement wins
- The model learns from real user behavior patterns
- What works evolves as user behavior changes

### Scoring Independence
The Phoenix transformer ensures:
> "The score for a candidate doesn't depend on which other candidates are in the batch."

This means:
- Your content is scored on its own merits
- You're not competing against specific other posts
- Consistent quality matters more than timing tricks

### Out-of-Network Discovery
Phoenix ML retrieval finds content for users who don't follow you based on:
- Similarity to content they've engaged with
- Your engagement pattern matching their interests
- Building a consistent content niche helps ML categorization

---

## Summary: The Engagement Hierarchy

Based on the weighted scoring system, prioritize in this order:

1. **Replies & Conversation** - Highest signal of valuable content
2. **Quotes** - Higher value than simple retweets
3. **Shares (DM/Link)** - Indicates off-platform value
4. **Dwell Time** - Quality attention metric
5. **Follow Actions** - Strong relationship building
6. **Likes/Favorites** - Base engagement signal
7. **Clicks & Profile Visits** - Interest indicators

**Avoid at all costs:**
- Reports > Blocks > Mutes > "Not Interested"

The algorithm rewards content that creates genuine engagement and conversation while penalizing content that annoys, offends, or drives users away.
