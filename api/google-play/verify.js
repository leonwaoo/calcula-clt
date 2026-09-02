const { google } = require('googleapis');

const productId = 'calculaclt_pro_lifetime';
const packageName = process.env.GOOGLE_PLAY_PACKAGE_NAME || 'com.calculaclt.app';

function serviceAccount() {
  const value = process.env.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON;
  if (!value) throw new Error('GOOGLE_PLAY_SERVICE_ACCOUNT_JSON is not configured');
  return JSON.parse(value);
}

module.exports = async (request, response) => {
  if (request.method !== 'POST') {
    response.setHeader('Allow', 'POST');
    return response.status(405).json({ error: 'method_not_allowed' });
  }

  const { productId: requestedProduct, purchaseToken, source } = request.body || {};
  if (requestedProduct !== productId || !purchaseToken || source !== 'google_play') {
    return response.status(400).json({ active: false });
  }

  try {
    const auth = new google.auth.GoogleAuth({
      credentials: serviceAccount(),
      scopes: ['https://www.googleapis.com/auth/androidpublisher'],
    });
    const publisher = google.androidpublisher({ version: 'v3', auth });
    const result = await publisher.purchases.products.get({
      packageName,
      productId,
      token: purchaseToken,
    });

    // purchaseState 0 means a completed purchase. A non-consumable item remains
    // owned and can safely be restored on a new device.
    const active = result.data.purchaseState === 0;
    return response.status(200).json({ active });
  } catch (error) {
    console.error('Google Play purchase verification failed', error.message);
    return response.status(200).json({ active: false });
  }
};
