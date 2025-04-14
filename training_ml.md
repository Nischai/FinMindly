# Training an On-Device SMS Classification Model for FinMindly

This guide explains how to create a simple text classification model for bank SMS messages that can be embedded in your Flutter app.

## 1. Collect and Prepare Training Data

First, you'll need a dataset of bank SMS messages:

```
# Example dataset structure (CSV format)
"message_text","class"
"Your a/c XX7890 debited INR 1,500.00 on 12-04-2023 at AMAZON RETAIL. Avl Bal: INR 24,350.75","debit_card_transaction"
"INR 12,000.00 credited to a/c XX1234 by NEFT from SALARY COMPANY LTD on 01-04-2023. Avl Bal: INR 36,500.50","deposit"
"Withdrawal of INR 5,000.00 from ATM at CITY BRANCH on 15-04-2023 from a/c XX5678. Avl Bal: INR 19,350.75","withdrawal"
# And so on...
```

Aim for at least 50-100 examples per category. Categories to consider:
- debit_card_transaction
- credit_card_transaction
- bank_transfer
- withdrawal
- deposit
- bill_payment
- not_transaction (for non-financial messages)

## 2. Train a Simple TensorFlow Model

Here's Python code to train a basic text classification model:

```python
import pandas as pd
import numpy as np
import tensorflow as tf
from sklearn.model_selection import train_test_split
from tensorflow.keras.preprocessing.text import Tokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences

# Load your dataset
df = pd.read_csv('bank_sms_dataset.csv')

# Split dataset
X_train, X_test, y_train, y_test = train_test_split(
    df['message_text'], df['class'], test_size=0.2, random_state=42)

# Prepare text tokenizer
max_words = 5000  # Size of vocabulary
max_length = 100  # Max SMS length
tokenizer = Tokenizer(num_words=max_words, oov_token='<OOV>')
tokenizer.fit_on_texts(X_train)

# Save vocabulary (needed for preprocessing in the app)
import json
with open('vocabulary.json', 'w') as f:
    json.dump(tokenizer.word_index, f)

# Convert text to sequences and pad
X_train_seq = tokenizer.texts_to_sequences(X_train)
X_test_seq = tokenizer.texts_to_sequences(X_test)
X_train_pad = pad_sequences(X_train_seq, maxlen=max_length, padding='post')
X_test_pad = pad_sequences(X_test_seq, maxlen=max_length, padding='post')

# Convert classes to one-hot encoding
classes = df['class'].unique()
class_to_index = {cls: i for i, cls in enumerate(classes)}
y_train_encoded = np.array([class_to_index[cls] for cls in y_train])
y_test_encoded = np.array([class_to_index[cls] for cls in y_test])
y_train_onehot = tf.keras.utils.to_categorical(y_train_encoded, num_classes=len(classes))
y_test_onehot = tf.keras.utils.to_categorical(y_test_encoded, num_classes=len(classes))

# Save class mapping
with open('label_mapping.json', 'w') as f:
    json.dump(class_to_index, f)

# Build a simple model
model = tf.keras.Sequential([
    tf.keras.layers.Embedding(max_words, 16, input_length=max_length),
    tf.keras.layers.GlobalAveragePooling1D(),
    tf.keras.layers.Dense(24, activation='relu'),
    tf.keras.layers.Dense(len(classes), activation='softmax')
])

model.compile(
    optimizer='adam',
    loss='categorical_crossentropy',
    metrics=['accuracy']
)

# Train the model
history = model.fit(
    X_train_pad, y_train_onehot,
    epochs=10,
    validation_data=(X_test_pad, y_test_onehot),
    batch_size=32
)

# Save the model in TensorFlow Lite format
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()
with open('sms_classifier.tflite', 'wb') as f:
    f.write(tflite_model)

# Save labels
with open('sms_labels.txt', 'w') as f:
    for cls in classes:
        f.write(f"{cls}\n")
```

## 3. Optimize for Mobile

To make the model more efficient:

1. **Quantization**: Reduce model size by quantizing weights:
   ```python
   converter = tf.lite.TFLiteConverter.from_keras_model(model)
   converter.optimizations = [tf.lite.Optimize.DEFAULT]
   tflite_model = converter.convert()
   ```

2. **Prune vocabulary**: Limit to most common words:
   ```python
   tokenizer = Tokenizer(num_words=3000)  # Use fewer words
   ```

## 4. Add Files to Your Flutter Project

1. Create an `assets/ml/` directory in your Flutter project
2. Add these files to it:
   - `sms_classifier.tflite` (Your model)
   - `sms_labels.txt` (Class names)
   - `vocabulary.json` (For tokenization)

3. Update `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/ml/sms_classifier.tflite
       - assets/ml/sms_labels.txt
       - assets/ml/vocabulary.json
   ```

## 5. Install Required Packages

```
flutter pub add tflite_flutter path_provider
```

## 6. Testing and Iteration

To improve your model:

1. Collect misclassified messages from actual usage
2. Add them to your training data
3. Retrain the model periodically
4. Update the .tflite file in your app

## Performance Considerations

- The model is small enough to run quickly on most devices
- Test on lower-end devices to ensure performance
- Consider adding a small delay after receiving SMS to batch processing
- Use the confidence score to fall back to regex when the model is uncertain

By following this approach, you'll have a privacy-preserving on-device ML solution that can intelligently classify bank SMS messages without sending sensitive financial data to any external services.