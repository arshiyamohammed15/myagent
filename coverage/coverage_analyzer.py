from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, List

from tasks.test_task_model import CoverageStatus, TestTask, TestType


# Priority order: higher value => higher priority
TEST_TYPE_PRIORITY = {
    TestType.E2E: 5,
    TestType.INTEGRATION: 4,
    TestType.SECURITY: 4,
    TestType.PERFORMANCE: 3,
    TestType.EXPLORATORY: 2,
    TestType.UNIT: 1,
}


@dataclass
class CoverageAnalyzer:
    """
    Analyze test coverage and prioritize missing coverage tasks.
    """

    def _is_missing(self, task: TestTask) -> bool:
        """
        Determine if a task is missing coverage.

        Supports both enum value CoverageStatus.MISSING and string inputs like
        "Not Covered"/"missing".
        """
        status = task.coverage_status
        if isinstance(status, CoverageStatus):
            return status == CoverageStatus.MISSING
        if isinstance(status, str):
            normalized = status.strip().lower().replace(" ", "_")
            return normalized in {"missing", "not_covered", "notcovered"}
        return False

    def find_missing_coverage(self, tasks: Iterable[TestTask]) -> List[TestTask]:
        """Return tasks whose coverage_status is missing/not covered."""
        return [t for t in tasks if self._is_missing(t)]

    def prioritize_tests(self, tasks: Iterable[TestTask]) -> List[TestTask]:
        """
        Sort missing coverage tasks by priority (E2E > integration/security > perf > exploratory > unit)
        and preserve stable ordering within same priority.
        """
        def priority(task: TestTask) -> int:
            return TEST_TYPE_PRIORITY.get(task.test_type, 0)

        missing = self.find_missing_coverage(tasks)
        # Sort descending by priority value
        return sorted(missing, key=priority, reverse=True)

