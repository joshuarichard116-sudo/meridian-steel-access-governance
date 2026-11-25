# Pizzazz style guide (the Dress It Up kit)

This repo uses one house look, called **Spec Sheet**. The GitHub Action in `.github/workflows/pizzazz.yml` follows this guide whenever new content is pushed to `main`. A person can follow it too, and the **Dress It Up** section below is how Claude uses it interactively in a chat.

## Ground rules

1. **Content is sacred.** Never change facts, numbers, names, dates, settings, commands or meaning. Never invent results, screenshots, certifications or claims.
2. **Change formatting, not writing.** The only wording edits allowed:
   - Replace buzzwords: "leverage", "synergy", "robust", "seamless", "cutting-edge", "delve", "elevate".
   - Fix clear typos and grammar.
   - Break up paragraphs longer than about 5 sentences.
3. **Voice:** first person, professional but human, plain and short sentences, explains why after what. No humor and no emoji in body text.
4. **Don't stack.** If a file already has a `pizzazz-recipe` comment, only style the parts that are new or changed. Never add a second banner or duplicate badges.
5. **Leave templates plain.** Files meant to be copied and filled in (anything under `templates/`, or with "template" in the name) keep their plain layout.
6. **Leave code alone.** Don't edit scripts (`.ps1`, `.sh`, `.py`, etc.), configs or data files. Only Markdown files and the `assets/` folder.
7. **Never** add personal data (emails, phone numbers, tenant IDs, IP addresses) and never alter what a screenshot shows.

## Dress It Up: ask first, then style

Dress It Up is the interactive way to use this kit. Before styling anything, ask the person a few questions so the result looks like *their* page, not a generic one. Ask them all in one short message, offer the choices shown, and say that any question can be skipped.

