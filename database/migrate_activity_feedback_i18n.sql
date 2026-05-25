USE carbon_go;

SET @sql = IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'activities' AND COLUMN_NAME = 'name_en') = 0,
  'ALTER TABLE activities ADD COLUMN name_en VARCHAR(180) NULL AFTER name',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'activities' AND COLUMN_NAME = 'name_id') = 0,
  'ALTER TABLE activities ADD COLUMN name_id VARCHAR(180) NULL AFTER name_en',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'activities' AND COLUMN_NAME = 'feedback_en') = 0,
  'ALTER TABLE activities ADD COLUMN feedback_en TEXT NULL AFTER carbon_value',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'activities' AND COLUMN_NAME = 'feedback_id') = 0,
  'ALTER TABLE activities ADD COLUMN feedback_id TEXT NULL AFTER feedback_en',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE activities
SET name_en = COALESCE(name_en, name),
    name_id = COALESCE(name_id, name),
    feedback_en = COALESCE(feedback_en, ''),
    feedback_id = COALESCE(feedback_id, '');

ALTER TABLE activities
  MODIFY name_en VARCHAR(180) NOT NULL,
  MODIFY name_id VARCHAR(180) NOT NULL,
  MODIFY feedback_en TEXT NOT NULL,
  MODIFY feedback_id TEXT NOT NULL;

