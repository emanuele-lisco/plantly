const admin = require("firebase-admin");

const serviceAccount = require("C:/Lavoro/Personal/firebase-keys/plantly-service-account.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function main() {
  const ownerUid = "kdh3XBTPajOl4qP0k8BCO3YCDyw1";
  const plantId = "1893_1780143038210381";
  const deviceId = "test_device_mandarin_orange_001";

  const deviceRef = db.collection("devices").doc(deviceId);

  const plantRef = db
    .collection("users")
    .doc(ownerUid)
    .collection("garden")
    .doc(plantId);

  await db.runTransaction(async (tx) => {
    tx.set(
      deviceRef,
      {
        id: deviceId,
        ownerUid: ownerUid,
        linkedUserPlantId: plantId,

        name: "Smart Pot Test",
        deviceCode: "PLANTLY-TEST-001",

        telemetry: {
          soilMoisturePercent: 48,
          lightLux: 3400,
          waterRemainingMl: 3200,
          waterRemainingPercent: 80,
          pumpActive: false,
          irrigationMode: "off",
          batteryPercent: -1,
          lastSeenAt: admin.firestore.FieldValue.serverTimestamp(),
        },

        config: {
          tankCapacityMl: 4000,
          pumpMlPerSecond: 20,
          cooldownSeconds: 1800,
          autoIrrigationEnabled: false,
          soilMoistureThreshold: 35,
          maxWaterMlPerCycle: 120,
          maxWaterMlPerDay: 350,
        },

        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    tx.set(
      plantRef,
      {
        deviceId: deviceId,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  });

  console.log("Device test creato e collegato correttamente.");
}

main().catch((error) => {
  console.error("Errore:", error);
  process.exit(1);
});