from motor.motor_asyncio import AsyncIOMotorClient
from src.core.config import settings
import logging

logger = logging.getLogger(__name__)

class Database:
    client: AsyncIOMotorClient = None
    db = None

    @classmethod
    async def connect_to_database(cls):
        if cls.client is None:
            cls.client = AsyncIOMotorClient(settings.MONGODB_URL)
            cls.db = cls.client[settings.MONGODB_DB_NAME]

    @classmethod
    async def close_database_connection(cls):
        if cls.client is not None:
            cls.client.close()
            cls.client = None
            cls.db = None

    @classmethod
    def get_database(cls):
        if cls.db is None:
            raise Exception("Database not initialized. Call connect_to_database first.")
        return cls.db

db = Database() 