def consolidate_cart(cart)
  cart_hash = {}
  cart.each do | item |
    if cart_hash[item.keys[0]]
      cart_hash[item.keys[0]][:count] += 1
    else
      cart_hash[item.keys[0]] = {
        price: item.values[0][:price],
        clearance: item.values[0][:clearance],
        count: 1
      }
    end
  end
  cart_hash
end

def apply_coupons(cart, coupons)
  coupons.each do | coupon |
    if cart.has_key?(coupon[:item]) && cart[coupon[:item]][:count] >= coupon[:num]
      if cart.has_key?("#{coupon[:item]} W/COUPON")
        cart["#{coupon[:item]} W/COUPON"][:count] += coupon[:num]
      else
        cart["#{coupon[:item]} W/COUPON"] = {
          price: (coupon[:cost] / coupon[:num]),
          clearance: cart[coupon[:item]][:clearance],
          count: coupon[:num]
        }
      end
      cart[coupon[:item]][:count] -= coupon[:num]
    end
  end
  cart
end

def apply_clearance(cart)
  cart.each_pair do | key, value |
    if cart[key][:clearance]
      cart[key][:price] = (cart[key][:price] * 0.8).round(2)
    end
  end
  cart
end

def checkout(cart, coupons)
  consolidated_cart = consolidate_cart(cart)
  coupons_cart = apply_coupons(consolidated_cart, coupons)
  clearance_cart = apply_clearance(coupons_cart)

  total = clearance_cart.values.reduce(0) { | memo, item |
    memo += item[:price] * item[:count]
  }
  
  total > 100 ? (total * 0.9).round(2) : total
end
