import subprocess
import json

def get_active_server():
    result = subprocess.run(["terraform", "output", "-json"], capture_output=True, text=True)
    output = json.loads(result.stdout)
    
    active_server = output["active_server"]["value"]
    
    if "blue_backend" in active_server:
        return "blue"
    return "green"

if __name__ == "__main__":
    active_server = get_active_server()
    print(f"Active Server: {active_server}")
