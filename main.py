from fastapi import FastAPI, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from models import SessionLocal, Pokemon

app = FastAPI()

async def get_db():
    async with SessionLocal() as session:
        yield session

@app.get("/api/v1/pokemons")
async def get_pokemons(name: str = None, type: str = None, db: AsyncSession = Depends(get_db)):
    query = select(Pokemon)
    if name:
        query = query.filter(Pokemon.name.ilike(f"%{name}%"))
    if type:
        query = query.filter(Pokemon.type.ilike(f"%{type}%"))
    result = await db.execute(query)
    pokemons = result.scalars().all()
    return pokemons
