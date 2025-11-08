from openai import OpenAI

import pdfplumber

import tiktoken

client = OpenAI(api_key="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")

MAX_TOKENS = 500
"""Rough estimate: 1 word ≈ 1.3 tokens"""

# Extract text from PDF
with pdfplumber.open("AWS Developer Coding Test.pdf") as pdf:
    pdf_text = ""
    for page in pdf.pages:
        pdf_text += page.extract_text() + "\n"

def estimate_tokens1(text):
    if isinstance(text, str):
        return int(len(text.split()) * 1.3)
    elif isinstance(text, list):
        # If content is a list of dicts (like input_file + input_text)
        total = 0
        for item in text:
            if "content" in item:
                total += estimate_tokens(item["content"])
        return total
    return 0

enc = tiktoken.encoding_for_model("gpt-5")

def estimate_tokens(text):
    if isinstance(text, str):
        return len(enc.encode(text))
    elif isinstance(text, list):
        return sum(estimate_tokens(item["content"]) for item in text if "content" in item)
    return 0


# Initialize conversation history
conversation = [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": pdf_text}  # PDF content as initial context
]


while True:
    user_input = input("Enter Message to ChatGpt or 'quit' to Exit: ")

    if user_input.lower() == "quit":
        print("Goodbye!")
        break  # Exit the loop

    # Add user message to the conversation
    conversation.append({"role": "user", "content": user_input})
    
    # Truncate conversation if token count exceeds MAX_TOKENS
    total_tokens = estimate_tokens(conversation)
    print(total_tokens)
    total_tokens1 = estimate_tokens1(conversation)
    print(total_tokens1)
    msg_truncated = 0

    while total_tokens > MAX_TOKENS:
      
        # Remove the oldest message after the initial system/file message
        if len(conversation) > 1:
            msg_truncated +=1
            conversation.pop(2)  # Keep the first message (PDF + system)
            total_tokens = estimate_tokens(conversation)
            total_tokens1 = estimate_tokens1(conversation)
            print(total_tokens)
            print(total_tokens1)
        else:
            break
    
    if (msg_truncated > 0):
        print("Warning: Conversation exceeded max tokens. "+ str(msg_truncated) + " messages truncated"  )

    try:
        response = client.chat.completions.create(
            model="gpt-5",
            messages=conversation
        ) 

        assistant_reply = response.choices[0].message.content
        print("Assistant:",assistant_reply)
        conversation.append({"role": "assistant", "content": assistant_reply})

    except Exception as e:
        print("Error:", e)
    
   

