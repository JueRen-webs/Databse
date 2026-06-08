from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import users#, students, lecturers, courses  # 按需加

app = FastAPI(title="MyUTHM API", version="1.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 允许任何前端地址访问（开发阶段最省心）
    allow_credentials=True,
    allow_methods=["*"],  # 允许 GET, POST, PUT, DELETE 等所有方法
    allow_headers=["*"],  # 允许任何请求头
)
app.include_router(users.router)
# app.include_router(students.router)
# app.include_router(lecturers.router)

@app.get("/")
def root():
    return {"message": "MyUTHM API is running"}