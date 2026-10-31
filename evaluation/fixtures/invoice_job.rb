# frozen_string_literal: true

# Static Rails review fixture. Do not load as application code.
# Rails 8.1, PostgreSQL, an at-least-once queue. Invoice IDs are server-selected.
# PaymentGateway.charge accepts an optional idempotency_key, but without one
# every call can create a new charge. A timeout may occur after a charge was
# accepted. There are no other locks, uniqueness constraints, rescue handlers,
# or idempotency mechanisms. A database write may fail after a charge succeeds.

class ChargeInvoiceJob < ApplicationJob
  retry_on PaymentGateway::Timeout, wait: 5.seconds, attempts: 3

  def perform(invoice_id)
    invoice = Invoice.find(invoice_id)
    return if invoice.paid?

    charge = PaymentGateway.charge(customer: invoice.customer_token, cents: invoice.total_cents)
    invoice.update!(paid_at: Time.current, gateway_charge_id: charge.id)
  rescue PaymentGateway::Timeout => error
    Rails.logger.warn("Payment gateway timeout: #{error.class}")
  end
end
