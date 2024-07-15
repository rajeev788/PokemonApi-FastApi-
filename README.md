# FastAPI Pokémon API

## Setup Instructions

1. **Clone the repository**:
    ```bash
    git clone <repo_url>
    cd fastapi-pokemon
    ```

2. **Set up a virtual environment and install dependencies**:
    ```bash
    python -m venv venv
    source venv/bin/activate  # On Windows use `venv\Scripts\activate`
    pip install -r requirements.txt
    ```

3. **Set up the PostgreSQL database**:
    ```bash
    # Ensure PostgreSQL is running and create a database
    createdb pokemon_db
    ```

4. **Create a `.env` file with the following content**:
    ```env
    DATABASE_URL=postgresql+asyncpg://user:password@localhost/pokemon_db
    ```

5. **Initialize the database and fetch Pokémon data**:
    ```bash
    python fetch_pokemon.py
    ```

6. **Run the FastAPI server**:
    ```bash
    uvicorn main:app --reload
    ```

7. **Access the API**:
    - Open your browser and go to `http://localhost:8000/api/v1/pokemons` to see the list of Pokémon.
    - Use query parameters to filter by name and type, e.g., `http://localhost:8000/api/v1/pokemons?name=pikachu&type=electric`.
