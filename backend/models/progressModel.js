import { query } from "../config/db.js";

export async function getTotalCarbon(userId) {
  const rows = await query(
    "SELECT COALESCE(SUM(carbon_value), 0) AS total FROM user_activity_logs WHERE user_id = :userId",
    { userId }
  );
  return Number(rows[0]?.total || 0);
}

export async function getEcoPoints(userId) {
  const rows = await query(
    "SELECT COALESCE(SUM(GREATEST(carbon_value, 0)), 0) AS total FROM user_activity_logs WHERE user_id = :userId",
    { userId }
  );
  return Number(rows[0]?.total || 0);
}

export async function getTodayCarbon(userId) {
  const rows = await query(
    `SELECT COALESCE(SUM(carbon_value), 0) AS total
     FROM user_activity_logs
     WHERE user_id = :userId
       AND DATE(CONVERT_TZ(created_at, '+00:00', '+07:00')) = DATE(CONVERT_TZ(UTC_TIMESTAMP(), '+00:00', '+07:00'))`,
    { userId }
  );
  return Number(rows[0]?.total || 0);
}

export async function getJourneyPoints(userId) {
  const todayCarbon = await getTodayCarbon(userId);
  const quests = [
    { requirement: 50, reward: 25 },
    { requirement: 150, reward: 25 },
    { requirement: 300, reward: 25 },
    { requirement: 500, reward: 25 }
  ];
  return quests.reduce((sum, quest) => (
    todayCarbon >= quest.requirement ? sum + quest.reward : sum
  ), 0);
}

export async function syncUserAwards(userId) {
  const totalCarbon = await getTotalCarbon(userId);
  const ecoPoints = await getEcoPoints(userId);
  const todayCarbon = await getTodayCarbon(userId);
  const journeyPoints = await getJourneyPoints(userId);

  await query(
    `INSERT IGNORE INTO user_badges (user_id, badge_id)
     SELECT :userId, id FROM badges
     WHERE requirement_type IN ('carbon_points', 'carbon_total', 'eco_points') AND requirement_value <= :totalCarbon`,
    { userId, totalCarbon }
  );

  const milestones = await query("SELECT * FROM milestones ORDER BY target_value", {});
  for (const milestone of milestones) {
    const completed = totalCarbon >= Number(milestone.target_value);
    await query(
      `INSERT INTO user_milestones
       (user_id, milestone_id, progress_value, is_completed, completed_at)
       VALUES (:userId, :milestoneId, :progressValue, :isCompleted, :completedAt)
       ON DUPLICATE KEY UPDATE
         progress_value = VALUES(progress_value),
         is_completed = VALUES(is_completed),
         completed_at = IF(completed_at IS NULL AND VALUES(is_completed) = 1, VALUES(completed_at), completed_at)`,
      {
        userId,
        milestoneId: milestone.id,
        progressValue: totalCarbon,
        isCompleted: completed ? 1 : 0,
        completedAt: completed ? new Date() : null
      }
    );
  }

  return { totalCarbon, ecoPoints, todayCarbon, journeyPoints };
}
