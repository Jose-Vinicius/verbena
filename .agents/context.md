# Project Brief: verbena Study Platform

## 1. Executive Summary
verbena Study is a precision-focused, AI-powered learning platform designed for students and developers. It converts raw study materials (summaries, notes, articles) into interactive question banks and mock exams using a "Precision in Darkness" design philosophy—minimizing cognitive load and maximizing focus.

## 2. Problem Statement
Traditional study methods often lack immediate feedback and structured retrieval practice. Students struggle to identify knowledge gaps and manage large volumes of notes. verbena Study automates the creation of study materials, providing a focused, feedback-driven environment.

## 3. Core Principles
- **Decision Minimalism:** Screens are designed to focus on one action or decision at a time.
- **Precision in Darkness:** A high-contrast, developer-grade dark UI that reduces eye strain and emphasizes content.
- **Immediate Feedback:** Real-time validation of answers during exams to reinforce learning.

## 4. Feature Requirements

### 4.1 Authentication & Profile
- Simple, distraction-free Login/Signup.
- Support for traditional email.
- User dashboard showing study progress and recent metrics.

### 4.2 Content Generation Engine
- **Source Input:** Text area for pasting notes or summaries (up to 10000 characters).
- **Subject Management:** Users can assign content to existing subjects or create new ones.
- **Batch Processing:** AI generates questions in batches (10, 20, or 30).
- **Progress Tracking:** Real-time polling with a progress bar and engine logs.

### 4.3 Knowledge Management
- **Question Bank:** Centralized repository of all generated questions grouped by subject, all questions have 5 answers.
- **Review Mode:** Expandable questions to view alternatives and correct answers without starting an exam.

### 4.4 Simulation (Mock Exams)
- **Configuration:** Select subject, quantity, and intensity level.
- **Validation:** System checks for sufficient questions before starting.
- **Exam Interface:** One question at a time. Progress tracking (e.g., "Question 4 of 10").
- **Real-time Feedback:** Visual indicators for correct/incorrect answers with detailed explanations.

### 4.5 Analytics & History
- **Results Summary:** Final score percentage, time duration, and detailed breakdown.
- **History Tracking:** Log of past performance across different subjects.
- **Metrics:** Average scores, exams completed, and top subjects.

## 5. Technical Architecture (Proposed)
- **Frontend:** Responsive Web Interface (Tailwind CSS).
- **Backend:** Ruby on Rails.
- **Processing:** solid queue for background job processing (AI generation).
- **AI Integration:** LLM for question generation and explanation (via batched API calls).

## 6. Design System: "verbena"
- **Color Palette:** Near-black backgrounds (#000), deep gray surfaces, and Violet (#a78bfa) accents.
- **Typography:** Geist (Modern sans-serif).
- **Components:** Side-bar navigation, high-contrast cards, and terminal-style generation logs.

## 7. Stack
- **backend/frontend:** Ruby on Rails
- **style:** Tailwind CSS
- **authentication:** Devise
- **job:** Solid Queue
- **DB:** Postgres 17
- **deploy:** Docker compose

## 8. Schema

### users

- id
- email
- password_digest
- created_at
- updated_at


### subjects

- id
- user_id (FK → users)
- name
- created_at
- updated_at


### summaries

- id
- user_id (FK → users)
- subject_id (FK → subjects)
- content (text)
- questions_requested (integer) — 10, 20 ou 30
- status (string) — pending, processing, done, error
- created_at
- updated_at


### questions

- id
- summary_id (FK → summaries)
- subject_id (FK → subjects) — denormalizado para facilitar queries por matéria sem join extra
- statement (text)
- options (jsonb) — array com as 4 alternativas
- correct_index (integer) — índice da alternativa correta (0 a 3)
- explanation (text)
- created_at
- updated_at


### exams

- id
- user_id (FK → users)
- subject_id (FK → subjects)
- questions_count (integer) — quantidade configurada pelo usuário
- correct_count (integer) — preenchido ao finalizar
- status (string) — in_progress, finished
- started_at
- finished_at


### exam_questions

- id
- exam_id (FK → exams)
- question_id (FK → questions)
- chosen_index (integer) — alternativa escolhida pelo usuário, null até responder
- is_correct (boolean) — preenchido no momento da resposta
- answered_at
- created_at


### Índices recomendados

questions: subject_id — consulta mais frequente do sistema
exam_questions: exam_id — carregamento das questões do simulado
summaries: user_id + status — polling de progresso
exams: user_id + status — histórico e exam em andamento