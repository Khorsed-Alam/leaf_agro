-- ====================================================================
-- AgriCare AI — Seed Catalog Data (Crops, Diseases, Recommendations)
-- Migration: 003_seed_catalog.sql
-- ====================================================================

-- Insert Crops
INSERT INTO public.crops (name_en, name_bn, description_en, description_bn, image_url)
VALUES
    ('Rice', 'ধান', 'Staple grain of Bangladesh, cultivated nationwide in Aus, Aman, and Boro seasons.', 'বাংলাদেশের প্রধান খাদ্যশস্য, আউশ, আমন ও বোরো মৌসুমে সারা দেশে উৎপাদিত হয়।', 'https://images.unsplash.com/photo-1536304993881-ff6e9eefa2a6'),
    ('Potato', 'আলু', 'High yield tuber crop heavily grown in Munshiganj, Bogura, and Rangpur regions.', 'মুন্সীগঞ্জ, বগুড়া এবং রংপুর অঞ্চলে ব্যাপকভাবে উৎপাদিত প্রধান কন্দজাতীয় ফসল।', 'https://images.unsplash.com/photo-1518977676601-b53f82aba655'),
    ('Tomato', 'টমেটো', 'Popular vegetable widely cultivated throughout winter and summer seasons.', 'শীত ও গ্রীষ্মকালীন মৌসুমে সারা দেশে ব্যাপকভাবে চাষকৃত জনপ্রিয় সবজি।', 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea'),
    ('Mango', 'আম', 'The King of Fruits, extensively grown in Rajshahi, Chapainawabganj, and Satkhira.', 'ফলের রাজা, রাজশাহী, চাঁপাইনবাবগঞ্জ ও সাতক্ষীরা অঞ্চলে প্রধান অর্থকরী ফল।', 'https://images.unsplash.com/photo-1553279768-865429fa0078'),
    ('Jute', 'পাট', 'The Golden Fibre of Bangladesh, crucial historical and commercial cash crop.', 'বাংলাদেশের সোনালী আঁশ, অন্যতম প্রধান ঐতিহ্যবাহী ও বাণিজ্যিক অর্থকরী ফসল।', 'https://images.unsplash.com/photo-1600681932179-c32278da47f9')
ON CONFLICT (name_en) DO NOTHING;

-- Insert Disease Catalog Records (exact class_name matching labels.json)
-- Rice Diseases
INSERT INTO public.disease_catalog (crop_id, class_name, disease_name_en, disease_name_bn, symptoms_en, symptoms_bn, causes_en, causes_bn, is_healthy)
SELECT id, 'Rice___Bacterial_leaf_blight', 'Bacterial Leaf Blight', 'ব্যাকটেরিয়াল লিফ ব্লাইট', 
    'Water-soaked lesions on leaf edges turning yellowish white and drying out.', 
    'পাতার কিনারায় পানিভেজা দাগ যা পরে হলুদ-সাদা হয়ে শুকিয়ে যায়।',
    'Xanthomonas oryzae pv. oryzae bacteria spread via irrigation water and high humidity.', 
    'অতিরিক্ত আর্দ্রতা ও সেচের পানির মাধ্যমে জ্যান্থোমোনাস ব্যাকটেরিয়ার বিস্তার।', false
FROM public.crops WHERE name_en = 'Rice'
ON CONFLICT (class_name) DO NOTHING;

INSERT INTO public.disease_catalog (crop_id, class_name, disease_name_en, disease_name_bn, symptoms_en, symptoms_bn, causes_en, causes_bn, is_healthy)
SELECT id, 'Rice___Brown_spot', 'Brown Spot', 'বাদামী দাগ রোগ', 
    'Small circular to oval dark brown spots on the foliage, often with gray center.', 
    'পাতায় ছোট গোলাকার বা ডিম্বাকৃতির গাঢ় বাদামী দাগ, মাঝখানে ধূসর বর্ণ।',
    'Bipolaris oryzae fungus, prevalent in nutrient-deficient and water-stressed soil.', 
    'মাটিতে পুষ্টিহীনতা ও খরার কারণে বাইপোলারিস ওরিজি ছত্রাকের আক্রমণ।', false
FROM public.crops WHERE name_en = 'Rice'
ON CONFLICT (class_name) DO NOTHING;

INSERT INTO public.disease_catalog (crop_id, class_name, disease_name_en, disease_name_bn, symptoms_en, symptoms_bn, causes_en, causes_bn, is_healthy)
SELECT id, 'Rice___healthy', 'Healthy Rice Leaf', 'সুস্থ ধান গাছ', 
    'Vibrant uniform green blade without visible spots or discolored margins.', 
    'পাতায় কোনো ক্ষতিকারক দাগ নেই, স্বাভাবিক সতেজ সবুজ বর্ণ।',
    'Optimal cultivation conditions and balanced soil nutrition.', 
    'সুষম সার প্রয়োগ ও সঠিক পরিচর্যার সুফল।', true
FROM public.crops WHERE name_en = 'Rice'
ON CONFLICT (class_name) DO NOTHING;

-- Potato Diseases
INSERT INTO public.disease_catalog (crop_id, class_name, disease_name_en, disease_name_bn, symptoms_en, symptoms_bn, causes_en, causes_bn, is_healthy)
SELECT id, 'Potato___Late_blight', 'Late Blight', 'নাবী ধসা রোগ', 
    'Dark water-soaked lesions on leaves turning black with white mold underneath.', 
    'পাতায় কালো পানিভেজা দাগ তৈরি হয় এবং পাতার নিচের অংশে সাদা ছত্রাক দেখা যায়।',
    'Phytophthora infestans oomycete in cool, cloudy, and humid weather.', 
    'ঘন কুয়াশা, স্যাঁতসেঁতে আবহাওয়া এবং ফাইটোপথোরা ছত্রাকের বিস্তার।', false
FROM public.crops WHERE name_en = 'Potato'
ON CONFLICT (class_name) DO NOTHING;

INSERT INTO public.disease_catalog (crop_id, class_name, disease_name_en, disease_name_bn, symptoms_en, symptoms_bn, causes_en, causes_bn, is_healthy)
SELECT id, 'Potato___healthy', 'Healthy Potato Leaf', 'সুস্থ আলু গাছ', 
    'Clean, robust green compound leaf foliage free of necrotic tissue.', 
    'সবুজ সতেজ পাতা, কোনো রোগ বা দাগমুক্ত অবস্থা।',
    'Good seed tuber quality and proper field management.', 
    'উন্নত বীজ ও সঠিক পানি নিষ্কাশন ব্যবস্থা।', true
FROM public.crops WHERE name_en = 'Potato'
ON CONFLICT (class_name) DO NOTHING;

-- Recommendations
INSERT INTO public.recommendations (disease_id, recommendation_type, title_en, title_bn, content_en, content_bn, is_verified)
SELECT id, 'treatment', 'Copper Oxychloride Spray', 'কপার অক্সিক্লোরাইড স্প্রে',
    'Apply Copper Oxychloride 50 WP @ 2.5g/L water every 7 days until spread halts.',
    'প্রতি লিটার পানিতে ২.৫ গ্রাম কপার অক্সিক্লোরাইড ৫০ ডব্লিউপি মিশিয়ে ৭ দিন পর পর স্প্রে করুন।', true
FROM public.disease_catalog WHERE class_name = 'Potato___Late_blight';

INSERT INTO public.recommendations (disease_id, recommendation_type, title_en, title_bn, content_en, content_bn, is_verified)
SELECT id, 'prevention', 'Certified Disease-Free Tubers', 'রোগমুক্ত প্রত্যয়িত বীজ ব্যবহার',
    'Always source certified disease-free seed tubers and ensure good soil drainage.',
    'সবসময় বিএডিসি বা বিশ্বস্ত উৎস থেকে রোগমুক্ত বীজ আলু সংগ্রহ করুন এবং জমিতে পানি জমতে দেবেন না।', true
FROM public.disease_catalog WHERE class_name = 'Potato___Late_blight';

