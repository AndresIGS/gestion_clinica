// Supabase Edge Function: send-push-notification
// ============================================================
// Esta función envía una notificación push mediante Firebase Cloud
// Messaging (FCM) a los dispositivos registrados de un usuario.
//
// Requisitos:
//   1. Tener un proyecto de Firebase configurado.
//   2. Tener la clave privada de Firebase Admin SDK (serviceAccountKey.json).
//   3. Configurar el secreto FCM_SERVICE_ACCOUNT en Supabase.
//
// Uso desde un trigger SQL:
//   SELECT net.http_post(
//     url := 'https://<tu-proyecto>.supabase.co/functions/v1/send-push-notification',
//     headers := '{"Authorization": "Bearer <service-role-key>", "Content-Type": "application/json"}'::jsonb,
//     body := '{"id_usuario_destino": "...", "titulo": "...", "cuerpo": "...", "data": {...}}'::jsonb
//   );
// ============================================================

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { JWT } from 'https://esm.sh/google-auth-library@8';

interface NotificationPayload {
  id_usuario_destino: string;
  titulo: string;
  cuerpo: string;
  data?: Record<string, string>;
}

serve(async (req) => {
  try {
    // Verifica autorización básica
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response('Unauthorized', { status: 401 });
    }

    const payload: NotificationPayload = await req.json();
    const { id_usuario_destino, titulo, cuerpo, data = {} } = payload;

    if (!id_usuario_destino || !titulo || !cuerpo) {
      return new Response('Faltan campos requeridos', { status: 400 });
    }

    // Cliente de Supabase con service role key
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // Obtiene los tokens FCM del usuario destino
    const { data: dispositivos, error } = await supabaseAdmin
      .from('dispositivos')
      .select('fcm_token')
      .eq('id_usuario', id_usuario_destino);

    if (error) throw error;
    if (!dispositivos || dispositivos.length === 0) {
      return new Response('Usuario sin dispositivos registrados', { status: 200 });
    }

    // Obtiene access token de Firebase
    const accessToken = await getFirebaseAccessToken();

    const resultados = [];

    for (const dispositivo of dispositivos) {
      const fcmToken = dispositivo.fcm_token;

      const message = {
        message: {
          token: fcmToken,
          notification: {
            title: titulo,
            body: cuerpo,
          },
          data: data,
          android: {
            notification: {
              channel_id: 'citas_channel',
              priority: 'high',
            },
          },
          apns: {
            payload: {
              aps: {
                sound: 'default',
              },
            },
          },
        },
      };

      const response = await fetch(
        `https://fcm.googleapis.com/v1/projects/${Deno.env.get('FCM_PROJECT_ID')}/messages:send`,
        {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${accessToken}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(message),
        }
      );

      resultados.push({ token: fcmToken, status: response.status });
    }

    return new Response(JSON.stringify({ enviados: resultados }), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 500,
    });
  }
});

async function getFirebaseAccessToken(): Promise<string> {
  const serviceAccount = JSON.parse(Deno.env.get('FCM_SERVICE_ACCOUNT') ?? '{}');

  const jwtClient = new JWT({
    email: serviceAccount.client_email,
    key: serviceAccount.private_key,
    scopes: ['https://www.googleapis.com/auth/cloud-platform'],
  });

  const tokens = await jwtClient.authorize();
  return tokens.access_token ?? '';
}
