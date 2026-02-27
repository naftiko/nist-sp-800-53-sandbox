#!/usr/bin/env python3
"""
findings-analyzer.py — Analyze assessment findings and produce SAR statistics.

Usage:
    python3 findings-analyzer.py < assessment.json

Input: Full assessment response JSON from the API.
Output: SAR summary tables and risk analysis.
"""

import json
import sys
from collections import defaultdict, Counter

RISK_SEVERITY = {"critical": 4, "high": 3, "moderate": 2, "low": 1}
RISK_ICONS = {
    "critical": "🔴",
    "high": "🟠",
    "moderate": "🟡",
    "low": "🟢",
}


def main():
    assessment = json.load(sys.stdin)
    findings = assessment.get("controlFindings", [])

    if not findings:
        print("No control findings in assessment.", file=sys.stderr)
        sys.exit(1)

    title = assessment.get("title", "Untitled")
    assessor = assessment.get("assessor", "Unknown")
    status = assessment.get("status", "unknown")

    # ── Classify findings ──
    satisfied = [f for f in findings if f["determination"] == "satisfied"]
    deficient = [f for f in findings if f["determination"] == "other_than_satisfied"]

    # Group by family
    by_family_sat = defaultdict(list)
    by_family_def = defaultdict(list)
    for f in satisfied:
        fam = f["controlId"].split("-")[0]
        by_family_sat[fam].append(f)
    for f in deficient:
        fam = f["controlId"].split("-")[0]
        by_family_def[fam].append(f)

    all_families = sorted(set(list(by_family_sat.keys()) + list(by_family_def.keys())))

    # Risk level counts
    risk_counts = Counter(f.get("riskLevel", "unspecified") for f in deficient)

    # ── Print report ──
    print("=" * 70)
    print(f"  SECURITY ASSESSMENT REPORT (SAR)")
    print("=" * 70)
    print(f"  Title    : {title}")
    print(f"  Assessor : {assessor}")
    print(f"  Status   : {status}")
    print(f"  Controls : {len(findings)} assessed")
    print(f"  Satisfied: {len(satisfied)}")
    print(f"  Other    : {len(deficient)}")
    print()

    # ── Summary by family ──
    print("── Summary by Control Family ──")
    print(f"  {'Family':<8} {'Satisfied':>10} {'Deficient':>10} {'Total':>8}")
    print(f"  {'─'*8} {'─'*10} {'─'*10} {'─'*8}")
    for fam in all_families:
        s = len(by_family_sat.get(fam, []))
        d = len(by_family_def.get(fam, []))
        print(f"  {fam:<8} {s:>10} {d:>10} {s+d:>8}")
    print(f"  {'─'*8} {'─'*10} {'─'*10} {'─'*8}")
    print(f"  {'TOTAL':<8} {len(satisfied):>10} {len(deficient):>10} {len(findings):>8}")
    print()

    # ── Risk summary ──
    print("── Risk Level Summary ──")
    for level in ["critical", "high", "moderate", "low"]:
        count = risk_counts.get(level, 0)
        icon = RISK_ICONS.get(level, "⚪")
        bar = "█" * count
        print(f"  {icon} {level:<10} {count:>3}  {bar}")
    print()

    # ── Detailed deficiencies ──
    if deficient:
        print("── Deficient Controls ──")
        print(f"  {'Control':<10} {'Method':<10} {'Risk':<10} Weakness")
        print(f"  {'─'*10} {'─'*10} {'─'*10} {'─'*40}")
        # Sort by risk severity desc
        deficient.sort(
            key=lambda f: RISK_SEVERITY.get(f.get("riskLevel", "low"), 0),
            reverse=True,
        )
        for f in deficient:
            ctrl = f["controlId"]
            method = f.get("assessmentMethod", "—")
            risk = f.get("riskLevel", "—")
            weakness = f.get("weaknessDescription", "—")[:60]
            print(f"  {ctrl:<10} {method:<10} {risk:<10} {weakness}")
        print()

    # ── Satisfied controls ──
    if satisfied:
        print("── Satisfied Controls ──")
        for f in sorted(satisfied, key=lambda x: x["controlId"]):
            ctrl = f["controlId"]
            method = f.get("assessmentMethod", "—")
            print(f"  ✅ {ctrl:<10} ({method})")
        print()

    # ── JSON summary ──
    summary = {
        "title": title,
        "totalAssessed": len(findings),
        "satisfied": len(satisfied),
        "otherThanSatisfied": len(deficient),
        "riskBreakdown": dict(risk_counts),
        "byFamily": {
            fam: {
                "satisfied": len(by_family_sat.get(fam, [])),
                "deficient": len(by_family_def.get(fam, [])),
            }
            for fam in all_families
        },
    }
    print(f"JSON Summary:\n{json.dumps(summary, indent=2)}")


if __name__ == "__main__":
    main()
