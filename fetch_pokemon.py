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
