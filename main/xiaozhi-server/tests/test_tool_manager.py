import sys
import types
import unittest


class _DummyLogger:
    def debug(self, *args, **kwargs):
        return None

    def info(self, *args, **kwargs):
        return None

    def warning(self, *args, **kwargs):
        return None

    def error(self, *args, **kwargs):
        return None

    def bind(self, *args, **kwargs):
        return self

    def configure(self, *args, **kwargs):
        return None

    def remove(self, *args, **kwargs):
        return None

    def add(self, *args, **kwargs):
        return None


sys.modules.setdefault("loguru", types.SimpleNamespace(logger=_DummyLogger()))
sys.modules.setdefault(
    "config.config_loader",
    types.SimpleNamespace(load_config=lambda: {"log": {}}),
)
sys.modules.setdefault(
    "config.settings",
    types.SimpleNamespace(check_config_file=lambda: None),
)

from core.providers.tools.base.tool_types import ToolDefinition, ToolType
from core.providers.tools.unified_tool_manager import ToolManager


class FakeExecutor:
    def get_tools(self):
        return {
            "weather": ToolDefinition(
                name="weather",
                description={
                    "type": "function",
                    "function": {
                        "name": "weather",
                        "description": "weather tool",
                        "parameters": {"type": "object", "properties": {}},
                    },
                },
                tool_type=ToolType.SERVER_PLUGIN,
            )
        }


class ToolManagerCacheIsolationTest(unittest.TestCase):
    def test_function_descriptions_are_not_mutated_by_callers(self):
        manager = ToolManager(conn=None)
        manager.register_executor(ToolType.SERVER_PLUGIN, FakeExecutor())

        functions = manager.get_function_descriptions()
        functions.append(
            {
                "type": "function",
                "function": {
                    "name": "direct_answer",
                    "description": "synthetic tool",
                    "parameters": {"type": "object", "properties": {}},
                },
            }
        )

        refreshed_functions = manager.get_function_descriptions()

        self.assertEqual(
            ["weather"],
            [tool["function"]["name"] for tool in refreshed_functions],
        )


if __name__ == "__main__":
    unittest.main()
