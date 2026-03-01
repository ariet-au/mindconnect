# script/embed_profile.py
import sys
import json
from sentence_transformers import SentenceTransformer

model = SentenceTransformer("intfloat/multilingual-e5-base")

def main():
    raw = sys.stdin.read()
    data = json.loads(raw)

    # Only handle chunk content
    text = data["content"]

    embedding = model.encode(
        f"passage: {text}",
        normalize_embeddings=True
    ).tolist()

    print(json.dumps(embedding))

if __name__ == "__main__":
    main()