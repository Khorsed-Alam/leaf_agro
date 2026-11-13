import 'package:flutter/material.dart';
import 'help_models.dart';

/// Screen 28 – Static Verified Educational Help & FAQ Catalog
class HelpContent {
  static const List<HelpGuide> guides = [
    // ── Guide 1: How to Detect Plant Disease ─────────────────────────────────
    HelpGuide(
      id: 'guide_detect_disease',
      titleEn: 'How to Detect Plant Disease',
      titleBn: 'গাছের রোগ কীভাবে শনাক্ত করবেন',
      descriptionEn: 'Follow a few simple steps to check your plant with AI.',
      descriptionBn: 'সহজ কয়েকটি ধাপে এআই দিয়ে আপনার গাছ পরীক্ষা করুন।',
      readingTimeEn: '2 min',
      readingTimeBn: '২ মিনিট',
      icon: Icons.qr_code_scanner_rounded,
      visualSequenceEn: [
        'Open App',
        'Select Crop',
        'Take Photo',
        'Analyze',
        'View Result',
      ],
      visualSequenceBn: [
        'অ্যাপ খুলুন',
        'ফসল নির্বাচন',
        'ছবি তুলুন',
        'বিশ্লেষণ',
        'ফলাফল দেখুন',
      ],
      stepsEn: [
        'Open AgriCare AI on your phone.',
        'Tap Detect Plant Disease or the Scan action on the home screen.',
        'Select the crop (Rice, Potato, Tomato, Mango, or Jute) if prompted.',
        'Take a clear leaf photo with your camera or choose one from your gallery.',
        'Review the captured photo on the preview screen for clarity.',
        'Tap Analyze Image to start the on-device AI examination.',
        'Wait a few seconds while MobileNetV2 completes inference.',
        'Review the diagnosis, confidence score, prevention advice, and treatment guidance.',
      ],
      stepsBn: [
        'আপনার ফোনে এগ্রিকেয়ার এআই অ্যাপটি খুলুন।',
        'হোম স্ক্রিনের "রোগ শনাক্ত করুন" বা স্ক্যান বোতামে চাপ দিন।',
        'অ্যাপ নির্দেশ দিলে ফসলের ধরন (ধান, আলু, টমেটো, আম বা পাট) নির্বাচন করুন।',
        'ক্যামেরা দিয়ে পাতার একটি স্পষ্ট ছবি তুলুন অথবা গ্যালারি থেকে নির্বাচন করুন।',
        'প্রিভিউ স্ক্রিনে ছবিটি স্পষ্ট ও ফোকাসযুক্ত কিনা ভালোভাবে দেখে নিন।',
        'রোগ পরীক্ষার জন্য "ছবি বিশ্লেষণ করুন" বোতামে চাপ দিন।',
        'অন-ডিভাইস মোবাইলনেট-ভি২ মডেলের বিশ্লেষণ শেষ হওয়া পর্যন্ত কয়েক সেকেন্ড অপেক্ষা করুন।',
        'ফলাফল দেখে রোগ নির্ণয়, কনফিডেন্স মাত্রা, প্রতিরোধ ব্যবস্থা ও প্রতিকার পরামর্শ জেনে নিন।',
      ],
      keyNotesEn: [
        'The AI model currently supports Rice, Potato, Tomato, Mango, and Jute.',
        'Diagnostic accuracy depends heavily on photo quality, focus, and visible symptoms.',
        'AI detection is an educational estimate, not a guaranteed laboratory diagnosis. Always consult a local agricultural extension officer for critical field decisions.',
      ],
      keyNotesBn: [
        'এআই মডেলটি বর্তমানে ধান, আলু, টমেটো, আম ও পাট ফসলে প্রশিক্ষিত।',
        'ফলাফলের সঠিকতা ছবির মান, আলোর পর্যাপ্ততা ও উপসর্গের স্পষ্টতার ওপর নির্ভর করে।',
        'এআই ফলাফল একটি সম্ভাব্য পূর্বাভাস, চূড়ান্ত নিশ্চয়তা নয়। জরুরি মাঠপর্যায়ের প্রয়োজনে উপজেলা কৃষি অফিসে যোগাযোগ করুন।',
      ],
    ),

    // ── Guide 2: How to Take a Good Leaf Photo ───────────────────────────────
    HelpGuide(
      id: 'guide_take_photo',
      titleEn: 'How to Take a Good Leaf Photo',
      titleBn: 'কীভাবে পাতার ভালো ছবি তুলবেন',
      descriptionEn: 'A clear photo can help the AI examine your plant.',
      descriptionBn: 'পরিষ্কার ছবি এআই-কে আপনার পাতা পরীক্ষা করতে সাহায্য করে।',
      readingTimeEn: '2 min',
      readingTimeBn: '২ মিনিট',
      icon: Icons.camera_alt_rounded,
      visualSequenceEn: [
        'Pick Leaf',
        'Steady Hands',
        'Natural Light',
        'Center Frame',
      ],
      visualSequenceBn: [
        'পাতা নির্বাচন',
        'হাত স্থির রাখুন',
        'স্বাভাবিক আলো',
        'মাঝখানে রাখুন',
      ],
      stepsEn: [
        'Choose a leaf that clearly displays symptoms, discoloration, or disease lesions.',
        'Keep the camera steady to prevent motion blur.',
        'Place the leaf in bright, natural daylight. Avoid deep shadows or harsh lens glare.',
        'Hold the camera 15-20 cm away and keep the single leaf centered in the camera frame.',
        'Ensure the leaf surface is sharp and in crisp focus before snapping the picture.',
        'Avoid covering any part of the leaf with your fingers or hand.',
        'Avoid distant canopy shots, very dark backgrounds, or out-of-focus images.',
        'Include both affected spots and surrounding leaf area for contrast.',
      ],
      stepsBn: [
        'রোগের দাগ বা লক্ষণ স্পষ্টভাবে ফুটে উঠেছে এমন পাতা বেছে নিন।',
        'ছবি তোলার সময় হাত ও ক্যামেরা পুরোপুরি স্থির রাখুন যেন ছবি না কাঁপে।',
        'দিনের উজ্জ্বল স্বাভাবিক আলোতে ছবি তুলুন। অতিরিক্ত অন্ধকার বা কড়া ছায়া এড়িয়ে চলুন।',
        'ক্যামেরা ১৫-২০ সেমি দূরত্বে রেখে পাতাটিকে ফ্রেমের মাঝখানে রাখুন।',
        'ক্যামেরার ফোকাস পাতার আক্রান্ত অংশের ওপর স্থির হওয়া নিশ্চিত করুন।',
        'পাতাটি কোনোভাবেই আঙুল বা হাত দিয়ে ঢেকে রাখবেন না।',
        'দূর থেকে পুরো গাছের ছবি বা অতিরিক্ত অন্ধকার ও ঝাপসা ছবি পরিহার করুন।',
        'লক্ষণগুলো সহজে বোঝার জন্য পাতার সুস্থ ও আক্রান্ত উভয় অংশ ফ্রেমে রাখুন।',
      ],
      keyNotesEn: [
        'Photos taken in steady natural light provide the highest diagnostic accuracy.',
        'Avoid flash photography at night, which can cause bright reflections on wet leaves.',
      ],
      keyNotesBn: [
        'দিনের স্বাভাবিক আলোতে তোলা পরিষ্কার ছবি এআই-কে সবচেয়ে নির্ভুল ফলাফল দিতে সাহায্য করে।',
        'রাতে ফ্ল্যাশ লাইট ব্যবহার করে ছবি তোলা এড়িয়ে চলুন, কারণ এতে ভেজা পাতায় তীব্র প্রতিফলন ঘটে।',
      ],
      goodTipsEn: [
        'Clear leaf in crisp focus',
        'Bright, even natural sunlight',
        'Visible spots and lesions',
        'Single leaf filling 70% of frame',
      ],
      goodTipsBn: [
        'পরিষ্কার ও ফোকাসযুক্ত একক পাতা',
        'উজ্জ্বল ও সমান স্বাভাবিক দিনের আলো',
        'রোগের দাগ ও উপসর্গ পরিষ্কারভাবে দৃশ্যমান',
        'পাতাটি ফ্রেমের প্রায় ৭০% অংশ জুড়ে রয়েছে',
      ],
      poorTipsEn: [
        'Blurry or out-of-focus shot',
        'Dark or deeply shadowed leaves',
        'Camera held too far away from leaf',
        'Fingers or thumb covering the symptoms',
      ],
      poorTipsBn: [
        'ঝাপসা বা ফোকাসহীন ছবি',
        'অন্ধকার বা অতিরিক্ত ছায়াযুক্ত পরিবেশ',
        'পাতা থেকে ক্যামেরা অতিরিক্ত দূরে রাখা',
        'আক্রান্ত অংশ আঙুল বা হাত দিয়ে ঢাকা',
      ],
    ),

    // ── Guide 3: Understanding AI Confidence ─────────────────────────────────
    HelpGuide(
      id: 'guide_ai_confidence',
      titleEn: 'Understanding AI Confidence',
      titleBn: 'এআই কনফিডেন্স বা আস্থার মাত্রা বোঝা',
      descriptionEn: 'Learn what the confidence percentage means.',
      descriptionBn: 'শতাংশের হিসাবটি কী নির্দেশ করে তা জানুন।',
      readingTimeEn: '1 min',
      readingTimeBn: '১ মিনিট',
      icon: Icons.analytics_rounded,
      visualSequenceEn: [
        'Confidence %',
        'Pattern Match',
        'Not Severity',
        'Verify Results',
      ],
      visualSequenceBn: [
        'আস্থার শতকরা হার',
        'লক্ষণ মেলানো',
        'রোগের মাত্রা নয়',
        'যাচাই করুন',
      ],
      stepsEn: [
        'The confidence percentage (e.g. 85%) shows how strongly the AI model favors its prediction compared with all other possible conditions.',
        'A higher percentage indicates a strong pattern similarity with the thousands of trained agricultural photos.',
        'A higher percentage does NOT guarantee 100% diagnostic correctness.',
        'A lower percentage means the symptoms may be ambiguous, lighting was suboptimal, or the crop is an untrained variety. Treat such results with caution.',
        'Important distinction: AI confidence is NOT disease severity. An 85% confidence score means the model is 85% certain of its diagnosis—not that 85% of your crop is destroyed.',
        'If the result is uncertain or low confidence, take another clearer photo under better light or consult your local agricultural office.',
      ],
      stepsBn: [
        'কনফিডেন্স শতাংশ (যেমন ৮৫%) নির্দেশ করে অন্যান্য সম্ভাব্য রোগের তুলনায় এই পূর্বাভাসটির প্রতি এআই কতটা সুনিশ্চিত।',
        'উচ্চ শতাংশ বোঝায় প্রশিক্ষিত হাজারো কৃষি ছবির সাথে আপনার পাতার উপসর্গের গভীর মিল পাওয়া গেছে।',
        'উচ্চ শতাংশ থাকলেও এটি শতভাগ নির্ভুলতার গ্যারান্টি বা চূড়ান্ত সত্য নয়।',
        'কম শতাংশের অর্থ হতে পারে লক্ষণগুলো স্পষ্ট নয়, আলো কম ছিল অথবা ভিন্ন জাতের পাতা। এমন ফলাফল সতর্কতার সাথে বিবেচনা করুন।',
        'জরুরি পার্থক্য: কনফিডেন্স শতকরা হার এবং রোগের তীব্রতা এক নয়। ৮৫% কনফিডেন্স মানে এআই রোগটি নিয়ে ৮৫% নিশ্চিত—এর মানে এই নয় যে আপনার গাছের ৮৫% নষ্ট হয়েছে।',
        'ফলাফল অস্পষ্ট মনে হলে পর্যাপ্ত আলোতে পুনরায় পরিষ্কার ছবি তুলুন অথবা স্থানীয় কৃষি উপসহকারী কর্মকর্তার সহায়তা নিন।',
      ],
      keyNotesEn: [
        'AI confidence is not the same as the percentage of your plant that is diseased, and it is not a guarantee of accuracy.',
        'Never apply high-risk chemical treatments based solely on an uncertain diagnosis.',
      ],
      keyNotesBn: [
        'এআই কনফিডেন্স শতকরা হার ফসলের ক্ষয়ক্ষতির পরিমাপ নয় এবং এটি নির্ভুলতার চূড়ান্ত নিশ্চয়তা নয়।',
        'অস্পষ্ট বা কম আস্থার ফলাফলের ওপর ভিত্তি করে কখনোই উচ্চমাত্রার রাসায়নিক বালাইনাশক স্প্রে করবেন না।',
      ],
    ),

    // ── Guide 4: Using the App Offline ───────────────────────────────────────
    HelpGuide(
      id: 'guide_offline_usage',
      titleEn: 'Using the App Offline',
      titleBn: 'ইন্টারনেট ছাড়া অ্যাপ ব্যবহার',
      descriptionEn:
          'Learn which features may work without an internet connection.',
      descriptionBn: 'ইন্টারনেট ছাড়া কোন সুবিধাগুলো চালু থাকবে তা জানুন।',
      readingTimeEn: '2 min',
      readingTimeBn: '২ মিনিট',
      icon: Icons.wifi_off_rounded,
      visualSequenceEn: [
        'On-Device AI',
        'Local Guides',
        'Saved Scans',
        'Online Sync',
      ],
      visualSequenceBn: [
        'অন-ডিভাইস এআই',
        'লোকাল সহায়িকা',
        'সংরক্ষিত হিস্ট্রি',
        'অনলাইন ব্যাকআপ',
      ],
      stepsEn: [
        '100% Offline AI Diagnosis: The MobileNetV2 neural network is embedded directly inside AgriCare AI. You can scan and identify crop diseases out in the field without internet, WiFi, or mobile data.',
        'Offline Treatment & Prevention Guides: All agricultural guidance, dosage rules, organic remedies, and prevention checklists are stored on your device and viewable completely offline.',
        'Local Scan History: Whenever you save a scan, it is stored in your local SQLite on-device database so you can revisit past records offline anytime.',
        'Features that Require an Internet Connection: Creating an account, logging in, synchronizing records to your Supabase cloud backup, and submitting feedback require internet access.',
      ],
      stepsBn: [
        'শতভাগ অফলাইন এআই রোগ নির্ণয়: মোবাইলনেট-ভি২ নিউরাল নেটওয়ার্ক সরাসরি আপনার ফোনের অ্যাপে সংরক্ষিত। ইন্টারনেট বা ডাটা না থাকলেও আপনি মাঠে বসেই তাত্ক্ষণিকভাবে রোগ শনাক্ত করতে পারবেন।',
        'অফলাইন প্রতিকার ও প্রতিরোধ নির্দেশিকা: ফসলের যত্ন, জৈব প্রতিকার, প্রতিরোধ চেকলিস্ট ও সার ব্যবহারের সকল পরামর্শ ফোনে সংরক্ষিত থাকায় ইন্টারনেট ছাড়াই পড়তে পারবেন।',
        'ফোনে হিস্ট্রি সংরক্ষণ: যেকোনো স্ক্যান সেভ করলে তা ফোনের অভ্যন্তরীণ মেমরিতে জমা থাকে, যা ইন্টারনেট ছাড়াই সবসময় দেখতে পাবেন।',
        'যেগুলোর জন্য ইন্টারনেট সংযোগ প্রয়োজন: নতুন অ্যাকাউন্ট নিবন্ধন, লগইন করা, ক্লাউড ব্যাকআপে ডাটা সিঙ্ক করা এবং ফিডব্যাক পাঠানো।',
      ],
      keyNotesEn: [
        'In-field disease detection and treatment recommendations require ZERO internet connection.',
        'Connect to the internet periodically if you wish to back up your scan history to your cloud account.',
      ],
      keyNotesBn: [
        'মাঠপর্যায়ে রোগ পরীক্ষা ও প্রতিকার পরামর্শ পাওয়ার জন্য কোনো ইন্টারনেটের প্রয়োজন নেই।',
        'আপনার স্ক্যান হিস্ট্রি ক্লাউড অ্যাকাউন্টে ব্যাকআপ রাখতে মাঝে মাঝে ইন্টারনেট সংযোগ চালু করুন।',
      ],
    ),
  ];

