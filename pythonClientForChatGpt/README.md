# Python ChatGPT PDF Reader

This application allows you to have an interactive conversation with ChatGPT about the contents of a PDF file. The application loads the PDF content and maintains a conversation context while managing token limits efficiently.

## Prerequisites

- Python 3.x
- Virtual environment (recommended)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/eyalno/revalio.git
cd revalio/pythonClientForChatGpt

```

2. Create and activate a virtual environment:
```bash
python3 -m venv venv
source venv/bin/activate  # On Windows use: venv\Scripts\activate
```

3. Install the required packages:
```bash
python3 -m pip install -r requirements.txt
```

4. update `.env` file in the project root with the following content:
```
CHAT_GPT_API_KEY=your_openai_api_key_here
PDF_FILE_NAME=path_to_your_pdf_file
GPT_MODEL=gpt-5  #gpt-4-1106-preview  # or your preferred model
SAFETY_MARGIN=500  # token buffer for conversation
MAX_MODEL_TOKENS=1000  # maximum tokens for your chosen model
```

## Usage

1. Make sure your virtual environment is activated:
```bash
source venv/bin/activate  # On Windows use: venv\Scripts\activate
```

2. Run the application:
```bash
python3 main.py
```

3. The application will:
   - Load the specified PDF file
   - Start an interactive conversation where you can ask questions about the PDF content
   - Type 'quit' to exit the application

## Features

- PDF text extraction
- Interactive conversation with ChatGPT
- Automatic token management
- Conversation history truncation to prevent token limits
- Environment-based configuration

## Configuration

You can adjust the following parameters in the `.env` file:
- `CHAT_GPT_API_KEY`: Your OpenAI API key
- `PDF_FILE_NAME`: Path to the PDF file you want to analyze
- `GPT_MODEL`: The GPT model to use
- `SAFETY_MARGIN`: Token buffer (default: 500)
- `MAX_MODEL_TOKENS`: Maximum tokens for the model (default: 64000)

## Error Handling

The application includes basic error handling for:
- API communication issues
- Token limit management
- Invalid user inputs


## Testing Guide

### 1. PDF Text Extraction Testing

**Test Prompts:**
- `What is the first word in the document?`
- `Summarize the main topics covered in the PDF`
- `List all the tasks mentioned in the document`
- `What are the deliverables mentioned in the PDF?`
- `Extract the date from the PDF`

**Expected Results:**
- The assistant should accurately reference content from the PDF
- Responses should demonstrate that the PDF content was successfully loaded
- Content references should match the actual PDF text

### 2. Interactive Conversation Testing

**Test Prompts:**
- `What is 50 + 50?` (first message)
- `Add 25 to the previous result` (follow-up to test context retention)
- `What was my first question?` (test conversation history)
- `Based on the PDF, what would you recommend for Task 1?`
- `Compare Task 2 and Task 3 from the document`

**Expected Results:**
- The assistant should maintain conversation context
- Multi-turn conversations should reference previous messages
- The assistant should reference the PDF context in responses

### 3. Automatic Token Management Testing

**Test Prompts (in sequence):**
1. `Write a 2000 word detailed story about a developer learning AWS`
2. `Write another 1500 word story about cloud architecture`
3. `What was the first story you wrote?` (should show token truncation occurred)
4. `Print the original PDF content` (should still be available)

**Expected Results:**
- After generating large responses, you should see logs like: `WARNING - Conversation exceeded max tokens. X messages truncated`
- Older conversation messages should be removed
- The PDF context should remain available (not truncated)
- The system should continue functioning after truncation

### 4. Conversation History Truncation Testing

**Test Prompts:**
1. `Tell me a short story`
2. `Tell me another short story`
3. `Tell me a third short story`
4. `What was the first story?` (may not be available if tokens exceeded)
5. `Print the document again` (PDF content should always be preserved)

**Expected Results:**
- Older messages are progressively removed as tokens accumulate
- System maintains the PDF context throughout
- A warning message appears when truncation occurs
- The application continues to function with reduced conversation history

### 5. Environment-Based Configuration Testing

**Test Prompts & Steps:**

**5.1 Test with Different Models:**
- Update `.env` to use `GPT_MODEL=gpt-3.5-turbo`
- Run: `Hello, which model are you?`
- Update back to `GPT_MODEL=gpt-4-1106-preview`
- Run the application again and compare responses

**5.2 Test with Different Safety Margins:**
- Set `SAFETY_MARGIN=100` (low margin)
- Generate several large responses and observe earlier truncation
- Set `SAFETY_MARGIN=2000` (high margin)
- Generate responses and observe later truncation

**5.3 Test with Different Max Tokens:**
- Set `MAX_MODEL_TOKENS=8000` (lower limit)
- Generate responses and observe more frequent truncation
- Set `MAX_MODEL_TOKENS=64000` (higher limit)
- Generate responses and observe less frequent truncation

**5.4 Test Missing Environment Variables:**
- Temporarily remove `CHAT_GPT_API_KEY` from `.env`
- Run the application and verify it shows: `Missing required environment variable: CHAT_GPT_API_KEY`
- Restore the variable and test again

**Expected Results:**
- Configuration changes take effect immediately
- Different models produce different response styles
- Safety margin and max tokens directly affect truncation behavior
- Missing configuration triggers appropriate error messages

### 6. Error Handling Testing

**Test Prompts:**
- `quit` (test graceful exit)
- (blank input - press Enter)
- Very long input with 10000+ characters
- Special characters and emojis: `Test 🚀 with émojis and spëcial çharacters`

**Expected Results:**
- Application handles `quit` gracefully with "Goodbye!" message
- Empty inputs are handled without crashing
- Long inputs are processed normally
- Special characters are handled properly
- No unhandled exceptions occur

## Test Execution Example

Run the application and try these prompts in order:

```bash
# Terminal 1: Start the application
python3 main.py

# Terminal 2: Enter these prompts one by one
# Session: Token Management Test
Enter Message to ChatGPT or 'quit' to Exit: What are the three tasks in this document?
Enter Message to ChatGPT or 'quit' to Exit: Can you write me a 1500 word technical guide on serverless architecture?
Enter Message to ChatGPT or 'quit' to Exit: What was my first question?
Enter Message to ChatGPT or 'quit' to Exit: Print the PDF again
Enter Message to ChatGPT or 'quit' to Exit: quit
```



## Contributing

Feel free to submit issues and enhancement requests!
