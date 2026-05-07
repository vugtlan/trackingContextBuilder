# Tracking Context Builder ML Pipeline

A machine learning pipeline built with Apache Airflow for automated data preparation, model training, and deployment focused on building tracking context.

## Project Structure

```
trackingContextBuilder/
│
├── dags/                       # Airflow DAG definitions
│   ├── ml_pipeline.py         # Main ML pipeline DAG
│   └── data_ingestion.py      # Data ingestion DAG
│
├── scripts/                    # Python scripts
│   ├── data_preparation/      # Data processing scripts
│   │   ├── extract.py
│   │   ├── transform.py
│   │   └── load.py
│   └── model_training/        # Model training scripts
│       ├── train.py
│       ├── evaluate.py
│       └── predict.py
│
├── notebooks/                  # Jupyter notebooks for exploration
│   ├── exploratory_analysis.ipynb
│   └── model_experiments.ipynb
│
├── sql/                        # SQL queries
│   ├── extract_data.sql
│   └── feature_engineering.sql
│
├── data/                       # Data storage
│   ├── raw/                   # Raw data
│   ├── processed/             # Processed data
│   └── features/              # Feature engineered data
│
├── models/                     # Trained models
│
├── plugins/                    # Airflow plugins
│
├── config/                     # Configuration files
│   ├── pipeline_config.yaml
│   └── db_config.yaml
│
├── tests/                      # Unit tests
│
├── logs/                       # Application logs
│
├── trackingContextBuilder/     # Main Python package
│
├── requirements.txt            # Python dependencies
├── pyproject.toml             # Project configuration
├── .gitignore                 # Git ignore rules
├── .env.example               # Environment variables template
├── setup_env.sh               # Environment setup script
└── README.md                  # This file
```

## Setup

### 1. Create Virtual Environment

```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure Environment

```bash
# Run the setup script to configure your .env file
bash setup_env.sh

# Or manually copy and edit .env.example
cp .env.example .env
# Edit .env with your credentials
```

### 4. Initialize Airflow

```bash
# Set Airflow home (optional, defaults to ~/airflow)
export AIRFLOW_HOME=$(pwd)

# Initialize the database
airflow db init

# Create an admin user
airflow users create \
    --username admin \
    --firstname Admin \
    --lastname User \
    --role Admin \
    --email admin@example.com
```

### 5. Configure Airflow

Update the `airflow.cfg` file or set environment variables:
- Set `dags_folder` to point to the `dags/` directory
- Configure database connections
- Set up logging paths

### 6. Start Airflow

```bash
# Start the web server (default port 8080)
airflow webserver --port 8080

# In another terminal, start the scheduler
airflow scheduler
```

## Usage

### Running DAGs

1. Access the Airflow UI at `http://localhost:8080`
2. Enable your DAG by toggling it on
3. Trigger manually or wait for scheduled runs

### Adding New Components

#### New DAG
1. Create a new Python file in `dags/`
2. Define your DAG structure
3. Airflow will automatically detect it

#### New Script
1. Add Python scripts to `scripts/data_preparation/` or `scripts/model_training/`
2. Reference them in your DAG tasks

#### New SQL Query
1. Add SQL files to `sql/`
2. Use SQLExecuteQueryOperator in your DAG to execute them

#### New Notebook
1. Add Jupyter notebooks to `notebooks/` for exploratory work
2. Convert finalized code to scripts for production

## Pipeline Phases

### 1. Data Preparation
- Extract data from sources
- Clean and transform data
- Feature engineering
- Data validation

### 2. Model Training
- Train ML models
- Hyperparameter tuning
- Model evaluation
- Model versioning

### 3. Model Deployment (Coming Soon)
- Model serving
- Batch predictions
- Monitoring

## Development

### Running Tests

```bash
pytest tests/
```

### Code Quality

```bash
# Format code
black .

# Lint code
flake8 .
pylint scripts/
```

## Project Dependencies

This project uses:
- **Apache Airflow 2.8.1** for workflow orchestration
- **Snowflake** for data warehousing
- **scikit-learn, XGBoost, LightGBM, CatBoost** for machine learning
- **Pandas & NumPy** for data processing
- **Jupyter** for interactive development

See `requirements.txt` and `pyproject.toml` for full dependency list.

## Contributing

1. Create a feature branch
2. Make your changes
3. Run tests
4. Submit a pull request

## License

[Your License Here]