INSERT INTO activities (name, name_en, name_id, category, carbon_value, feedback_en, feedback_id, is_default) VALUES
('Walk / Bicycle', 'Walk / Bicycle', 'Jalan Kaki / Sepeda', 'transportation', 5, '🚶‍♂️ Amazing! Zero-carbon commuting sets a great example.', '🚶‍♂️ Luar biasa! Komuter nol karbon memberi contoh yang baik.', 1),
('Personal electric vehicle', 'Personal electric vehicle', 'Kendaraan listrik pribadi', 'transportation', 4, '🔋 Great choice! EVs reduce emissions significantly.', '🔋 Pilihan bagus! EV mengurangi emisi secara signifikan.', 1),
('Public transport / Carpool / Ride-sharing', 'Public transport / Carpool / Ride-sharing', 'Transportasi umum / Carpool / Berbagi tumpangan', 'transportation', 3, '🚌 Excellent! Shared transport cuts carbon per person.', '🚌 Bagus! Transportasi bersama mengurangi karbon per orang.', 1),
('Dropped off with more than 2 people', 'Dropped off with more than 2 people', 'Di antar dengan lebih dari 2 orang', 'transportation', 2, '👥 Carpooling helps — try walking for short distances.', '👥 Carpool membantu — coba jalan kaki untuk jarak dekat.', 1),
('Short distance gasoline vehicle', 'Short distance gasoline vehicle', 'Kendaraan bensin jarak pendek', 'transportation', 1, '🛵 Consider biking for nearby trips.', '🛵 Pertimbangkan bersepeda untuk perjalanan dekat.', 1),
('Neutral / No special activity', 'Neutral / No special activity', 'Netral / Tidak ada aktivitas khusus', 'transportation', 0, 'Neutral choice. Every small action counts.', 'Pilihan netral. Setiap tindakan kecil berarti.', 1),
('Short ride online taxi', 'Short ride online taxi', 'Taksi online jarak pendek', 'transportation', -1, 'Apps increase emissions — try public transport.', 'Aplikasi meningkatkan emisi — coba transportasi umum.', 1),
('Long ride online taxi', 'Long ride online taxi', 'Taksi online jarak jauh', 'transportation', -2, 'Long solo rides = higher carbon.', 'Perjalanan solo jarak jauh = karbon lebih tinggi.', 1),
('Gasoline motorcycle', 'Gasoline motorcycle', 'Sepeda motor bensin', 'transportation', -3, 'Motorcycles emit less than cars but still pollute.', 'Motor mengeluarkan emisi lebih sedikit dari mobil tetapi tetap polusi.', 1),
('Private gasoline car', 'Private gasoline car', 'Mobil bensin pribadi', 'transportation', -4, '🚗 Solo car trips are carbon-heavy. Try carpooling.', '🚗 Perjalanan mobil solo berat karbon. Coba carpool.', 1),
('Intensive gasoline vehicle (>2 trips/day)', 'Intensive gasoline vehicle (>2 trips/day)', 'Kendaraan bensin intensif (>2 perjalanan/hari)', 'transportation', -5, '⚠️ High emissions! Combine trips or walk.', '⚠️ Emisi tinggi! Gabungkan perjalanan atau jalan kaki.', 1),
('Consistently saved energy all day', 'Consistently saved energy all day', 'Menghemat energi sepanjang hari', 'energy', 5, '💡 Energy champion! You inspire others.', '💡 Juara energi! Kamu menginspirasi orang lain.', 1),
('No AC/Cooler, used natural ventilation', 'No AC/Cooler, used natural ventilation', 'Tidak pakai AC/Pendingin, pakai ventilasi alami', 'energy', 4, 'Natural cooling saves huge energy.', 'Pendinginan alami menghemat banyak energi.', 1),
('No lift for ≤2 floors', 'No lift for ≤2 floors', 'Tidak pakai lift untuk ≤2 lantai', 'energy', 3, 'Stairs are healthy and green!', 'Tangga itu sehat dan hijau!', 1),
('Turned off cooler/fan before leaving', 'Turned off cooler/fan before leaving', 'Matikan pendingin/kipas sebelum pergi', 'energy', 2, 'Small habit, big impact.', 'Kebiasaan kecil, dampak besar.', 1),
('Turned off lights/devices after use', 'Turned off lights/devices after use', 'Matikan lampu/perangkat setelah pakai', 'energy', 1, 'Good! Keep it consistent.', 'Bagus! Tetap konsisten.', 1),
('Normal energy use', 'Normal energy use', 'Penggunaan energi normal', 'energy', 0, 'Neutral — try one green action tomorrow.', 'Netral — coba satu aksi hijau besok.', 1),
('Excessive gadget use', 'Excessive gadget use', 'Penggunaan gadget berlebihan', 'energy', -1, 'Reduce screen time to save energy.', 'Kurangi waktu layar untuk hemat energi.', 1),
('Left electronics on', 'Left electronics on', 'Meninggalkan elektronik menyala', 'energy', -2, 'Unplug to avoid vampire power.', 'Cabut untuk menghindari daya vampir.', 1),
('Used lift for 1 floor', 'Used lift for 1 floor', 'Pakai lift untuk 1 lantai', 'energy', -3, 'Take stairs next time!', 'Pakai tangga lain kali!', 1),
('AC used >6 hours', 'AC used >6 hours', 'AC digunakan >6 jam', 'energy', -4, 'Set thermostat 24°C + fan.', 'Atur termostat 24°C + kipas.', 1),
('Wasted energy consistently all day', 'Wasted energy consistently all day', 'Boros energi sepanjang hari', 'energy', -5, 'High waste! Turn off unused devices.', 'Pemborosan tinggi! Matikan perangkat yang tidak terpakai.', 1),
('Zero plastic waste produced', 'Zero plastic waste produced', 'Tidak menghasilkan sampah plastik', 'consumption', 5, '🌟 Zero waste hero! Inspiring.', '🌟 Pahlawan tanpa sampah! Menginspirasi.', 1),
('Brought full eco-friendly kit', 'Brought full eco-friendly kit', 'Membawa perlengkapan ramah lingkungan lengkap', 'consumption', 4, 'Reusable bottles/bags = perfect.', 'Botol/tas pakai ulang = sempurna.', 1),
('Brought homemade lunch', 'Brought homemade lunch', 'Membawa bekal makan siang', 'consumption', 3, 'Home meals avoid packaging.', 'Makanan rumahan menghindari kemasan.', 1),
('Brought own tumbler', 'Brought own tumbler', 'Membawa tumbler sendiri', 'consumption', 2, 'Refillable = less plastic.', 'Dapat diisi ulang = lebih sedikit plastik.', 1),
('Finished food with no leftovers', 'Finished food with no leftovers', 'Menghabiskan makanan tanpa sisa', 'consumption', 1, 'No waste = responsible.', 'Tanpa sampah = bertanggung jawab.', 1),
('Normal consumption', 'Normal consumption', 'Konsumsi normal', 'consumption', 0, 'Neutral — aim to reduce plastic.', 'Netral — bertujuan mengurangi plastik.', 1),
('Bought plastic bottled water', 'Bought plastic bottled water', 'Membeli air kemasan plastik', 'consumption', -1, 'Carry a reusable bottle!', 'Bawa botol pakai ulang!', 1),
('Used single-use plastic', 'Used single-use plastic', 'Menggunakan plastik sekali pakai', 'consumption', -2, 'Avoid straws/bags, bring own.', 'Hindari sedotan/tas, bawa sendiri.', 1),
('Ordered food in plastic packaging', 'Ordered food in plastic packaging', 'Memesan makanan dalam kemasan plastik', 'consumption', -3, 'Takeout creates waste. Dine-in or cook.', 'Bawa pulang menciptakan sampah. Makan di tempat atau masak.', 1),
('Generated lots of plastic waste', 'Generated lots of plastic waste', 'Menghasilkan banyak sampah plastik', 'consumption', -4, 'High plastic footprint. Reduce now.', 'Jejak plastik tinggi. Kurangi sekarang.', 1),
('Used styrofoam', 'Used styrofoam', 'Menggunakan styrofoam', 'consumption', -5, 'Styrofoam is terrible. Avoid completely!', 'Styrofoam sangat buruk. Hindari sepenuhnya!', 1),
('Recycled waste into useful items', 'Recycled waste into useful items', 'Mendaur ulang sampah menjadi barang berguna', 'waste', 5, '♻️ Upcycling genius!', '♻️ Jenius daur ulang!', 1),
('Reminded others to dispose properly', 'Reminded others to dispose properly', 'Mengingatkan orang lain untuk membuang dengan benar', 'waste', 4, 'Leadership for the planet!', 'Kepemimpinan untuk planet!', 1),
('Separated waste by type', 'Separated waste by type', 'Memisahkan sampah berdasarkan jenis', 'waste', 3, 'Great sorting habit!', 'Kebiasaan memilah yang bagus!', 1),
('Reused items still usable', 'Reused items still usable', 'Menggunakan kembali barang yang masih bisa dipakai', 'waste', 2, 'Reuse extends product life.', 'Penggunaan ulang memperpanjang umur produk.', 1),
('Threw trash in bin', 'Threw trash in bin', 'Membuang sampah ke tempat sampah', 'waste', 1, 'Basic but essential.', 'Dasar tapi penting.', 1),
('No special waste action', 'No special waste action', 'Tidak ada tindakan sampah khusus', 'waste', 0, 'Neutral — try sorting tomorrow.', 'Netral — coba memilah besok.', 1),
('Left trash scattered without action', 'Left trash scattered without action', 'Meninggalkan sampah berserakan tanpa tindakan', 'waste', -1, 'Pick it up! Every piece matters.', 'Ambil! Setiap potongan berarti.', 1),
('Littered improperly', 'Littered improperly', 'Membuang sampah sembarangan', 'waste', -2, 'Never litter. Use bins.', 'Jangan pernah buang sampah sembarangan. Pakai tempat sampah.', 1),
('Accumulated waste without management', 'Accumulated waste without management', 'Menumpuk sampah tanpa pengelolaan', 'waste', -3, 'Bad habit — start recycling.', 'Kebiasaan buruk — mulai daur ulang.', 1),
('Dumped waste into drains / buried trash', 'Dumped waste into drains / buried trash', 'Membuang sampah ke saluran air/mengubur sampah', 'waste', -4, 'Pollutes water/soil. Use proper disposal.', 'Mencemari air/tanah. Gunakan pembuangan yang tepat.', 1),
('Burned trash', 'Burned trash', 'Membakar sampah', 'waste', -5, '🔥 Burning releases toxins. Stop immediately!', '🔥 Membakar melepaskan racun. Hentikan segera!', 1),
('Consistently saved water', 'Consistently saved water', 'Menghemat air secara konsisten', 'environment', 5, '💧 Water saver = planet saver.', '💧 Penghemat air = penyelamat planet.', 1),
('Made a mini garden at home', 'Made a mini garden at home', 'Membuat kebun mini di rumah', 'environment', 4, '🌱 Gardening boosts biodiversity.', '🌱 Berkebun meningkatkan keanekaragaman hayati.', 1),
('Planted or cared for plants', 'Planted or cared for plants', 'Menanam atau merawat tanaman', 'environment', 3, 'Plants absorb CO₂!', 'Tanaman menyerap CO₂!', 1),
('Used water sparingly', 'Used water sparingly', 'Menggunakan air secukupnya', 'environment', 2, 'Smart water use saves energy too.', 'Penggunaan air cerdas menghemat energi juga.', 1),
('Cleaned green spaces nearby', 'Cleaned green spaces nearby', 'Membersihkan ruang hijau di sekitar', 'environment', 1, 'Community care = heroic.', 'Peduli komunitas = heroik.', 1),
('No special environmental action', 'No special environmental action', 'Tidak ada tindakan lingkungan khusus', 'environment', 0, 'Neutral — try planting a small seed.', 'Netral — coba menanam benih kecil.', 1),
('Let water run unused', 'Let water run unused', 'Membiarkan air mengalir tidak terpakai', 'environment', -1, 'Turn off tap while brushing.', 'Matikan keran saat menyikat gigi.', 1),
('Excessive water use', 'Excessive water use', 'Penggunaan air berlebihan', 'environment', -2, 'Long showers = waste.', 'Mandi lama = pemborosan.', 1),
('Littered green areas', 'Littered green areas', 'Membuang sampah di area hijau', 'environment', -3, 'Keep nature clean!', 'Jaga kebersihan alam!', 1),
('Damaged plants or green areas', 'Damaged plants or green areas', 'Merusak tanaman atau area hijau', 'environment', -4, 'Respect nature — don''t harm.', 'Hormati alam — jangan merusak.', 1),
('Let plants die / neglected', 'Let plants die / neglected', 'Membiarkan tanaman mati / terabaikan', 'environment', -5, 'Water plants! Every leaf matters.', 'Siram tanaman! Setiap daun berarti.', 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  name_en = VALUES(name_en),
  name_id = VALUES(name_id),
  carbon_value = VALUES(carbon_value),
  feedback_en = VALUES(feedback_en),
  feedback_id = VALUES(feedback_id),
  is_default = VALUES(is_default);
