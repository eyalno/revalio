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
pip3 install -r requirements.txt
```

4. Create a `.env` file in the project root with the following content:
```
CHAT_GPT_API_KEY=your_openai_api_key_here
PDF_FILE_NAME=path_to_your_pdf_file
GPT_MODEL=gpt-4-1106-preview  # or your preferred model
SAFETY_MARGIN=500  # token buffer for conversation
MAX_MODEL_TOKENS=64000  # maximum tokens for your chosen model
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

## Contributing

Feel free to submit issues and enhancement requests!