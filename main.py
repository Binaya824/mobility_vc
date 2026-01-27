import os

from dotenv import load_dotenv
from agent_runner import build_agent

os.makedirs("output", exist_ok=True)

load_dotenv()

def load_prompt(name):
    with open(f"prompts/{name}_prompt.txt", "r", encoding="utf-8") as f:
        return f.read()


components = [
    "home",
    "navigation",
    # "branding",
    # "about",
    # "contact"
]


for component in components:
    system_prompt = load_prompt(component)
    agent = build_agent(system_prompt)

    result = agent.invoke({
        "messages": [
            {"role": "user", "content": f"Build the {component} UI now."}
        ]
    })

    print("Response:", result["messages"][-1].content)


