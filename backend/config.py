import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    """Base configuration"""
    SQLALCHEMY_DATABASE_URI = os.getenv(
        'DATABASE_URL',
        'sqlite:///truthchecker.db'
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JSON_SORT_KEYS = False
    MAX_CONTENT_LENGTH = 1024 * 1024  # 1MB max request size
    
    # API Configuration
    GOOGLE_FACT_CHECK_API_KEY = os.getenv('GOOGLE_FACT_CHECK_API_KEY', '')
    FACT_CHECK_API_TIMEOUT = 10  # seconds
    
    # Search Configuration
    SIMILARITY_THRESHOLD = 0.7  # 70% similarity to match
    MAX_SEARCH_RESULTS = 10
    
    # Performance
    CACHE_SIZE = 100  # Number of popular claims to cache
    
class DevelopmentConfig(Config):
    """Development configuration"""
    DEBUG = True
    TESTING = False

class ProductionConfig(Config):
    """Production configuration"""
    DEBUG = False
    TESTING = False

class TestingConfig(Config):
    """Testing configuration"""
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'

config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig
}
