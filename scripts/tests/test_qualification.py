import importlib.util
from pathlib import Path
import tempfile
import unittest

path = Path(__file__).resolve().parents[1] / 'qualify.py'
spec = importlib.util.spec_from_file_location('qualify', path)
qa = importlib.util.module_from_spec(spec)
spec.loader.exec_module(qa)


class EvidenceGateTest(unittest.TestCase):
    def check(self, content, expected):
        with tempfile.NamedTemporaryFile(mode='w', suffix='.xml') as output:
            output.write(content)
            output.flush()
            return qa.verify_junit(output.name, expected)

    def test_empty_and_failing_reports_cannot_pass(self):
        expected = {'allowed_skips': {}, 'test_count': 1}
        for xml in ['<testsuite/>', '<testsuite><testcase name="a"><failure/></testcase></testsuite>', '<testsuite><testcase name="a"><error/></testcase></testsuite>']:
            with self.assertRaises(RuntimeError):
                self.check(xml, expected)

    def test_unreviewed_skips_and_missing_cases_cannot_pass(self):
        with self.assertRaises(RuntimeError):
            self.check('<testsuite><testcase name="a"><skipped message="new reason"/></testcase></testsuite>', {'allowed_skips': {}, 'test_count': 1})
        with self.assertRaises(RuntimeError):
            self.check('<testsuite><testcase name="a"/></testsuite>', {'allowed_skips': {}, 'test_count': 2})

    def test_reviewed_skip_is_reported_separately_from_a_pass(self):
        result = self.check('<testsuite><testcase name="a"/><testcase name="b"><skipped message="reason"/></testcase></testsuite>', {'allowed_skips': {'::b': 'reason'}, 'test_count': 2})
        self.assertEqual(result['passed'], 1)
        self.assertEqual(result['total'], 2)

    def test_duplicate_and_replaced_cases_cannot_satisfy_inventory(self):
        with self.assertRaises(RuntimeError):
            self.check('<testsuite><testcase name="a"/><testcase name="a"/></testsuite>', {'allowed_skips': {}, 'test_count': 2})
        with self.assertRaises(RuntimeError):
            self.check('<testsuite><testcase name="other"/></testsuite>', {'allowed_skips': {}, 'test_count': 1, 'case_ids': ['::expected']})

class SkipIdentityGateTest(unittest.TestCase):
    def test_same_test_name_in_different_classes_cannot_hide_an_extra_skip(self):
        xml = '<testsuite><testcase classname="one" name="same"><skipped message="reason"/></testcase><testcase classname="two" name="same"><skipped message="reason"/></testcase></testsuite>'
        with tempfile.NamedTemporaryFile(mode='w', suffix='.xml') as output:
            output.write(xml)
            output.flush()
            with self.assertRaises(RuntimeError):
                qa.verify_junit(output.name, {'allowed_skips': {'one::same': 'reason'}, 'test_count': 2})


if __name__ == '__main__':
    unittest.main()
