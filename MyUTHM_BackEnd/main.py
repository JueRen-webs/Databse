from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# 1. 引入刚刚写好的 4 个 Router 模块
from routers import users, academic, lecturer, campus, student

app = FastAPI(title="MyUTHM Comprehensive API", version="1.0")

# 允许跨域（方便你的 Flutter 访问）
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 2. 依次挂载到 FastAPI 实例上
app.include_router(users.router)
app.include_router(academic.router)
app.include_router(lecturer.router)
app.include_router(campus.router)
app.include_router(student.router)

@app.get("/")
def root():
    return {"status": "online",
            "system": "MyUTHM Backend",
            "docs_url": "/docs"}