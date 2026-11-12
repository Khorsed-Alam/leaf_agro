# AgriCare AI — User Manual & Operations Guide
*Comprehensive Step-by-Step Guide for Farmers & Field Officers (English & Bengali)*

---

## 🌟 Application Workflow Overview

![AgriCare AI Flowchart](images/agricare_ai_application_flowchart.jpg)

AgriCare AI (LeafAgro) provides automated, on-device AI plant pathology diagnosis tailored specifically for Bangladeshi agricultural ecosystems. The user workflow spans **Screens 01 through 07** to guide farmers seamlessly from authentication to crop diagnosis.

---

## 🇬🇧 English Operations Manual

### Screen 01: Animated Splash Screen
1. **Launch:** Open AgriCare AI on your Android or iOS device.
2. **System Initialization:** The application displays the brand logo, version number, and offline TFLite runtime checks.
3. **Session Check:**
   - If an active Supabase session exists, the app navigates directly to **Screen 06: Main Home Dashboard**.
   - If no session is active or first launch, the app transitions smoothly to **Screen 02: Onboarding Screen**.

### Screen 02: Interactive Onboarding
1. **Explore Features:** Swipe through the visual introduction slides highlighting:
   - Instant leaf disease scanning powered by on-device AI.
   - 100% offline edge inference (no internet needed in rural fields).
   - Tailored treatment and prevention recommendations.
2. **Language Toggle:** Tap the language pill in the top-right corner to switch between **English** and **বাংলা**.
3. **Continue:** Tap **Get Started** or **Skip** to navigate to **Screen 03: Login Screen**.

### Screen 03: Farmer Login Screen
1. **Credentials:** Enter your registered email address and account password.
2. **Password Visibility:** Tap the eye icon to toggle password obfuscation.
3. **Actions:**
   - **Login:** Authenticates with Supabase Auth and lands on **Screen 06: Main Home Dashboard**.
   - **Create Account:** Tap **Register** or **Sign Up** to navigate to **Screen 04: Registration Screen**.
   - **Forgot Password:** Tap the **Forgot Password?** link to transition to **Screen 05: Forgot Password Screen**.

### Screen 04: Farmer Registration Screen
1. **Form Details:**
   - **Full Name:** Enter your full legal or preferred name (e.g., *Md. Khorshed Alam*).
   - **Email Address:** Enter a valid email address.
   - **Phone Number:** Enter your Bangladeshi mobile number (prefixed with `+880`).
   - **Password & Confirm Password:** Enter at least 8 characters containing letters and numbers.
2. **Terms & Conditions:** Review and check the *Terms & Conditions and Privacy Policy* agreement checkbox.
3. **Submit:** Tap **Create Account**. A confirmation notification will appear, and you will be routed to the Login screen.

### Screen 05: Password Recovery Screen
1. **Input:** Enter your registered email address into the single recovery field.
2. **Reset Request:** Tap **Send Reset Link**. A secure Supabase password recovery email will be dispatched.
3. **Confirmation:** Follow the instructions sent to your inbox to reset your password and return to Login.

### Screen 06: AgriCare AI Home Dashboard
1. **Header Profile & Greeting:**
   - Dynamic greeting (e.g., *"Good Morning, Farmer!"*) tailored to the time of day.
   - Displays the authenticated farmer's name.
   - Quick access to profile settings via avatar tap and notification center via bell icon.
2. **Hero Section ("Check Your Plant Health"):**
   - High-contrast green gradient card with illustration.
   - Primary Call-To-Action: Tap **Scan Plant** to initiate a disease examination. This opens **Screen 07: Crop Selection Screen**.
3. **Explore Crops Section:**
   - Horizontal gallery showing all 5 AI-supported crops: **Rice (ধান)**, **Potato (আলু)**, **Tomato (টমেটো)**, **Mango (আম)**, and **Jute (পাট)**.
   - Tap any crop to open its detailed botanical guide and common pathology encyclopedia.
