from langchain.agents import create_agent
from langchain_community.chat_models import ChatDeepInfra
from langchain_core.callbacks.base import BaseCallbackHandler

from tools.tools import ensure_folder_and_file, write_content_to_file


class MyHandler(BaseCallbackHandler):
    def on_tool_start(self, serialized, input_str, **kwargs):
        print(f"\n{'=' * 60}")
        print(f"[TOOL CALL] {serialized.get('name', 'Unknown')} with args:")
        print(f"{input_str}")
        print(f"{'=' * 60}\n")

    def on_tool_end(self, output, **kwargs):
        print(f"\n{'=' * 60}")
        print(f"[TOOL RESULT]")
        print(f"{output}")
        print(f"{'=' * 60}\n")

    def on_chat_model_start(self, serialized, messages, **kwargs):
        print(
            f"\n[CHAT MODEL START] Generating response...\n **{messages[0][-1].content}"
        )

    def on_llm_end(self, response, **kwargs):
        print(f"\n[LLM END] Response generated: {response.llm_output}")

    def on_llm_new_token(self, token, **kwargs):
        print(token, end="", flush=True)

    def on_agent_action(self, action, **kwargs):
        print(f"\n[AGENT ACTION] Tool: {action.tool}, Input: {action.tool_input}")

    def on_agent_finish(self, finish, **kwargs):
        print(f"\n[AGENT FINISH] {finish.return_values}")


def build_agent(system_prompt: str):
    model = ChatDeepInfra(
        model="deepseek-ai/DeepSeek-V3.1-Terminus",
        temperature=0.8,
        max_tokens=8192,
        callbacks=[MyHandler()],
    )

    agent = create_agent(
        model,
        tools=[ensure_folder_and_file, write_content_to_file],
        system_prompt=system_prompt,
    )

    return agent
