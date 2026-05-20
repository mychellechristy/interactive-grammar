# Interactive Grammar Book — Codebase Map

> **Single-file vanilla app** deployed to **https://english.casapetrova.com/** via GitHub Pages.
> All code lives in `index.html`. This map shows where to find and change things.

## Quick reference

| What | Search for | Approx line | Notes |
|---|---|---|---|
| Supabase URL & key | `SUPABASE_URL` | ~1085 | Sync config |
| All grammar units | `const UNITS` | ~1098 | Units 1-18 (1-25 dropdown) |
| Skills Lab content per unit | `const SKILLS` | ~3049 | translation, dialogues, etc. |
| Phrase bank | `const PHRASES` | ~4400 | Static phrase list |
| 90-day plan | `PLAN_WEEKS` | ~4446 | Daily study schedule |
| Episodes (TV transcripts) | `const EPISODES` | ~4748 | Normal People S01E01 |
| Live Classes | `const LIVE_LESSONS` | ~5097 | L1, L2, L3 lessons |
| Common words dictionary | `const COMMON_WORDS` | ~6407 | were/was/grinds/etc. |
| Word popup (dblclick) | `showWordPopup` | ~6822 | Editable popup |
| Flashcards system | `renderFlashcardView` | ~6945 | SRS-based review |
| SRS algorithm | `getNextInterval` | ~7020 | Again/Hard/Good/Easy intervals |
| Edit flashcard | `editFlashcard` | ~7095 | Inline edit modal |
| Phrase selection lookup | search `mouseup` in dblclick area | ~6713 | Multi-word selection |
| Audio / voice selection | `getEnglishVoice` | search bottom | Voice priority list (en-US only) |

---

## Major sections in `index.html` (~8400 lines total)

```
Lines 1-1062     : HTML (head, styles, body markup, nav)
Lines 1063-1085  : <script> opens, SUPABASE_URL/KEY
Lines 1086-1094  : Supabase config
Lines 1095-3046  : UNITS data
Lines 3047-4397  : SKILLS Lab data (per unit)
Lines 4398-4443  : PHRASE BANK data
Lines 4444-4559  : 90-DAY PLAN data (PLAN_WEEKS)
Lines 4560-4570  : Global state (currentUnit, flashcards, audioCache)
Lines 4571-4596  : STORAGE (saveState, loadState, saveStateLocal)
Lines 4597-4744  : SUPABASE SYNC (push/pull/safety flag)
Lines 4745-4859  : EPISODES data
Lines 4860-5096  : LIVE_LESSONS data
Lines 5097-5641  : RENDER VIEWS (hide/show, unit, lesson, episode)
Lines 5642-6212  : RENDERING (renderUnit, exercises, skills)
Lines 6213-6402  : ANSWER CHECKING (normalize, checkAll, retry)
Lines 6403-6694  : AUDIO (COMMON_WORDS, buildLocalDictionary, fetchWordData)
Lines 6695-6927  : WORD POPUP (double-click & multi-word selection)
Lines 6928-7196  : FLASHCARDS (review, list, SRS, edit)
Lines 7197-7208  : TOAST notifications
Lines 7209-7741  : SKILLS LAB rendering (8 skill types)
Lines 7742-7801  : PHRASE BANK rendering
Lines 7802-7914  : 90-DAY PLAN rendering
Lines 7915-8137  : PROGRESS & DIFFICULTY tracking
Lines 8138-8315  : REMEDIAL EXERCISES (auto-generated practice)
Lines 8316-8391  : SYNC view (Cloud + Export/Import)
Lines 8392-8423  : INIT (loadState, showUnit(1), background pull)
```

---

## Common modification recipes

### Add a new Live Class (Lesson)
1. Find `const LIVE_LESSONS = [` (~line 4860)
2. Add new lesson object before the closing `];`:
   ```js
   {
     id: 'L4', date: '2026-MM-DD',
     title: 'Lesson Title',
     vocabulary: [{ word, ipa, meaning, examples: [..3 sentences..], extra, ptBr }],
     idioms:     [{ phrase, meaning, examples: [..3 sentences..], usage, ptBr }],
     grammarNotes: [{ title, wrong, correct, explanation }],
     exercises:  [{ id: 'L4.1', title, type: 'fill'|'write', instructions, items: [...] }]
   }
   ```
3. The local dictionary auto-includes new vocab/idioms (no extra work)
4. Test: `showLiveClasses()` then click the new lesson card

### Add a new TV Episode transcript
1. Get SRT file
2. Use the parser script:
   ```bash
   python3 -c "
   import re
   with open('episode.srt') as f: content = f.read()
   # parse and generate JS data
   " > /tmp/data.js
   ```
3. Insert in `const EPISODES = [` (~line 4748) before the closing `];`

### Fix a wrong word definition (e.g., wrong PT-BR for an irregular verb)
- Find `const COMMON_WORDS = {` (~line 6407)
- Add or edit the entry:
  ```js
  'word': { phonetic: '/.../', definition: 'English def', ptBr: 'tradução', example: 'Sentence.' }
  ```
- This dictionary takes priority over the external API