  static const List<FaqItem> faqs = [
    // ── FAQ 1 ────────────────────────────────────────────────────────────────
    FaqItem(
      id: 'faq_1',
      questionEn: 'How do I scan a plant?',
      questionBn: 'কীভাবে গাছের রোগ পরীক্ষা বা স্ক্যান করব?',
      answerEn:
          'Open AgriCare AI, tap "Detect Plant Disease" on the dashboard, choose your crop (Rice, Potato, Tomato, Mango, or Jute) if prompted, take a clear photo of the leaf or select one from your gallery, review the image, and tap "Analyze Image". The result will appear on your screen in seconds.',
      answerBn:
          'এগ্রিকেয়ার এআই অ্যাপ খুলে হোম স্ক্রিন থেকে "রোগ শনাক্ত করুন" বাটনে চাপুন। এরপর ফসলের ধরন (ধান, আলু, টমেটো, আম বা পাট) নির্বাচন করুন, পাতার স্পষ্ট ছবি তুলুন বা গ্যালারি থেকে নিন, ছবিটি দেখে নিয়ে "ছবি বিশ্লেষণ করুন" বোতামে চাপুন। কয়েক সেকেন্ডেই ফলাফল চলে আসবে।',
      category: 'Detection',
      tags: ['scan', 'photo', 'camera', 'detect', 'স্ক্যান', 'ক্যামেরা', 'ছবি'],
    ),

    // ── FAQ 2 ────────────────────────────────────────────────────────────────
    FaqItem(
      id: 'faq_2',
      questionEn: 'Why is my plant disease not detected?',
      questionBn: 'আমার গাছের রোগ শনাক্ত হচ্ছে না কেন?',
      answerEn:
          'The photo might be blurry, too dark, or taken from too far away. Also, the crop or specific disease might not be among the five crops supported by the AI model. Try taking another crisp, well-lit photo focusing closely on the diseased symptoms. If the problem continues, ask a local agricultural extension officer.',
      answerBn:
          'ছবিটি ঝাপসা, অন্ধকার বা বেশি দূর থেকে তোলা হতে পারে। এছাড়া আক্রান্ত পাতাটি এআই মডেলের আওতাভুক্ত ৫টি ফসলের বাইরের ফসল বা বিরল রোগ হতে পারে। পর্যাপ্ত আলোতে লক্ষণগুলোর ওপর পরিষ্কার ফোকাস করে আবার ছবি তুলুন। সমস্যা সমাধান না হলে স্থানীয় উপসহকারী কৃষি কর্মকর্তার পরামর্শ নিন।',
      category: 'Detection',
      tags: ['not detected', 'blurry', 'error', 'শনাক্ত', 'ঝাপসা', 'ভুল'],
    ),

    // ── FAQ 3 ────────────────────────────────────────────────────────────────
    FaqItem(
      id: 'faq_3',
      questionEn: 'Is the AI result always correct?',
      questionBn: 'এআই-এর ফলাফল কি সবসময় শতভাগ সঠিক?',
      answerEn:
          'No. AI results are automated estimates based on visual training data and may sometimes be incorrect. Unusual symptoms, pests, or poor lighting can mislead the model. Check the plant carefully and consult an agricultural expert before making major chemical treatment decisions.',
      answerBn:
          'না। এআই ফলাফল পূর্ববর্তী হাজারো ছবির লক্ষণের ভিত্তিতে তৈরি একটি সম্ভাব্য পূর্বাভাস। কম আলো, ভিন্ন রোগ বা পোকার আক্রমণের কারণে ফলাফল ভুল হতে পারে। তাই বড় ধরনের রাসায়নিক বালাইনাশক ব্যবহারের আগে কৃষি বিশেষজ্ঞের পরামর্শ নেওয়া উচিত।',
      category: 'Accuracy',
      tags: ['correct', 'accuracy', 'reliable', 'সঠিক', 'নির্ভুল', 'নিশ্চয়তা'],
    ),

    // ── FAQ 4 ────────────────────────────────────────────────────────────────
    FaqItem(
      id: 'faq_4',
      questionEn: 'What does the confidence percentage mean?',
      questionBn: 'কনফিডেন্স শতাংশ কী নির্দেশ করে?',
      answerEn:
          'It indicates how strongly the AI model favors its displayed prediction compared with other possibilities. It is NOT the percentage of your crop that is damaged, and it is not a guarantee of 100% accuracy.',
      answerBn:
          'কনফিডেন্স শতকরা হার বোঝায় অন্যান্য সম্ভাব্য রোগের তুলনায় এই নির্দিষ্ট রোগটি সম্পর্কে এআই কতটা আস্থাশীল। এটি ফসলের ক্ষয়ক্ষতির শতকরা পরিমাণ নয় এবং চূড়ান্ত সত্যতার নিশ্চয়তা নয়।',
      category: 'Accuracy',
      tags: [
        'confidence',
        'percentage',
        'score',
        'কনফিডেন্স',
        'শতকরা',
        'আস্থা'
      ],
    ),

    // ── FAQ 5 ────────────────────────────────────────────────────────────────
    FaqItem(
      id: 'faq_5',
      questionEn: 'Can I use AgriCare AI without the internet?',
      questionBn: 'ইন্টারনেট ছাড়া কি এগ্রিকেয়ার এআই ব্যবহার করা যায়?',
      answerEn:
          'Yes! On-device AI diagnosis, prevention tips, and local history work 100% offline using the embedded MobileNetV2 model. You only need an internet connection to create an account, log in, back up scans to Supabase cloud storage, or submit user feedback.',
      answerBn:
          'হ্যাঁ! অন-ডিভাইস মোবাইলনেট-ভি২ মডেল থাকায় রোগ শনাক্তকরণ, সমাধান, প্রতিকার নির্দেশিকা ও লোকাল হিস্ট্রি পুরোপুরি ইন্টারনেট ছাড়াই চলে। শুধুমাত্র অ্যাকাউন্ট লগইন, ক্লাউড ব্যাকআপ সিঙ্ক এবং মতামত পাঠানোর জন্য ইন্টারনেট প্রয়োজন।',
      category: 'Offline',
      tags: [
        'offline',
        'internet',
        'wifi',
        'data',
        'অফলাইন',
        'ইন্টারনেট',
        'ডাটা'
      ],
    ),

    // ── FAQ 6 ────────────────────────────────────────────────────────────────
    FaqItem(
      id: 'faq_6',
      questionEn: 'Where can I see my previous scans?',
      questionBn: 'আমার পূর্ববর্তী স্ক্যানগুলো কোথায় দেখতে পাব?',
      answerEn:
          'Open "Detection History" from the bottom navigation or the home dashboard. There you can browse all your past plant diagnoses, view saved photos, and search or filter records by crop and date.',
      answerBn:
          'অ্যাপের নিচের নেভিগেশন বার অথবা হোম ড্যাশবোর্ড থেকে "স্ক্যান ইতিহাস" (Detection History) অপশনে যান। সেখানে আপনার পূর্ববর্তী সকল রোগ পরীক্ষার তালিকা, সংরক্ষিত ছবি ও ফলাফল দেখতে পাবেন।',
      category: 'Features',
      tags: ['history', 'previous', 'past scans', 'ইতিহাস', 'আগের স্ক্যান'],
    ),

    // ── FAQ 7 ────────────────────────────────────────────────────────────────
    FaqItem(
      id: 'faq_7',
      questionEn: 'How can I save a detection result?',
      questionBn: 'রোগ শনাক্তকরণের ফলাফল কীভাবে সংরক্ষণ করব?',
      answerEn:
          'After an AI scan finishes, review the diagnosis on Screen 16 and tap the "Save Scan" button at the bottom. Detection results are not saved automatically until you tap this button.',
      answerBn:
          'এআই পরীক্ষার পর ফলাফল স্ক্রিনে (Screen 16) নিচে থাকা "সংরক্ষণ করুন" (Save Scan) বোতামে চাপ দিন। এই বোতামে চাপ না দিলে ফলাফলটি ইতিহাসে স্বয়ংক্রিয়ভাবে সংরক্ষিত হবে না।',
      category: 'Features',
      tags: ['save', 'store', 'record', 'সংরক্ষণ', 'সেভ'],
    ),

    // ── FAQ 8 ────────────────────────────────────────────────────────────────
    FaqItem(
      id: 'faq_8',
      questionEn: 'Can I change the app language?',
      questionBn: 'অ্যাপের ভাষা কীভাবে পরিবর্তন করব?',
      answerEn:
          'Yes. Open Settings or Profile, tap "Language", select either English or বাংলা, and tap "Save Language". The entire application changes instantly and remembers your selection.',
      answerBn:
          'হ্যাঁ। সেটিংস বা প্রোফাইল থেকে "ভাষা" অপশনে যান, এরপর English বা বাংলা নির্বাচন করে সেভ করুন। সম্পূর্ণ অ্যাপটি সাথে সাথে আপনার পছন্দের ভাষায় পরিবর্তিত হবে।',
      category: 'Settings',
      tags: ['language', 'bangla', 'english', 'ভাষা', 'বাংলা', 'ইংরেজি'],
    ),

    // ── FAQ 9 ────────────────────────────────────────────────────────────────
    FaqItem(
      id: 'faq_9',
      questionEn: 'What should I do if the camera does not open?',
      questionBn: 'ক্যামেরা চালু না হলে কী করব?',
      answerEn:
          'Open your phone Settings > Apps > AgriCare AI > Permissions > Camera, and ensure permission is set to "Allow". Return to AgriCare AI and try again.',
      answerBn:
          'আপনার ফোনের সেটিংস > অ্যাপস > AgriCare AI > পারমিশন-এ যান এবং ক্যামেরা পারমিশন "Allow" বা চালু করুন। এরপর অ্যাপে ফিরে এসে আবার চেষ্টা করুন।',
      category: 'Troubleshooting',
      tags: ['camera', 'permission', 'black screen', 'ক্যামেরা', 'পারমিশন'],
    ),

    // ── FAQ 10 ───────────────────────────────────────────────────────────────
    FaqItem(
      id: 'faq_10',
      questionEn: 'How do I understand treatment recommendations?',
      questionBn: 'প্রতিকার ও চিকিৎসা পরামর্শ কীভাবে বুঝব?',
      answerEn:
          'AgriCare AI provides verified cultural management, organic biological remedies, and registered chemical controls suited for Bangladeshi agriculture. Always read approved pesticide labels, wear protective clothing, and follow recommended dilution ratios.',
      answerBn:
          'এগ্রিকেয়ার এআই-তে কৃষি গবেষণা ইনস্টিটিউট অনুমোদিত জৈব ও রাসায়নিক ব্যবস্থাপনা তুলে ধরা হয়। বালাইনাশক ব্যবহারের আগে প্যাকেটের নির্দেশিকা পড়ুন, নিরাপত্তা পোশাক পরিধান করুন এবং সঠিক মাত্রায় স্প্রে করুন।',
      category: 'Treatment',
      tags: [
        'treatment',
        'medicine',
        'pesticide',
        'প্রতিকার',
        'ঔষধ',
        'বালাইনাশক'
      ],
    ),

    // ── FAQ 11 ───────────────────────────────────────────────────────────────
    FaqItem(
      id: 'faq_11',
      questionEn: 'Can I scan any plant?',
      questionBn: 'আমি কি যেকোনো ফসলের পাতা স্ক্যান করতে পারব?',
      answerEn:
          'AgriCare AI is specifically trained for five key crops: Rice (ধান), Potato (আলু), Tomato (টমেটো), Mango (আম), and Jute (পাট). Scanning weeds, unsupported crops, or non-plant objects may produce unreliable predictions.',
      answerBn:
          'এগ্রিকেয়ার এআই বর্তমানে পাঁচটি প্রধান ফসলের জন্য প্রশিক্ষিত: ধান, আলু, টমেটো, আম এবং পাট। আগাছা বা অন্য কোনো অপ্রশিক্ষিত গাছের পাতা স্ক্যান করলে ভুল ফলাফল আসতে পারে।',
      category: 'Detection',
      tags: ['crop', 'supported', 'rice', 'potato', 'ফসল', 'ধান', 'আলু'],
    ),

    // ── FAQ 12 ───────────────────────────────────────────────────────────────
    FaqItem(
      id: 'faq_12',
      questionEn: 'How can I delete a previous scan?',
      questionBn: 'পূর্বের কোনো স্ক্যান রেকর্ড কীভাবে মুছে ফেলব?',
      answerEn:
          'Open Detection History, tap the specific scan record to view its details, and tap the red "Delete Record" button. Confirm in the dialog, and the record will be removed from your history.',
      answerBn:
          'স্ক্যান ইতিহাসে গিয়ে যে রেকর্ডটি মুছতে চান তাতে ট্যাপ করুন। এরপর বিস্তারিত পাতার নিচে লাল "রেকর্ড মুছুন" বাটনে চাপ দিয়ে নিশ্চিত করুন। রেকর্ডটি স্থায়ীভাবে মুছে যাবে।',
      category: 'Features',
      tags: ['delete', 'remove', 'history', 'মুছে ফেলা', 'ডিলিট'],
    ),
  ];
}
