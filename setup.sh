#!/bin/bash

# Create project directory
mkdir -p fastapi-pokemon
cd fastapi-pokemon

# Create and activate virtual environment
python -m venv venv
source venv/bin/activate

# Install dependencies
pip install fastapi uvicorn asyncpg sqlalchemy httpx pydantic python-dotenv

# Create necessary files
touch main.py models.py config.py fetch_pokemon.py .env README.md

# Populate main.py
cat <<EOL > main.py
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
EOL

# Populate models.py
cat <<EOL > models.py
from sqlalchemy import Column, Integer, String
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import declarative_base, sessionmaker
from config import settings

DATABASE_URL = settings.database_url

engine = create_async_engine(DATABASE_URL, echo=True)
SessionLocal = sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False
)

Base = declarative_base()

class Pokemon(Base):
    __tablename__ = 'pokemons'
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    image = Column(String)
    type = Column(String)

async def init_db():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
EOL

# Populate config.py
cat <<EOL > config.py
from pydantic import BaseSettings

class Settings(BaseSettings):
    database_url: str

    class Config:
        env_file = ".env"

settings = Settings()
EOL

# Populate fetch_pokemon.py
cat <<EOL > fetch_pokemon.py
import httpx
from sqlalchemy.ext.asyncio import AsyncSession
from models import SessionLocal, Pokemon, init_db

POKEAPI_URL = "https://pokeapi.co/api/v2/pokemon?limit=100"

async def fetch_pokemons():
    async with httpx.AsyncClient() as client:
        response = await client.get(POKEAPI_URL)
        data = response.json()
        return data['results']

async def save_pokemons(pokemons):
    async with SessionLocal() as session:
        for pokemon in pokemons:
            poke_response = await httpx.AsyncClient().get(pokemon['url'])
            poke_data = poke_response.json()
            poke_type = poke_data['types'][0]['type']['name']
            poke_image = poke_data['sprites']['front_default']
            new_pokemon = Pokemon(name=pokemon['name'], image=poke_image, type=poke_type)
            session.add(new_pokemon)
        await session.commit()

async def main():
    await init_db()
    pokemons = await fetch_pokemons()
    await save_pokemons(pokemons)

if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
EOL

# Populate .env
cat <<EOL > .env
DATABASE_URL=postgresql+asyncpg://user:Rajiv7890@localhost/pokemon
EOL

#