### Add a new Unit (e.g., Unit 19)
1. Add to `UNITS` (~line 1098): `19: { number, title, grammar: [...], exercises: [...] }`
2. Add to `SKILLS` (~line 3049): `19: { translation: [...], dialogues: [...], speedRound: [...], brazilianErrors: [...], sentenceBuilding: [...], grammarCards: [...], dictation: [...], shadowing: [...] }`
3. Add `<option value="19">Unit 19: Title</option>` to nav dropdown (~line 1003)
4. Add topic mapping in `getExerciseTopic` (search for it in PROGRESS section, ~line 7918)

### Change voice (accent / quality)
- Find `function getEnglishVoice` (~line 7415)
- Edit the `preferred` array — voices at top win
- Currently prioritizes neural Microsoft → Google US → Samantha
- Change `u.lang = 'en-US'` in `speakWord`, `speakDictation`, `speakEpisodeFromLine` if you want different accent

### Change SRS intervals (flashcard review timing)
- Find `function getNextInterval` (~line 7020)
- Three phases: new card (reps===0), learning (reps===1), review (reps>=2)
- Each phase has Again/Hard/Good/Easy intervals you can tune
- Ease factor adjustment is in `rateCard` (~line 7050)

### Fix an exercise's wrong answer or formatting
1. Find the unit in `UNITS` (~line 1098) — it's `N: { exercises: [...] }`
2. Find the exercise by id (e.g., `'13.2'`)
3. Edit the items array. Items have: `num, before, after, hints, answers, explanation` (fill) or `num, context, hint, answers, explanation` (write)
4. **Important**: `fill` exercises use `answers: [["correct1", "correct2"]]` (nested). `write` uses `answers: ["correct1", "correct2"]` (flat). Both formats are accepted by `answersMatch()` so it's forgiving.

### Modify the popup that appears on double-click
- HTML/CSS for popup: search `id="word-popup"` (~line 1075)
- Logic: `showWordPopup` function (~line 6822)
- Adding/editing fields in popup: edit the `content.innerHTML` template inside that function

### Modify flashcard review screen
- Card front/back HTML: `renderCurrentCard` (~line 6996)
- Buttons (Again/Hard/Good/Easy): same function, look for `fc-buttons` div
- All Cards list: `renderAllCards` (~line 7080)
- Edit modal: `editFlashcard` (~line 7095)

---

## Data shapes reference

### Unit
```js
{
  number: 1, title: '...',
  grammar: [{ id: 'A', title: '...', html: `...HTML...` }],
  exercises: [{
    id: '1.1', title: '...', type: 'fill'|'write'|'match',
    instructions: '...', wordBank: [...optional],
    items: [
      { isExample: true, num: 1, display: '...' },
      { num: 2, before: '...', after: '...', hints: [...], answers: [["ans"]], explanation: '...' }
    ]
  }]
}
```

### Skill (per unit)
```js
{
  translation:    [{ pt: '...', answers: ['English1', 'English2'] }],
  dialogues:      [{ title: '...', lines: [{ speaker: 'A'|'You', text|hint, answers }] }],
  speedRound:     [{ text: '... ___ ...', answers: ['correct'] }],
  brazilianErrors:[{ wrong: '...', hint: '...', answers: ['correct'], explanation: '...' }],
  sentenceBuilding:[{ words: ['word1', 'word2'], answer: 'final sentence' }],
  grammarCards:   [{ front: '...', back: '...', example: '...' }],
  dictation:      [{ text: '...', words: N }],
  shadowing:      [{ text: '...', slow: '... ... pauses' }]
}
```

### Live Lesson
```js
{
  id: 'L1', date: 'YYYY-MM-DD', title: '...',
  vocabulary: [{ word, ipa, meaning, examples: [...], extra, ptBr }],
  idioms: [{ phrase, meaning, examples: [...], usage, ptBr }],
  grammarNotes: [{ title, wrong, correct, explanation }],
  exercises: [{ id: 'L1.1', title, type: 'fill'|'write', instructions, items: [...] }]
}
```

### Episode
```js
{
  id: 'E1', show, season, episode, title, description,
  subtitles: [{ time: 'HH:MM:SS', text: 'subtitle line' }]
}
```

### Flashcard
```js
{
  word, definition, example, examples: [...],
  audioUrl, interval, nextReview: 'YYYY-MM-DD',
  easeFactor: 2.5, repetitions: 0, addedAt: 'ISO'
}
```

---

## Deploy workflow

```bash
cd /Users/mychellechristy/Claude\ Skills\ -\ Treino/interactive-grammar
git add index.html
git commit -m "..."
git push origin main
# GitHub Pages rebuilds in ~1-2 min. User does Cmd+Shift+R to bypass cache.
```

---

## Safety notes

- **NEVER push to Supabase from localhost** — already protected by `IS_LOCAL` check
- **NEVER push empty state** — already protected by `cloudPullSucceeded` flag
- Use the **preview server** (port 8765) for testing: it disables Supabase sync
- Always reload preview after edits: `window.location.reload()` via preview_eval

---

## Maintenance philosophy

This single-file approach is intentional:
- One file → easy GitHub Pages deploy
- No build step → instant changes
- Everything searchable with one Ctrl+F
- Section markers + this map = fast navigation

To find anything: search for the constant name (`UNITS`, `SKILLS`, `LIVE_LESSONS`, `COMMON_WORDS`, `EPISODES`) or the function name (e.g., `showWordPopup`, `renderCurrentCard`).