4. **Recent Detections Section:**
   - Displays your most recent disease scans sorted chronologically.
   - Shows crop thumbnail, predicted condition, timestamp, and AI confidence level.
   - Tap any record to open the complete diagnosis report.
   - Tap **View All** to navigate to the complete diagnosis history.
5. **Compact Statistics & Quick Actions:**
   - Summary statistics of scans, healthy status ratio, and action shortcuts.

### Screen 07: Crop Selection Screen
1. **Crop Selection Grid:**
   - Visual 2-column grid showing only verified AI-supported crops.
   - Tap a crop card to select it (e.g., *Rice*). The card highlights with a Fresh Green border and check-circle indicator.
2. **Dynamic Search:**
   - Type in the search bar (e.g., *"আলু"* or *"Tomato"*). The grid filters dynamically in real time.
   - If no crops match, an empty-state illustration appears with a **Clear Search** button.
3. **Continue to Crop Details:**
   - Once a valid crop is selected, the bottom **Continue to Scan** button activates.
   - Tapping it preserves your selection in application state and advances to **Screen 08: Crop Details Screen** (`/crops/:id`).

### Screen 08: Crop Details Screen
1. **Top Bar & Actions:**
   - Displays dynamic crop name (e.g. *Rice Profile* / *ধানের বিবরণ*).
   - Bookmark button to save the crop to farmer favorites.
   - Back navigation returns to Crop Selection or Dashboard.
2. **Hero Photograph & Identity:**
   - High-resolution realistic photography with green gradient overlay.
   - English and Bengali names, category badge, and AI-supported indicator with disease count.
3. **Crop Information Cards (Agronomy):**
   - 2-column visual grid showing Category, Growing Season (e.g. Aus, Aman, Boro), Water Need, Sunlight Requirement, Soil Preference, and Growth Duration.
4. **Common Diseases Section:**
   - Horizontal gallery of verified diseases trained in the MobileNetV2 AI model for the selected crop.
   - Each card displays disease name, Bangla name, severity badge (Critical, High, Moderate, Healthy), symptom snippet, and details link to `/diseases/:id`.
5. **Crop Care Tips:**
   - Practical field care guidelines from verified Bangladeshi agricultural research (Water Depth, Balanced Urea, Weed Control, Pest Monitoring).
6. **Prominent Disease Detection CTA:**
   - Fixed bottom action button: **"Detect [Crop] Disease"** (e.g. *"Detect Rice Disease"* / *"ধানের রোগ পরীক্ষা করুন"*).
   - Tapping verifies AI support, sets global crop selection, and advances to the diagnostic scanner (`/detect`).

### Screen 09: Plant Disease Categories Screen
1. **Directory Header & Overview:**
   - Heading: *"Plant Diseases"* / *"ফসলের রোগসমূহ"*.
   - Subtitle: *"Explore common diseases affecting crops."*
   - Accessible from the Home Dashboard or the Crop Details screen.
2. **Crop Filter Selector:**
   - Horizontally scrollable filter chips: **All Crops**, **Rice**, **Potato**, **Tomato**, **Mango**, **Jute**.
   - Tap any crop chip to instantly isolate the pathology catalog for that specific plant.
3. **Bilingual Search Bar:**
   - Real-time search by disease English name, Bangla name, symptoms, or associated crop.
   - Includes one-tap clear search button and immediate local filtering.
4. **Disease Category Cards:**
   - Clean white rounded cards with crop badge, disease titles, severity indicator (`Critical`, `High`, `Moderate`, `Healthy`), and symptom preview.
   - Tapping a disease card navigates to the detailed disease diagnosis and treatment view (`/diseases/:id`).
5. **Smart Empty & Error States:**
   - Contextual empty states for no matching query, no diseases for selected crop, and catalog loading with pull-to-refresh.

---

## 🇧🇩 বাংলা ব্যবহারিক নির্দেশিকা (কৃষক ও মাঠ কর্মকর্তাদের জন্য)

