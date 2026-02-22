# script/embed_profile.py
import sys
import json
from sentence_transformers import SentenceTransformer

# Load model once per execution
model = SentenceTransformer("intfloat/multilingual-e5-base")

def build_profile_text(data):
    """
    Combine structured psychologist data into
    a meaningful semantic representation.
    """

    parts = []

    if data.get("about_me"):
        parts.append(f"About therapist: {data['about_me']}")

    if data.get("about_specialties"):
        parts.append(f"Specialties: {data['about_specialties']}")

    if data.get("about_issues"):
        parts.append(f"Issues treated: {data['about_issues']}")

    if data.get("about_clients"):
        parts.append(f"Client types: {data['about_clients']}")

    if data.get("specialties"):
        parts.append("Specialty names: " + ", ".join(data["specialties"]))

    if data.get("client_types"):
        parts.append("Works with: " + ", ".join(data["client_types"]))

    if data.get("issues"):
        parts.append("Focus areas: " + ", ".join(data["issues"]))

    return "\n".join(parts)


def main():
    raw = sys.stdin.read()
    data = json.loads(raw)

    text = build_profile_text(data)

    # E5 model works best with "passage:" prefix
    embedding = model.encode(
        f"passage: {text}",
        normalize_embeddings=True
    ).tolist()

    print(json.dumps(embedding))


if __name__ == "__main__":
    main()