1. **What are you building, and who reads it?** (portfolio, lab guide, admin dashboard, tech talk, launch page, runbook, or something else)
2. **Light, dark, or both?**
3. **Pick a palette.** Show the [palette library](#palette-library) below as named choices with a one-line vibe each, and mark the one that fits their answer to question 1 as *suggested*. They can also bring their own colors or brand colors.
4. **Mood:** calm, technical, or bold.
5. **How much flash:** subtle, standard, or bold. This sets `dev.intensity` in the recipe.
6. **A page you like** (optional): a link or a screenshot to borrow spacing and structure from. Never copy its logo, name or content.

If a question is skipped, use the default: question 1's suggested palette, light, technical, standard. If they bring their own colors, check that text keeps a contrast ratio of at least 4.5:1 and fix the shade rather than the hue, then give the palette a short vibe name of its own.

**Save the answers.** In a repository, write them to `.github/pizzazz/profile.md` (palette name, the eight hex values, light or dark, mood, intensity, date). Every later run, including the GitHub Action, reads that file first and uses it in place of the default palette, so the next page matches without asking again. In a chat, repeat the profile back at the end so the person can keep it.

**Unattended runs** (the GitHub Action, or anyone running the kit without a person to ask) never ask questions: they use `profile.md` if it exists, and Rustic if it doesn't.

## Palette library

Every palette fills the same eight roles, so the banner, badge, divider and diagram templates below work with any of them: swap the hex values and keep the layout. The banner template uses `tint` for its background and `pri` for its title, so the dark palettes flip naturally. In the diagram `init` line, use `tint` for node fills, `zeb` for groups, `pri` for text and borders, and `acc` for lines.

| Palette | Vibe and best for | pri | sec | tint | zeb | mut | hair | acc | watch |
|---|---|---|---|---|---|---|---|---|---|
| **Rustic** (default, `my-color-profile`) | Warm and grounded, amber accent. Portfolios, trades and manufacturing, personal pages, READMEs. | `#27241D` | `#423D33` | `#FAF5EE` | `#F7F3EC` | `#625B50` | `#D9D1C4` | `#D9A21B` | `#B44D12` |
| **Control Room** | Crisp admin console: slate rail, teal accent. Lab guides, dashboards, firewall and network docs. | `#17232E` | `#22323F` | `#EEF1F4` | `#F5F7F9` | `#5A6878` | `#D5DCE3` | `#0B7A85` | `#C0362C` |
| **Sea Glass** | Calm and clean: soft green-gray, deep teal, copper. Training pages, internal how-tos, runbooks. | `#1B2624` | `#116466` | `#EEF4F2` | `#DBEEEA` | `#4D605B` | `#D3E2DD` | `#1F8A70` | `#C9773F` |
| **Night Shift** (dark) | Dark slate with a teal glow and a peach highlight. Tech talks, presentations, dark-first pages. | `#E6F1EE` | `#1A2523` | `#0F1716` | `#1A2523` | `#9FB5AF` | `#2F3D3A` | `#FFCB9A` | `#FF8A7A` |
| **Aurora** (dark) | Bright and playful: violet, aqua and coral on deep indigo. Launch pages, demos, hackathon projects. | `#ECEBFF` | `#1A1733` | `#0F0D1F` | `#1A1733` | `#A9A5C9` | `#2E2A52` | `#8F7BFF` | `#FF8466` |

Badges: on a light palette, the label background is `pri`, topic values use `sec` and status values use `acc`. On a dark palette, the label background is `sec`, and both topic and status values use `acc`.

The accent rule holds for every palette: never use `acc` as body text on a light background. On the dark palettes, it is fine for headings and links.

## Default palette: Rustic (my-color-profile: warm and grounded, amber accent)

Used when there is no `profile.md` and nobody to ask. The table below gives each role's use.

| Role | Hex | Use |
|---|---|---|
| Primary | `#27241D` | banner title, badge label background |
| Secondary | `#423D33` | badge value background |
| Tint | `#FAF5EE` | banner background, diagram node fill |
| Zebra | `#F7F3EC` | diagram group fill |
| Muted | `#625B50` | banner eyebrow and subtitle |
| Hairline | `#D9D1C4` | banner border, diagram group border |
| Accent | `#D9A21B` | amber rule, dividers, "status" badges. **Never as text on a light background.** |
| Watch | `#B44D12` | warnings only |

## Elements

### 1. Banner (one per README, replaces the plain H1)

Each README gets its own banner SVG in the repo-root `assets/` folder, named `banner.svg` for the root README or `banner-<folder-name>.svg` for a README in a subfolder. Use a relative path from the README. Make the H1 the image, with the full title as alt text:

```markdown
# ![Lab 01: Storage account redundancy](../../assets/banner-lab-01-storage-account-redundancy.svg)
```

Copy this template exactly and change only the three text lines and the `<title>`. Use the eyebrow (UPPERCASE, short) for the project or domain, the title (≤ 32 characters) for the page title, and the subtitle (≤ 95 characters) for the tech covered. Escape `&` as `&amp;`.

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="220" viewBox="0 0 1200 220" role="img" aria-labelledby="t">
  <title id="t">Access Governance &amp; RBAC</title>
  <metadata>{"pz":1,"kit":"my-color-profile","concept":"Spec Sheet","family":"refined","dev":{"intensity":"standard","flourish":"amber dividers","structure":"slim header"},"sig":"amber rule dividers","pal":{"pri":"#27241D","sec":"#423D33","tint":"#FAF5EE","zeb":"#F7F3EC","mut":"#625B50","ftr":"#6B6358","hair":"#D9D1C4","acc":"#D9A21B","watch":"#B44D12"},"font":{"h":"system-ui","b":"system-ui"},"date":"2026-11-18"}</metadata>
  <rect x="1" y="1" width="1198" height="218" rx="14" fill="#FAF5EE" stroke="#D9D1C4" stroke-width="2"/>
  <rect x="1" y="1" width="10" height="218" rx="5" fill="#27241D"/>
  <text x="64" y="66" font-family="system-ui, -apple-system, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif" font-size="17" font-weight="600" letter-spacing="3.5" fill="#625B50">MERIDIAN STEEL &amp; FABRICATION</text>
  <text x="64" y="122" font-family="system-ui, -apple-system, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif" font-size="46" font-weight="700" fill="#27241D">Access Governance &amp; RBAC</text>
  <rect x="64" y="142" width="150" height="5" rx="2.5" fill="#D9A21B"/>
  <text x="64" y="184" font-family="system-ui, -apple-system, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif" font-size="21" fill="#625B50">Hybrid Active Directory / Microsoft Entra ID lab  ·  AD DS · NTFS · Conditional Access · PIM · PowerShell</text>
</svg>
```

### 2. Badges (optional, at most 5, right after the banner)

```html
<p>
  <img alt="Azure Storage" src="https://img.shields.io/badge/Azure%20Storage-GRS-423D33?labelColor=27241D">
  <img alt="Validated" src="https://img.shields.io/badge/Status-validated-D9A21B?labelColor=27241D">
</p>
```

Topic badges use `423D33`; status or outcome badges use `D9A21B`. Only state statuses the content itself supports.

### 3. Emoji section headings

Every `##` heading starts with one fitting emoji, e.g. `## 🎯 Goal`, `## 🧱 Architecture`, `## ✅ Validation`, `## 🧹 Cleanup`. **Only use emoji that are a single character with no hidden variation selector (U+FE0F).** Emoji such as ⚠️ 🏗️ ⚙️ 🛡️ 🗺️ 🖥️ ⚖️ include one, and GitHub keeps it in the heading's link anchor, which breaks table-of-contents links. Safe picks: 🎯 🧱 🧭 🔐 🔒 🔑 🔄 🧠 ✅ 🧾 📦 📚 📂 📄 💡 💲 🚀 🔧 🧩 🧹 🎓 🏭 💻. If a table of contents links to headings, update its anchors: GitHub drops the emoji but keeps a leading hyphen, so `## 🎯 Goal` becomes `#-goal`.

### 4. Amber dividers (the signature move)

```html
<p align="center"><img src="assets/divider.svg" width="100%" alt=""></p>
```

Fix the `src` path for subfolders (e.g. `../../assets/divider.svg`). Use them in place of `---` and between major groups of sections, not before every heading. That means about one per 2–3 sections, and at most 2 on a short page.

### 5. Diagrams

Add this as the first line inside every Mermaid **flowchart** block. Leave sequence diagrams and other diagram types on GitHub's default theme, since their text sits on the page background and must adapt to dark mode.

```text
%%{init: {'theme':'base','themeVariables':{'primaryColor':'#FAF5EE','primaryTextColor':'#27241D','primaryBorderColor':'#423D33','lineColor':'#B8860B','secondaryColor':'#F7F3EC','tertiaryColor':'#F7F3EC','clusterBkg':'#F7F3EC','clusterBorder':'#D9D1C4','titleColor':'#27241D','edgeLabelBackground':'#FAF5EE','textColor':'#27241D'}}}%%
```

### 6. Recipe stamp (last line of every styled README)

```markdown
<!-- pizzazz-recipe: {"pz":1,"kit":"my-color-profile","concept":"Spec Sheet","family":"refined","dev":{"intensity":"standard","flourish":"amber dividers","structure":"slim header"},"sig":"amber rule dividers","pal":{"pri":"#27241D","sec":"#423D33","tint":"#FAF5EE","zeb":"#F7F3EC","mut":"#625B50","ftr":"#6B6358","hair":"#D9D1C4","acc":"#D9A21B","watch":"#B44D12"},"font":{"h":"system-ui","b":"system-ui"},"date":"YYYY-MM-DD"} -->
```

## Final check before committing

- Diff the text: no fact, number, name or command was changed or dropped.
- Every new SVG parses as valid XML.
- Every relative image path points to a file that exists.
- Table-of-contents anchors match the emoji headings.
- Commit message starts with `[pizzazz]`.