### স্ক্রিন ০১: অ্যানিমেটেড স্প্ল্যাশ স্ক্রিন
১. **অ্যাপ চালু:** আপনার ফোনে AgriCare AI অ্যাপটি ওপেন করুন।
২. **সিস্টেম লোডিং:** অ্যাপটির লোগো প্রদর্শিত হবে এবং অফলাইন AI মডেল স্বয়ংক্রিয়ভাবে প্রস্তুত হবে।
৩. **লগইন পরীক্ষা:**
   - পূর্ববর্তী লগইন থাকলে সরাসরি **স্ক্রিন ০৬: মূল ড্যাশবোর্ড**-এ নিয়ে যাবে।
   - প্রথমবার চালু করলে **স্ক্রিন ০২: অনবোর্ডিং** পেজে যাবে।

### স্ক্রিন ০২: পরিচিতি ও অনবোর্ডিং
১. **ফিচারসমূহ দেখুন:** পাতা সোয়াইপ করে অ্যাপের মূল সুবিধাগুলো জানুন:
   - মোবাইল থেকেই তাত্ক্ষণিক ফসলের রোগ নির্ণয়।
   - সম্পূর্ণ ইন্টারনেট ছাড়া অফলাইনে কৃত্রিম বুদ্ধিমত্তা চালনা।
   - অনুমোদিত সঠিক কৃষি সমাধান ও প্রতিষেধক পরামর্শ।
২. **ভাষা পরিবর্তন:** উপরে ডানপাশের ভাষা বাটন চেপে **বাংলা** বা **English** নির্বাচন করুন।
৩. **পরবর্তী ধাপ:** **শুরু করুন (Get Started)** বাটনে চাপ দিয়ে **স্ক্রিন ০৩: লগইন** পেজে প্রবেশ করুন।

### স্ক্রিন ০৩: কৃষক লগইন স্ক্রিন
১. **লগইন তথ্য:** আপনার নিবন্ধিত ইমেইল ও পাসওয়ার্ড প্রদান করুন।
২. **পাসওয়ার্ড দেখা:** চোখের আইকন চেপে পাসওয়ার্ড চেক করতে পারেন।
৩. **বিকল্পসমূহ:**
   - **লগইন:** সঠিক তথ্য দিয়ে **স্ক্রিন ০৬: ড্যাশবোর্ড**-এ প্রবেশ করুন।
   - **নতুন অ্যাকাউন্ট:** নিচে **রেজিস্টার** বাটনে চাপ দিয়ে **স্ক্রিন ০৪**-এ যান।
   - **পাসওয়ার্ড ভুলে গেলে:** **Forgot Password?** বাটনে চাপ দিন।

### স্ক্রিন ০৪: নতুন অ্যাকাউন্ট রেজিস্ট্রেশন স্ক্রিন
১. **প্রয়োজনীয় তথ্য:**
   - **পুরো নাম:** আপনার নাম লিখুন (যেমন: *মোঃ খোরশেদ আলম*)।
   - **ইমেইল ঠিকানা:** সঠিক ইমেইল প্রদান করুন।
   - **মোবাইল নম্বর:** বাংলাদেশি মোবাইল নম্বর (+880 সহ)।
   - **পাসওয়ার্ড ও কনফার্ম পাসওয়ার্ড:** কমপক্ষে ৮ অক্ষরের বর্ণ ও সংখ্যাযুক্ত শক্তিশালী পাসওয়ার্ড দিন।
২. **শর্তাবলী সম্মতি:** *শর্তাবলী ও নীতিমালা* চেক বক্সে টিক চিহ্ন দিন।
৩. **অ্যাকাউন্ট তৈরি:** **Create Account** বাটনে চাপ দিন। সফল হওয়ার পর লগইন পেজে নিয়ে যাবে।

### স্ক্রিন ০৫: পাসওয়ার্ড পুনরুদ্ধার স্ক্রিন
১. **ইমেইল প্রদান:** অ্যাকাউন্টের ইমেইল ঠিকানাটি লিখুন।
২. **রিসেট লিংক পাঠান:** **Send Reset Link** বাটনে চাপ দিন।
৩. **ইমেইল চেক করুন:** আপনার ইনবক্সে আসা নির্দেশিকা অনুসরণ করে নতুন পাসওয়ার্ড সেট করুন।

