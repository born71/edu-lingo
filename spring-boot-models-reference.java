/*
 * Suggested Spring Boot Entity Models for your Lessons Microservice
 * These should match the JSON structure expected by your Flutter app
 */

// ===== LESSON ENTITY =====
/*
@Entity
@Table(name = "lessons")
public class Lesson {
    @Id
    private String id;
    
    @Column(nullable = false)
    private String title;
    
    @Column(length = 1000)
    private String description;
    
    private String language;
    
    @Enumerated(EnumType.STRING)
    private Difficulty difficulty;
    
    @Column(name = "estimated_minutes")
    private Integer estimatedMinutes;
    
    @ElementCollection
    @CollectionTable(name = "lesson_topics")
    private List<String> topics;
    
    @OneToMany(mappedBy = "lesson", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<QuizQuestion> questions = new ArrayList<>();
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")  
    private LocalDateTime updatedAt;
    
    // Constructors, getters, setters, etc.
}

// ===== QUIZ QUESTION ENTITY =====
@Entity
@Table(name = "quiz_questions")
public class QuizQuestion {
    @Id
    private String id;
    
    @ManyToOne
    @JoinColumn(name = "lesson_id")
    private Lesson lesson;
    
    @Column(nullable = false, length = 1000)
    private String question;
    
    @Column(name = "correct_answer", nullable = false)
    private String correctAnswer;
    
    @ElementCollection
    @CollectionTable(name = "question_options")
    private List<String> options;
    
    @Enumerated(EnumType.STRING)
    private QuestionType type = QuestionType.MULTIPLE_CHOICE;
    
    @Enumerated(EnumType.STRING)
    private Difficulty difficulty;
    
    private String language;
    
    @Column(name = "audio_url")
    private String audioUrl;
    
    @Column(name = "image_url")
    private String imageUrl;
    
    @Column(length = 1000)
    private String explanation;
    
    @Column(name = "order_index")
    private Integer orderIndex = 0;
    
    // Constructors, getters, setters, etc.
}

// ===== ENUMS =====
public enum Difficulty {
    BEGINNER, INTERMEDIATE, ADVANCED
}

public enum QuestionType {
    MULTIPLE_CHOICE, FILL_IN_BLANK, TRUE_OR_FALSE, LISTENING, SPEAKING
}
*/

// ===== EXPECTED JSON STRUCTURE =====
/*
Lesson JSON:
{
  "id": "basic_greetings",
  "title": "Basic Greetings",
  "description": "Learn essential greetings in different languages",
  "language": "Multiple",
  "difficulty": "BEGINNER",
  "estimatedMinutes": 12,
  "topics": ["greetings", "basics", "conversation"],
  "questions": [
    {
      "id": "greeting_1",
      "question": "Select the Spanish word for \"Hello\"",
      "correctAnswer": "Hola",
      "options": ["Guten Tag", "Bonjour", "Hola", "Ciao"],
      "type": "MULTIPLE_CHOICE",
      "difficulty": "BEGINNER",
      "language": "Spanish",
      "audioUrl": null,
      "imageUrl": null,
      "explanation": "Hola is the most common and friendly way to say hello in Spanish.",
      "orderIndex": 0
    }
  ],
  "createdAt": "2025-11-24T10:00:00",
  "updatedAt": "22025-11-24T10:00:00"
}
*/

// ===== REPOSITORY INTERFACES =====
/*
@Repository
public interface LessonRepository extends JpaRepository<Lesson, String> {
    List<Lesson> findByLanguage(String language);
    List<Lesson> findByDifficulty(Difficulty difficulty);
    List<Lesson> findByLanguageAndDifficulty(String language, Difficulty difficulty);
    
    @Query("SELECT l FROM Lesson l WHERE l.title LIKE %:query% OR l.description LIKE %:query%")
    List<Lesson> searchByTitleOrDescription(@Param("query") String query);
}

@Repository
public interface QuizQuestionRepository extends JpaRepository<QuizQuestion, String> {
    List<QuizQuestion> findByLessonIdOrderByOrderIndex(String lessonId);
    List<QuizQuestion> findByDifficulty(Difficulty difficulty);
    List<QuizQuestion> findByLanguage(String language);
}
*/

// ===== CONTROLLER ENDPOINTS =====
/*
@RestController
@RequestMapping("/api/lessons")
public class LessonController {
    
    @GetMapping
    public ResponseEntity<List<Lesson>> getAllLessons() {
        // Return all lessons
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Lesson> getLessonById(@PathVariable String id) {
        // Return specific lesson with questions
    }
    
    @GetMapping("/language/{language}")
    public ResponseEntity<List<Lesson>> getLessonsByLanguage(@PathVariable String language) {
        // Return lessons filtered by language
    }
    
    @GetMapping("/difficulty/{difficulty}")
    public ResponseEntity<List<Lesson>> getLessonsByDifficulty(@PathVariable String difficulty) {
        // Return lessons filtered by difficulty
    }
    
    @GetMapping("/search")
    public ResponseEntity<List<Lesson>> searchLessons(@RequestParam String q) {
        // Return lessons matching search query
    }
    
    @GetMapping("/{id}/questions")
    public ResponseEntity<List<QuizQuestion>> getLessonQuestions(@PathVariable String id) {
        // Return questions for specific lesson
    }
    
    @PostMapping
    public ResponseEntity<Lesson> createLesson(@RequestBody Lesson lesson) {
        // Create new lesson
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<Lesson> updateLesson(@PathVariable String id, @RequestBody Lesson lesson) {
        // Update existing lesson
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteLesson(@PathVariable String id) {
        // Delete lesson
    }
}
*/