# frozen_string_literal: true

# Static Rails review fixture. Do not load as application code.
# Rails 8.1, PostgreSQL. An account has many orders; an order belongs to a
# customer and has many line_items. There are no default includes, counter
# caches, or query caches across requests. page is validated upstream as an
# integer >= 0. Several existing orders share the same created_at value.
# The endpoint promises stable page membership on an unchanged data set.

class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    orders = current_account.orders.order(created_at: :desc).limit(50).offset(params[:page] * 50)
    render json: orders.map { |order|
      { id: order.id, customer: order.customer.name, item_count: order.line_items.count }
    }
  end
end
