# TruthChecker - Accessible Fact Verification Platform

An accessible, transparent fact-checking platform designed for all ages, with special focus on middle-aged to senior adults. Verifies claims against trusted data sources without using AI decision-making.

## 🎯 Features

- **Transparent Verification** - See exactly which trusted sources verify each claim
- **Accessibility First** - Large fonts, high contrast, simple navigation (WCAG AAA compliant)
- **No AI Black Box** - Rule-based verification system users can understand
- **Multiple Source Cross-Reference** - Compare results from Snopes, PolitiFact, WHO, and more
- **Source Credibility Ratings** - Know which outlets to trust
- **Easy Search** - Find similar claims with fuzzy matching

## 📁 Project Structure

```
truthchecker/
├── frontend/              # User interface
│   ├── index.html        # Main page
│   ├── css/
│   │   └── style.css     # Accessibility-first styling
│   └── js/
│       └── app.js        # Frontend logic
├── backend/              # API & database
│   ├── app.py           # Flask application
│   ├── database.py      # Database operations
│   ├── config.py        # Configuration
│   └── requirements.txt  # Python dependencies
├── database/            # Database files & schemas
│   ├── schema.sql       # Database structure
│   └── seeds.sql        # Initial data
├── docs/                # Documentation
│   ├── DATABASE_DESIGN.md
│   ├── UI_MOCKUP.md
│   └── DATA_PIPELINE.md
└── README.md
```

## 🚀 Quick Start

### Requirements
- Python 3.8+
- SQLite3 (included with Python)
- Modern web browser

### Installation

```bash
# Clone the repository
git clone https://github.com/tolula43-debug/truthchecker.git
cd truthchecker

# Install dependencies
pip install -r backend/requirements.txt

# Run the application
python backend/app.py

# Open in browser
# http://localhost:5000
```

## 📊 Tech Stack

- **Frontend**: HTML5, CSS3, Vanilla JavaScript
- **Backend**: Python Flask
- **Database**: SQLite/PostgreSQL
- **Accessibility**: WCAG AAA Level compliance

## 🎓 How It Works

1. User enters a claim to verify
2. System searches local database for exact/similar matches
3. Returns verified fact-checks from trusted sources
4. Displays consensus score and credibility ratings
5. Shows all source links for user verification

## 📚 Data Sources

- Google Fact Check Explorer
- Snopes
- PolitiFact
- WHO (World Health Organization)
- CDC (Centers for Disease Control)
- Full Fact
- NewsGuard Ratings

## ♿ Accessibility

- Large, readable fonts (18px minimum)
- High contrast WCAG AAA standard
- Keyboard navigation support
- Screen reader compatible
- Voice input option (planned)
- Simple, clear language

## 📖 Documentation

- [Database Design](./docs/DATABASE_DESIGN.md)
- [UI Mockup & Design](./docs/UI_MOCKUP.md)
- [Data Pipeline](./docs/DATA_PIPELINE.md)

## 📝 License

MIT License

## 🤝 Contributing

Contributions welcome! Please read CONTRIBUTING.md

## 📧 Contact

For questions or feedback, open an issue on GitHub.
