from pyngrok import ngrok
ngrok.set_auth_token("Ngrok token")

import os
import uuid
import json
import torch
import whisperx
import ffmpeg
import random
import threading
import requests
from flask import Flask, request, jsonify, Response

app = Flask(__name__)

device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"Используем устройство: {device}")

model = whisperx.load_model("base", device, compute_type="int8")

def get_gigachat_token():
    url = "https://ngw.devices.sberbank.ru:9443/api/v2/oauth"
    headers = {
        "Content-Type": "application/x-www-form-urlencoded",
        "Accept": "application/json",
        "RqUID": str(uuid.uuid4()),
        "Authorization": "Basic Auth key"
    }
    data = {
        "scope": "GIGACHAT_API_PERS"
    }

    response = requests.post(url, headers=headers, data=data, verify=False)
    response.raise_for_status()
    return response.json().get("access_token")

def ask_gigachat(prompt_text, access_token):
    url = "https://gigachat.devices.sberbank.ru/api/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json",
        "Accept": "application/json"
    }
    data = {
        "model": "GigaChat",
        "messages": [
            {"role": "user", "content": f"проанализируй речь пользователя дай оценку и советы по улучшению. Текст не точный, не обращай внимание на орфографию и пунктуацию: {prompt_text}"}
        ],
        "temperature": 0.8
    }

    response = requests.post(url, headers=headers, json=data, verify=False)
    response.raise_for_status()
    return response.json()

@app.route("/transcribe", methods=["POST"])
def transcribe():
    if "audio" not in request.files:
        return jsonify({"error": "No audio uploaded"}), 400

    file = request.files["audio"]
    original_ext = file.filename.split('.')[-1]
    original_path = f"temp_{uuid.uuid4().hex}.{original_ext}"
    converted_path = f"converted_{uuid.uuid4().hex}.wav"

    file.save(original_path)

    try:
        ffmpeg.input(original_path).output(
            converted_path,
            ar=16000,
            ac=1,
            format='wav'
        ).run(overwrite_output=True)

        result = model.transcribe(converted_path)
        model_a, metadata = whisperx.load_align_model(language_code=result["language"], device=device)
        result_aligned = whisperx.align(result["segments"], model_a, metadata, converted_path, device)

        combined_text = " ".join([segment["text"] for segment in result_aligned["segments"]])

        access_token = get_gigachat_token()
        gigachat_response = ask_gigachat(combined_text, access_token)

        return Response(
            json.dumps(gigachat_response, ensure_ascii=False, indent=2),
            content_type="application/json; charset=utf-8"
        )

    except Exception as e:
        return jsonify({"error": str(e)}), 500

    finally:
        for path in [original_path, converted_path]:
            try:
                os.remove(path)
            except FileNotFoundError:
                pass

port = random.randint(19000, 19096)

def run_flask():
    app.run(host="0.0.0.0", port=port)

threading.Thread(target=run_flask).start()

public_url = ngrok.connect(port)
print(f"Flask запущен на порту {port}")
print("Публичный URL:", public_url)