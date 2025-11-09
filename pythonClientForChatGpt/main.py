from openai import OpenAI

import pdfplumber

from dotenv import load_dotenv
import os

# Load environment variables from a .env file
load_dotenv()

# Access a variable
chat_gpt_api_key = os.getenv("CHAT_GPT_API_KEY")
pdf_file_name = os.getenv("PDF_FILE_NAME")
gpt_model = os.getenv("GPT_MODEL")
 
safety_margin = int(os.getenv("SAFETY_MARGIN",500)) 
max_model_tokens = int(os.getenv("MAX_MODEL_TOKENS",64000)) 
"""Rough estimate: 1 word ≈ 1.3 tokens"""

client = OpenAI(api_key = chat_gpt_api_key)

# Extract text from PDF
with pdfplumber.open(pdf_file_name) as pdf:
    pdf_text = ""
    for page in pdf.pages:
        pdf_text += page.extract_text() + "\n"

# Initialize conversation history
conversation = [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": pdf_text}  # PDF content as initial context
]
message_token = [0, 0]

while True:
    user_input = input("Enter Message to ChatGpt or 'quit' to Exit: ")

    if user_input.lower() == "quit":
        print("Goodbye!")
        break  # Exit the loop

    # Add user message to the conversation
    conversation.append({"role": "user", "content": user_input})
    total_tokens = 0
    
    try:
        response = client.chat.completions.create(
            model = gpt_model,
            messages=conversation
        ) 
        
        message_token.append(response.usage.prompt_tokens)
        message_token.append(response.usage.completion_tokens)
        total_tokens = response.usage.total_tokens
        
        #print("prompt tokens: ", response.usage.prompt_tokens)
        #print("completion tokens: ", response.usage.completion_tokens)
        #print("total tokens:",total_tokens )
        
        assistant_reply = response.choices[0].message.content
        print("Assistant:",assistant_reply)
        
        conversation.append({"role": "assistant", "content": assistant_reply})

    except Exception as e:
        print("Error:", e)

    # Truncate conversation if token count exceeds MAX_TOKENS
    
    msg_truncated = 0
    
    while total_tokens > (max_model_tokens - safety_margin ):
      
        # Remove the oldest message after the initial system/file message
        if len(conversation) > 2:
            msg_truncated += 1
            total_tokens -= message_token[2]
            conversation.pop(2)  # Keep the first message (PDF + system)
            message_token.pop(2)
        else:
            break
    
    if (msg_truncated > 0):
        print("Warning: Conversation exceeded max tokens. "+ str(msg_truncated) + " messages truncated"  )

   
    
   