### স্ক্রিন ০৬: AgriCare AI মূল ড্যাশবোর্ড
১. **স্বাগতম ও প্রোফাইল হেডার:**
   - দিনের সময়ের সাথে সামঞ্জস্যপূর্ণ শুভেচ্ছা বার্তা (যেমন: *"শুভ সকাল, কৃষক ভাই!"*)।
   - কৃষকের নাম এবং প্রোফাইল ছবি ও নোটিফিকেশন বেল।
২. **রোগ নির্ণয় হিরো কার্ড ("Check Your Plant Health"):**
   - আকর্ষণীয় সবুজ গ্র্যাডিয়েন্ট কার্ড।
   - বড় **Scan Plant (ফসল পরীক্ষা করুন)** বাটনে চাপ দিয়ে সরাসরি **স্ক্রিন ০৭: ফসল নির্বাচন** স্ক্রিনে যান।
৩. **ফসল এক্সপ্লোর সেকশন:**
   - AI সমর্থিত ৫টি ফসলের ছবি ও তালিকা: **ধান (Rice)**, **আলু (Potato)**, **টমেটো (Tomato)**, **আম (Mango)**, এবং **পাট (Jute)**।
   - যেকোনো ফসলে চাপ দিয়ে তার সাধারণ রোগ ও যত্ন নির্দেশিকা দেখুন।
৪. **সাম্প্রতিক পরীক্ষা রেকর্ড (Recent Detections):**
   - আপনার স্ক্যান করা পূর্বের রোগ নির্ণয়ের তালিকা।
   - রোগের নাম, তারিখ এবং AI কনফিডেন্স স্কোর প্রদর্শিত হয়।
   - বিস্তারিত দেখতে যেকোনো রেকর্ডে চাপ দিন অথবা সব দেখতে **View All** চাপুন।

### স্ক্রিন ০৭: ফসল নির্বাচন স্ক্রিন (Crop Selection)
১. **ফসল গ্রিড:**
   - AI মডেল দ্বারা সমর্থিত শস্যের আধুনিক দুই কলাম গ্রিড।
   - যে ফসলটি পরীক্ষা করতে চান তাতে চাপ দিন (যেমন: *ধান*)। সাথে সাথে সবুজ বর্ডার ও টিক চিহ্ন দেখা যাবে।
২. **স্মার্ট সার্চ বার:**
   - বাংলায় বা ইংরেজিতে ফসলের নাম লিখে সহজে খুঁজুন (যেমন: *"আলু"* বা *"Tomato"*)।
   - কোনো ফসল না মিললে **Clear Search** বাটন চেপে পুনরায় পুরো তালিকা দেখুন।
৩. **পরবর্তী ধাপে যান:**
   - ফসল নির্বাচন সম্পন্ন হলে নিচের **Continue to Scan (পরবর্তী ধাপ)** বাটনটি সক্রিয় হবে।
   - বাটনে চাপ দিয়ে সরাসরি **স্ক্রিন ০৮: ফসলের বিবরণ ও রোগ তালিকা** পেজে যান।

### স্ক্রিন ০৮: ফসলের বিস্তারিত তথ্য স্ক্রিন (Crop Details Screen)
১. **হেডার ও বুকমার্ক:**
   - নির্বাচিত ফসলের নাম (যেমন: *ধানের বিবরণ*) ও পছন্দের তালিকায় সংরক্ষণের জন্য বুকমার্ক বাটন।
   - ব্যাক বাটন চেপে পুনরায় ফসল পরিবর্তন করা যায়।
২. **হিরো ফটোগ্রাফি ও মূল তথ্য:**
   - ফসলের বড় ছবি, বাংলা ও ইংরেজি নাম, ফসলের সারসংক্ষেপ ও AI সমর্থিত রোগের সংখ্যার ব্যাজ।
৩. **কৃষি তথ্য কার্ড (Crop Information):**
   - ২-কলামের তথ্য কার্ড: ফসলের বিভাগ, চাষের মৌসুম (আউশ, আমন, বোরো), পানির চাহিদা, সূর্যালোক, মাটির ধরন ও ফসল পাকার সময়।
