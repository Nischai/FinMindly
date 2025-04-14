# Python code to generate vocabulary.json during model training

import json
import pandas as pd
from tensorflow.keras.preprocessing.text import Tokenizer

# 1. Load your dataset (CSV with bank SMS messages)
# Replace 'bank_sms_dataset.csv' with your actual file path
df = pd.read_csv('bank_sms_dataset.csv')

# 2. Configure the tokenizer
max_words = 5000  # Maximum vocabulary size
tokenizer = Tokenizer(num_words=max_words, oov_token='<OOV>')

# 3. Fit the tokenizer on your SMS text data
# This creates the word-to-index mapping
tokenizer.fit_on_texts(df['message_text'])

# 4. Access the word index dictionary
word_index = tokenizer.word_index

# 5. Save the word index to vocabulary.json
with open('vocabulary.json', 'w') as f:
    json.dump(word_index, f)

print(f"Vocabulary saved with {len(word_index)} words")

# Optional: Preview the first 10 words in the vocabulary
preview = dict(list(word_index.items())[:10])
print("Vocabulary preview:", preview)