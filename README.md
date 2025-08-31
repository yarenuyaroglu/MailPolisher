# MailPolish 📧✨

**AI-Powered Email Enhancement for iOS**  

Polish your emails into professional, clear, and well-toned messages with AI.  

---

<p align="center">
  <img src="screensGifs/composeGIF.gif" width="400" alt="Compose demo" style="margin-right:60px;">
  <img src="screensGifs/ResultGIF.gif" width="400" alt="Result demo">
</p>

## 🌟 Features  
- **AI-Enhanced Writing**: Grammar, clarity, and tone improvements  
- **Tone & Empathy Control**: Professional, Friendly, Formal, Direct, Apologetic + empathy slider  
- **Presets**: Academia, Business, or General sector modes  
- **Quick Actions**: One-tap adjustments (shorter, more formal, warmer, etc.)  
- **Chat Refinement**: Iterative improvements via chat-style interface  
- **Copy & Share**: Export polished drafts to Mail or other apps  
- **Session Memory**: Keeps suggestions and history per session  

---

## 🛠 Tech Stack  

### Frontend (iOS)  
- **SwiftUI** – declarative UI with animations and glassmorphic design  
- **Architecture** – MVVM + Combine for state management  
- **Requirements** – iOS 16+, Xcode 15+  

### Backend (API)  
- **Flask** – API with Blueprints  
- **Validation** – Pydantic models  
- **AI Integration** – OpenAI/LLM (via LangChain-style prompt building)  
- **Summarization** – lightweight context compression  
- **Cache** – in-memory LRU for faster responses  
- **Session Store** – per-user history & suggestions  
- **Security** – dotenv for API keys, CORS & rate limiting enabled  

---
✨ *Built with SwiftUI + Flask + AI*  
