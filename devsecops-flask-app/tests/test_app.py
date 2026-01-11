from app.main import app

def test_home():
    client = app.test_client()
    assert client.get("/").status_code == 200

def test_api():
    client = app.test_client()
    assert client.get("/api/status").status_code == 200
