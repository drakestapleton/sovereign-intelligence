#!/usr/bin/env python3
import sys
import json
import urllib.request
import time

def dispatch(prompt: str, system_prompt: str = None, target_file: str = None):
    url = "http://127.0.0.1:18006/v1/chat/completions"
    
    if not system_prompt:
        system_prompt = (
            "You are AIEN, sovereign cognitive architecture on Grace Blackwell GB10. "
            "Generate verified, high-performance native Rust code. "
            "Strictly follow the unslop standard: zero em dashes, zero en dashes, affirmative voice."
        )

    payload = {
        "model": "atlas-lightning-omni",
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": prompt}
        ],
        "max_tokens": 4096,
        "temperature": 0.2,
        "stream": True
    }

    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"}
    )

    print("=== AIEN ON SPARK (GB10) DISPATCH START ===")
    print(f"Target: {target_file or stdout}")
    
    reasoning_tokens = []
    content_tokens = []
    start_time = time.time()

    with urllib.request.urlopen(req, timeout=120) as resp:
        for line in resp:
            line_str = line.decode("utf-8").strip()
            if not line_str.startswith("data: "):
                continue
            data_str = line_str[6:]
            if data_str == "[DONE]":
                break
            try:
                chunk = json.loads(data_str)
                delta = chunk["choices"][0].get("delta", {})
                if "reasoning" in delta and delta["reasoning"]:
                    sys.stdout.write(delta["reasoning"])
                    sys.stdout.flush()
                    reasoning_tokens.append(delta["reasoning"])
                elif "content" in delta and delta["content"]:
                    content_tokens.append(delta["content"])
            except Exception:
                pass

    elapsed = time.time() - start_time
    full_content = "".join(content_tokens)
    print("\n=== AIEN REASONING COMPLETE ===")
    print(f"Elapsed: {elapsed:.2f}s | Content length: {len(full_content)} chars")

    if target_file and full_content:
        # Strip markdown fences if present
        clean_code = full_content.strip()
        if clean_code.startswith("```"):
            lines = clean_code.split("\n")
            if lines[0].startswith("```"):
                lines = lines[1:]
            if lines and lines[-1].startswith("```"):
                lines = lines[:-1]
            clean_code = "\n".join(lines)
        
        with open(target_file, "w", encoding="utf-8") as f:
            f.write(clean_code)
        print(f"Saved generated code to: {target_file}")
    elif full_content:
        print("=== AIEN FINAL OUTPUT ===")
        print(full_content)

    return full_content

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: symphony_dispatch.py <prompt> [target_file]")
        sys.exit(1)
    prompt = sys.argv[1]
    target = sys.argv[2] if len(sys.argv) > 2 else None
    dispatch(prompt, target_file=target)
