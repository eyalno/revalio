from openai import OpenAI
import pdfplumber
from dotenv import load_dotenv
import os
import logging
from typing import List, Dict, Optional

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

class ChatGPTConfig:
    """Configuration class for ChatGPT conversation parameters."""
    def __init__(self):
        # Load environment variables
        load_dotenv()
        
        # Required configuration
        self.api_key = self._get_required_env("CHAT_GPT_API_KEY")
        self.pdf_file = self._get_required_env("PDF_FILE_NAME")
        self.model = self._get_required_env("GPT_MODEL")
        
        # Optional configuration with defaults
        self.safety_margin = int(os.getenv("SAFETY_MARGIN", "500"))
        self.max_tokens = int(os.getenv("MAX_MODEL_TOKENS", "64000"))
    
    def _get_required_env(self, var_name: str) -> str:
        """Get a required environment variable or raise an error."""
        value = os.getenv(var_name)
        if not value:
            raise ValueError(f"Missing required environment variable: {var_name}")
        return value

class PDFChatBot:
    """A chatbot that can discuss PDF contents using ChatGPT."""
    
    def __init__(self, config: ChatGPTConfig):
        """Initialize the chatbot with configuration."""
        self.config = config
        self.client = OpenAI(api_key=config.api_key)
        self.conversation: List[Dict[str, str]] = []
        self.message_tokens: List[int] = [0, 0]
        self.pdf_text = self._load_pdf()
        self._initialize_conversation()
    
    def _load_pdf(self) -> str:
        """Load and extract text from the PDF file."""
        try:
            with pdfplumber.open(self.config.pdf_file) as pdf:
                return "\n".join(page.extract_text() for page in pdf.pages)
        except Exception as e:
            raise RuntimeError(f"Failed to load PDF file: {str(e)}")
    
    def _initialize_conversation(self):
        """Initialize the conversation with system message and PDF context."""
        self.conversation = [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": self.pdf_text}
        ]

    def process_message(self, user_input: str) -> Optional[str]:
        """Process a user message and get response from ChatGPT."""
        # Add user message to the conversation
        self.conversation.append({"role": "user", "content": user_input})
        total_tokens = 0
        
        try:
            response = self.client.chat.completions.create(
                model=self.config.model,
                messages=self.conversation
            )
            
            self.message_tokens.append(response.usage.prompt_tokens)
            self.message_tokens.append(response.usage.completion_tokens)
            total_tokens = response.usage.total_tokens
            
            assistant_reply = response.choices[0].message.content
            self.conversation.append({"role": "assistant", "content": assistant_reply})
            
            # Manage conversation history
            self._truncate_conversation(total_tokens)
            
            return assistant_reply
            
        except Exception as e:
            logging.error(f"Error in ChatGPT API call: {str(e)}")
            return None
    
    def _truncate_conversation(self, total_tokens: int):
        """Truncate conversation history if token count exceeds limit."""
        msg_truncated = 0
        
        while total_tokens > (self.config.max_tokens - self.config.safety_margin):
            if len(self.conversation) > 2:
                msg_truncated += 1
                total_tokens -= self.message_tokens[2]
                self.conversation.pop(2)  # Keep the first message (PDF + system)
                self.message_tokens.pop(2)
            else:
                break
        
        if msg_truncated > 0:
            logging.warning(f"Conversation exceeded max tokens. {msg_truncated} messages truncated")

def main():
    """Main application entry point."""
    try:
        # Initialize configuration and chatbot
        config = ChatGPTConfig()
        chatbot = PDFChatBot(config)
        
        # Main conversation loop
        while True:
            user_input = input("Enter Message to ChatGPT or 'quit' to Exit: ")
            
            if user_input.lower() == "quit":
                print("Goodbye!")
                break
            
            response = chatbot.process_message(user_input)
            if response:
                print("Assistant:", response)
            else:
                print("Failed to get response from assistant. Please try again.")
                
    except Exception as e:
        logging.error(f"Application error: {str(e)}")
        print("An error occurred. Please check the logs for details.")

if __name__ == "__main__":
    main()

   
    
   

