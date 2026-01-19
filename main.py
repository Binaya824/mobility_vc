import os

from dotenv import load_dotenv
from langchain_community.chat_models import ChatDeepInfra
from langchain_core.prompts import PromptTemplate
from langchain_community.tools import DuckDuckGoSearchRun
from langchain.agents import create_agent
from langsmith import Client
from tools.tools import ensure_folder_and_file, write_content_to_file
from langchain_core.callbacks.base import BaseCallbackHandler
from langchain_core.callbacks import StdOutCallbackHandler
from langchain_core.callbacks import CallbackManager


search_tool = DuckDuckGoSearchRun()

load_dotenv()
# from langchain.chains import LLMChain

class MyHandler(BaseCallbackHandler):
    def on_tool_start(self, serialized, input_str, **kwargs):
        print(f"\n{'='*60}")
        print(f"[TOOL CALL] {serialized.get('name', 'Unknown')} with args:")
        print(f"{input_str}")
        print(f"{'='*60}\n")

    def on_tool_end(self, output, **kwargs):
        print(f"\n{'='*60}")
        print(f"[TOOL RESULT]")
        print(f"{output}")
        print(f"{'='*60}\n")

    def on_llm_start(self, serialized, prompts, **kwargs):
        print(f"\n[LLM START] Generating response...")

    def on_llm_end(self, response, **kwargs):
        print(f"\n[LLM END] Response generated")

    def on_llm_new_token(self, token, **kwargs):
        print(token, end="", flush=True)
        
    def on_agent_action(self, action, **kwargs):
        print(f"\n[AGENT ACTION] Tool: {action.tool}, Input: {action.tool_input}")
    
    def on_agent_finish(self, finish, **kwargs):
        print(f"\n[AGENT FINISH] {finish.return_values}")
        
callback_manager = CallbackManager([MyHandler(), StdOutCallbackHandler()])


# Initialize LLM
model = ChatDeepInfra(model="deepseek-ai/DeepSeek-V3" , max_tokens=2048 , streaming=True,  
    callbacks=[MyHandler()])
client = Client()

prompt = client.pull_prompt("hwchase17/react")
# system_text = prompt.template
system_text = """
You are an autonomous HTML template generator.

CRITICAL WORKFLOW - MUST FOLLOW IN ORDER:

Step 1: Call ensure_folder_and_file
   - folder_path: "./ui"
   - file_name: "restaurants.html"

Step 2: Generate the complete HTML template

Step 3: IMMEDIATELY call write_content_to_file with:
   - file_path: "./ui/restaurants.html"
   - content: <the complete HTML you generated>
   - mode: "overwrite"

Step 4: Respond with: "HTML template written to ./ui/restaurants.html"

ABSOLUTE RULES:
- You MUST call write_content_to_file after generating HTML
- You MUST NOT just output the HTML as text
- The content parameter must contain the FULL HTML code
- DO NOT use markdown code blocks in the content parameter
- DO NOT return the HTML in your response - write it to file instead

HTML Requirements:
- Beautiful, modern design with CSS animations
- Responsive layout
- Gradient backgrounds and card-based design
- Calls fetchRestaurants() function
- Filters for isActive === true
- Displays: name, type, description, timings, cost, reservation, menu link, images

Example fetchRestaurants structure:
{
  name: string,
  type: string,
  description: string,
  timings: string,
  averageCostForTwo: number,
  reservationRequired: boolean,
  menuUrl: string,
  images: string[],
  isActive: boolean
}
"""
agent = create_agent(model, tools=[ensure_folder_and_file, write_content_to_file] , system_prompt=system_text)

result = agent.invoke(
    {"messages": [{"role": "user", "content": "make a beautiful ui for my restaurants"}]},
    config={"callbacks": [MyHandler()]} 
)

# print("Response:", result["messages"][-1].content)

