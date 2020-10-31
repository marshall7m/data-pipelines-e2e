from airflow.models import DagBag
import unittest

class TestSparkifyAnalytics(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
       cls.dagbag = DagBag()
    def test_dag_loaded(self):
        dag = self.dagbag.get_dag(dag_id='sparkify_analytics')
        self.assertDictEqual(self.dagbag.import_errors, {})
        self.assertIsNotNone(dag)

if __name__ == '__main__':
    unittest.main()