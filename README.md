# WhatsApp + Rails + Pi Agent POC

Proof of concept for using WhatsApp Business Cloud API as a customer-facing chat surface, a Rails API as the source of customer/order data, and Pi as the reasoning layer that turns a WhatsApp message into a useful reply.

## What this proves

```text
WhatsApp user
  -> Meta WhatsApp webhook
  -> Rails API (/webhooks/whatsapp)
  -> Rails customer/order lookup
  -> Pi-compatible agent adapter
  -> WhatsApp reply
```

The app includes a deterministic agent mode so the full Rails + WhatsApp webhook flow is testable without real WhatsApp or model credentials. Switching `PI_AGENT_MODE=pi` invokes the local `pi` CLI with a locked-down customer harness.

## App endpoints

| Endpoint | Purpose |
|---|---|
| `GET /up` | Rails health check |
| `GET /webhooks/whatsapp` | Meta webhook verification challenge |
| `POST /webhooks/whatsapp` | Meta inbound WhatsApp messages |
| `POST /api/v1/agent_messages` | Local/staging test endpoint that skips Meta and returns the agent reply JSON |

## Local setup

```bash
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/rails test
bin/rails server
```

Seed data creates one test customer. Override the phone number before seeding if you want it to match your WhatsApp sender:

```bash
SEED_CUSTOMER_PHONE=+15551234567 bin/rails db:seed
```

## Test without WhatsApp

```bash
curl -s http://localhost:3000/api/v1/agent_messages \
  -H 'Content-Type: application/json' \
  -d '{"from":"+15551234567","text":"Where is my order?"}' | jq
```

Expected reply includes the seeded order `POC-1001`.

## Test the WhatsApp webhook locally

Webhook verification:

```bash
curl -i 'http://localhost:3000/webhooks/whatsapp?hub.mode=subscribe&hub.verify_token=dev-verify-token&hub.challenge=hello'
```

Inbound message simulation:

```bash
curl -s http://localhost:3000/webhooks/whatsapp \
  -H 'Content-Type: application/json' \
  -d @docs/sample_whatsapp_payload.json | jq
```

By default `WHATSAPP_SEND_MODE=log`, so replies are logged instead of sent to Meta.

## Staging / Meta WhatsApp setup

1. Deploy this Rails app to a public HTTPS URL.
2. Set staging environment variables:

   | Variable | Required | Purpose |
   |---|---:|---|
   | `WHATSAPP_WEBHOOK_VERIFY_TOKEN` | yes | Token you enter in Meta's webhook verification UI |
   | `WHATSAPP_SEND_MODE` | yes | `log` for dry-run, `cloud_api` to send WhatsApp replies |
   | `WHATSAPP_GRAPH_VERSION` | no | Defaults to `v23.0` |
   | `WHATSAPP_PHONE_NUMBER_ID` | for `cloud_api` | Meta phone number ID |
   | `WHATSAPP_ACCESS_TOKEN` | for `cloud_api` | Meta Cloud API token |
   | `WHATSAPP_ALLOWED_SENDERS` | recommended | Comma-separated E.164 numbers allowed to use staging |
   | `PI_AGENT_MODE` | yes | `deterministic` or `pi` |
   | `PI_COMMAND` | for `pi` mode | Defaults to `pi` |
   | `PI_PROVIDER` | optional | Passed to `pi --provider`, e.g. `openai` |
   | `PI_MODEL` | optional | Passed to `pi --model`, e.g. `local-gemma` |
   | `PI_AGENT_TIMEOUT_SECONDS` | optional | Defaults to 30 |

3. In Meta for Developers, configure the WhatsApp webhook callback URL:

   ```text
   https://YOUR-STAGING-HOST/webhooks/whatsapp
   ```

4. Subscribe to WhatsApp `messages` webhook events.
5. While testing, set `WHATSAPP_ALLOWED_SENDERS` to your own WhatsApp number so only you can use the staging bot.
6. Seed staging with a matching customer:

   ```bash
   SEED_CUSTOMER_PHONE=+YOUR_NUMBER bin/rails db:seed
   ```

## Pi customer harness

The external customer harness lives at:

```text
pi_harnesses/customer_whatsapp/APPEND_SYSTEM.md
```

It instructs Pi to:

- speak as a WhatsApp customer assistant
- use only Rails-provided JSON context for customer-specific facts
- avoid exposing internal implementation details
- refuse secrets/payment details
- offer human escalation when the Rails data is insufficient

To use the real Pi CLI adapter locally/staging:

```bash
PI_AGENT_MODE=pi PI_COMMAND=pi bin/rails server
```

The POC intentionally invokes Pi with:

```text
--no-tools --no-context-files --no-skills --no-prompt-templates
```

That keeps the external customer agent separate from internal engineering harnesses. The Rails app supplies the allowed customer/order data as JSON.

## Security notes for a real pilot

- Keep `WHATSAPP_ALLOWED_SENDERS` enabled for personal staging.
- Do not commit real `.env` files, Meta tokens, Rails credentials, or Pi credentials.
- Add Meta request signature verification before production use.
- Store inbound/outbound messages in a database if you need audit trails or retries.
- Add idempotency using WhatsApp message IDs before enabling retries.
- Replace the deterministic agent with Pi only after you have model credentials and cost limits configured.
