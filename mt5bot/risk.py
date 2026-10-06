def lot_size(balance, risk_frac, sl_distance, tick_value, tick_size, vol_min, vol_max, vol_step):
    """Lot tel que la perte au SL = risk_frac * balance."""
    if sl_distance <= 0 or tick_size <= 0 or tick_value <= 0:
        return 0.0
    loss_per_lot = sl_distance / tick_size * tick_value
    lots = balance * risk_frac / loss_per_lot
    lots = int(round(lots / vol_step, 9)) * vol_step
    lots = round(min(lots, vol_max), 8)
    return lots if lots >= vol_min else 0.0


def daily_loss_hit(start_equity, equity, max_daily_loss):
    return start_equity > 0 and (start_equity - equity) / start_equity >= max_daily_loss