৪. **পরিচিত রোগসমূহ (Common Diseases):**
   - উক্ত ফসলের জন্য প্রশিক্ষিত AI মডেলের রোগসমূহের গ্যালারি (যেমন ধানের জন্য: ব্যাকটেরিয়াল লিফ ব্লাইট, বাদামী দাগ, পাতার স্মাট ও সুস্থ পাতা)।
   - তীব্রতার মাত্রা (মারাত্মক, উচ্চ, মাঝারি, সুস্থ) এবং বিস্তারিত দেখতে কার্ডে চাপ দিন।
৫. **ফসল পরিচর্যার পরামর্শ (Crop Care Tips):**
   - জমিতে পানির গভীরতা, সুষম ইউরিয়া সার প্রয়োগ, নিড়ানি ও রোগ পর্যবেক্ষণের নির্ভরযোগ্য পরামর্শ।
৬. **রোগ নির্ণয় বাটন (Detect Crop Disease):**
   - স্ক্রিনের নিচে বড় সবুজ বাটন: **"ধানের রোগ পরীক্ষা করুন"** (অন্যান্য ফসলের ক্ষেত্রে ফসলের নাম অনুযায়ী পরিবর্তিত হবে)।
   - বাটনে চাপ দিলে সরাসরি পাতার ছবি গ্রহণ ও রোগ নির্ণয় পেজে নিয়ে যাবে।

### স্ক্রিন ০৯: উদ্ভিদের রোগ ক্যাটাগরি ও তালিকা স্ক্রিন (Plant Disease Categories)
১. **ডিরেক্টরি হেডার:**
   - শিরোনাম: *"ফসলের রোগসমূহ"* এবং ব্যাক নেভিগেশন বাটন।
   - ড্যাশবোর্ড বা ফসলের বিবরণী পেজ থেকে সহজেই প্রবেশ করা যায়।
২. **ফসল ফিল্টার চিপস:**
   - অনুভূমিকভাবে স্ক্রোলযোগ্য ফিল্টার: **সকল ফসল**, **ধান**, **আলু**, **টমেটো**, **আম**, **পাট**।
   - যেকোনো ফসলে চাপ দিয়ে মুহূর্তেই সেই ফসলের রোগ তালিকা আলাদা করা যায়।
৩. **দ্বিভাষিক সার্চ বার:**
   - রোগের নাম (বাংলা বা ইংরেজি), ফসলের নাম বা লক্ষণ লিখে সরাসরি রিয়েল-টাইম সার্চ।
   - ক্রস (X) বাটন চেপে এক ক্লিকে সার্চ ক্লিয়ার করার সুবিধা।
৪. **রোগ ক্যাটাগরি কার্ড:**
   - প্রতিটি কার্ডে ফসলের ব্যাজ, রোগের ইংরেজি ও বাংলা নাম, তীব্রতার মাত্রা (মারাত্মক, উচ্চ, মাঝারি, সুস্থ) ও ক্ষতিকর লক্ষণের সারসংক্ষেপ প্রদর্শিত হয়।
   - যেকোনো কার্ডে চাপ দিলে রোগটির সম্পূর্ণ সমাধান ও প্রতিরোধ সংক্রান্ত পেজে নিয়ে যায়।
৫. **স্মার্ট এম্পটি স্টেট:**
   - কোনো ফলাফল না মিললে বা ডাটাবেজ তথ্য না থাকলে বন্ধুত্বপূর্ণ নোটিফিকেশন ও ফিল্টার রিসেট বাটন প্রদর্শিত হয়।

---

## 🛠️ Offline & Field Deployment Tips

1. **Camera Lighting:** Always photograph affected leaves under bright, indirect sunlight for the highest diagnostic accuracy.
2. **Leaf Framing:** Ensure the infected lesion or spot is centered and in focus. Avoid blurry or dark photos.
3. **Offline Guarantee:** All inference for Rice, Potato, Tomato, Mango, and Jute runs entirely locally on your phone without requiring mobile data.
