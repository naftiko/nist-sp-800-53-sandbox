#!/usr/bin/env python3
"""
poam-dashboard.py — Generate a POA&M dashboard from API data.

Usage:
    python3 poam-dashboard.py < poam-list.json

Input: POA&M list response JSON from the API (the 'items' array).
Output: Dashboard with status breakdown, overdue tracking, and budget summary.
"""

import json
import sys
from collections import Counter
from datetime import datetime, timezone

STATUS_ICONS = {
    "open": "📋",
    "in_progress": "🔄",
    "completed": "✅",
    "accepted_risk": "⚖️",
    "cancelled": "❌",
}

RISK_ICONS = {
    "critical": "🔴",
    "high": "🟠",
    "moderate": "🟡",
    "low": "🟢",
}

RISK_SEVERITY = {"critical": 4, "high": 3, "moderate": 2, "low": 1}


def parse_date(s):
    """Parse ISO datetime string."""
    if not s:
        return None
    try:
        return datetime.fromisoformat(s.replace("Z", "+00:00"))
    except (ValueError, TypeError):
        return None


def main():
    data = json.load(sys.stdin)

    # Handle both { items: [...] } and raw array
    if isinstance(data, dict):
        items = data.get("items", [])
    elif isinstance(data, list):
        items = data
    else:
        print("Invalid input format.", file=sys.stderr)
        sys.exit(1)

    if not items:
        print("No POA&M items found.", file=sys.stderr)
        sys.exit(1)

    now = datetime.now(timezone.utc)

    # ── Status breakdown ──
    status_counts = Counter(item.get("status", "unknown") for item in items)
    risk_counts = Counter(item.get("riskLevel", "unknown") for item in items)

    # ── Overdue items ──
    overdue = []
    for item in items:
        if item.get("status") in ("open", "in_progress"):
            sched = parse_date(item.get("scheduledCompletionDate"))
            if sched and sched < now:
                days_over = (now - sched).days
                overdue.append({**item, "daysOverdue": days_over})

    overdue.sort(key=lambda x: x["daysOverdue"], reverse=True)

    # ── Budget ──
    total_budget = sum(item.get("estimatedCostUsd", 0) for item in items)
    completed_cost = sum(
        item.get("estimatedCostUsd", 0)
        for item in items
        if item.get("status") in ("completed", "accepted_risk")
    )
    remaining_cost = total_budget - completed_cost

    # ── Print dashboard ──
    print("=" * 70)
    print("  POA&M DASHBOARD")
    print("=" * 70)
    print(f"  Total Items: {len(items)}")
    print()

    # Status
    print("── Status Breakdown ──")
    for status in ["open", "in_progress", "completed", "accepted_risk", "cancelled"]:
        count = status_counts.get(status, 0)
        icon = STATUS_ICONS.get(status, "?")
        bar = "█" * count
        print(f"  {icon} {status:<16} {count:>3}  {bar}")
    print()

    # Risk
    print("── Risk Level Breakdown ──")
    for level in ["critical", "high", "moderate", "low"]:
        count = risk_counts.get(level, 0)
        icon = RISK_ICONS.get(level, "⚪")
        bar = "█" * count
        print(f"  {icon} {level:<10} {count:>3}  {bar}")
    print()

    # Overdue
    if overdue:
        print(f"── ⚠️  Overdue Items ({len(overdue)}) ──")
        print(f"  {'Control':<10} {'Risk':<10} {'Days Over':>9}  Weakness")
        print(f"  {'─'*10} {'─'*10} {'─'*9}  {'─'*38}")
        for item in overdue[:10]:
            ctrl = item.get("controlId", "?")
            risk = item.get("riskLevel", "?")
            days = item.get("daysOverdue", 0)
            weak = (item.get("weaknessDescription", "") or "")[:38]
            print(f"  {ctrl:<10} {risk:<10} {days:>9}  {weak}")
        print()
    else:
        print("── ✅ No Overdue Items ──")
        print()

    # Budget
    print("── Budget Summary ──")
    print(f"  Total Estimated   : ${total_budget:>12,}")
    print(f"  Completed/Accepted: ${completed_cost:>12,}")
    print(f"  Remaining         : ${remaining_cost:>12,}")
    print()

    # Top 5 open risks
    open_items = [
        item for item in items if item.get("status") in ("open", "in_progress")
    ]
    open_items.sort(
        key=lambda x: RISK_SEVERITY.get(x.get("riskLevel", "low"), 0),
        reverse=True,
    )
    top5 = open_items[:5]

    if top5:
        print("── Top 5 Open Risks ──")
        print(f"  {'#':>2} {'Control':<10} {'Risk':<10} {'Cost':>10} {'Due Date':<12} Milestone")
        print(f"  {'─'*2} {'─'*10} {'─'*10} {'─'*10} {'─'*12} {'─'*30}")
        for i, item in enumerate(top5, 1):
            ctrl = item.get("controlId", "?")
            risk = item.get("riskLevel", "?")
            cost = item.get("estimatedCostUsd", 0)
            due = (item.get("scheduledCompletionDate", "") or "")[:10]
            mile = (item.get("milestone", "") or "")[:30]
            print(f"  {i:>2} {ctrl:<10} {risk:<10} ${cost:>9,} {due:<12} {mile}")
        print()

    print("=" * 70)

    # JSON
    summary = {
        "totalItems": len(items),
        "statusBreakdown": dict(status_counts),
        "riskBreakdown": dict(risk_counts),
        "overdueCount": len(overdue),
        "budget": {
            "total": total_budget,
            "completed": completed_cost,
            "remaining": remaining_cost,
        },
    }
    print(f"\nJSON Summary:\n{json.dumps(summary, indent=2)}")


if __name__ == "__main__":
    main()
