# DiaRisk - Diabetes Risk Assessment System

DiaRisk is a comprehensive system for assessing diabetes risk using machine learning models and providing personalized recommendations. The system consists of a FastAPI backend and a Flutter mobile application.

## App Demo
Watch the app demo video: [DiaRisk App Demo](https://drive.google.com/file/d/1nxqdfxuWWcr3Wy1a9CXyEPV66EKU2PCA/view?usp=drive_link)

## Features

- Diabetes risk assessment using machine learning models
- User authentication and authorization
- Personalized health recommendations
- Secure data handling
- RESTful API endpoints
- Mobile interface (Android)

## Prerequisites

- Docker and Docker Compose
- Flutter SDK (for local development)
- Android Studio / Xcode (for local development)

## Project Structure

```
DiaRisk/
├── Backend/           # FastAPI backend
├── app/              # Flutter mobile application
├── docker-compose.yml # Docker configuration
└── README.md         # This file
```

## Quick Start with Docker Compose

1. Make sure Docker and Docker Compose are installed on your system

2. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/DiaRisk.git
   cd DiaRisk
   ```

3. Start the backend services:
   ```bash
   docker-compose up --build
   ```

The backend API will be available at `http://localhost:8000`

## Local Development Setup

### Backend Development

1. Navigate to the backend directory:
   ```bash
   cd Backend
   ```

2. Create a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Create a `.env` file in the Backend directory with the following variables:
   ```
   MONGODB_URL=your_mongodb_url
   SECRET_KEY=your_secret_key
   ALGORITHM=HS256
   ACCESS_TOKEN_EXPIRE_MINUTES=30
   GOOGLE_CLIENT_ID=your_client_id
   GOOGLE_CLIENT_SECRET=your_client_secret
   ```

5. Run the backend server:
   ```bash
   uvicorn main:app --reload
   ```

### Flutter Development

1. Navigate to the app directory:
   ```bash
   cd app
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## API Documentation

Once the backend is running, you can access the API documentation at:
- Swagger UI: `http://localhost:8000/docs`

## Machine Learning Models

The system uses ensemble machine learning models for diabetes risk assessment:
- XGBoost
- LightGBM
- Random Forest (RF)
- Logistic Regression (LR)
- Voting Classifier
- Scikit-learn models

Models are trained on Diabetes sample data.
