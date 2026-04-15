# AI Meal Planner 🥗

**AI Meal Planner** is a lifestyle-focused Flutter application that utilizes **Google Gemini AI** to generate personalized meal plans. Developed with a focus on premium UI/UX and local-first persistence, the app provides a streamlined experience for users to manage their daily nutrition goals.

---

## 🚀 Key Features

### Premium Dashboard
A clean, action-oriented home interface designed for efficient navigation and plan management.
- **AI Generation**: Effortlessly initiate meal plan creation based on your profile.
- **User Profile Hub**: A visual summary of current dietary preferences and health goals.
- **Minimalist Design**: A professional, white-labeled interface focused on high-quality content.

### Nutritional Dashboard
A detailed results view featuring advanced data visualization and UI components.
- **Macro Visualization**: A custom-painted ring displaying the breakdown of Protein, Carbs, and Fats.
- **Persistent Header**: A glassmorphic (frosted glass) header that remains pinned while scrolling for continuous macro tracking.
- **Detailed Recipes**: Cookbook-style meal cards with clear instructions and nutritional metadata.

### Interactive Shopping List
- **Groceries Checklist**: A functional checklist to track ingredient acquisition.
- **Reset Functionality**: Quickly clear checklist states to reuse existing meal plans.

---

## 🛠️ Technical Stack

- **Framework**: [Flutter](https://flutter.dev)
- **State Management**: [Riverpod](https://riverpod.dev)
- **AI Integration**: [Google Gemini 3.1 Flash](https://deepmind.google/technologies/gemini/)
- **Local Persistence**: [ObjectBox](https://objectbox.io)
- **Networking**: [Dio](https://pub.dev/packages/dio)

---

## ⚙️ Development Setup

### Troubleshooting Prerequisites
- Ensure the Flutter SDK (Stable) is installed and configured.
- Obtain a Google Gemini API Key.

### Installation Steps

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/ai_meal_planner.git
   cd ai_meal_planner
   ```

2. **Configure Environment**:
   Create a `.env` file in the root directory and add your API credentials:
   ```env
   GEMINI_API_KEY=your_key_here
   ```

3. **Install Dependencies & Generate Code**:
   ```bash
   flutter pub get
   flutter pub run build_runner build
   ```

4. **Run the Application**:
   ```bash
   flutter run
   ```

---

## 🏗️ Architecture
The project is built using a **Modified Clean Architecture** pattern:
- **Domain Layer**: Contains the core entities and repository definitions.
- **Data Layer**: Handles ObjectBox persistence and Gemini API communication.
- **Presentation Layer**: Manages the UI state and components via Riverpod providers.

---

> [!NOTE]
> *This application generates AI-driven nutritional guidance for general purposes. Please consult with a health professional for specific dietary requirements.*
