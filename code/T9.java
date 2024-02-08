import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.PriorityQueue;
import java.util.Queue;
import java.util.Set;
import java.util.StringTokenizer;



public class T9 {

  /**
   * T9 dictionary is the hash table having the digit seq mapped to words the
   * digit sequence is the key and the word tree is the value
   */
  public static HashMap<String, Queue<String>> T9dictionary = new LinkedHashMap<String, Queue<String>>();

  /**
   * T9dicitionary is constructed.
   */
  public T9() {
    makeDictionary();
    System.out.println(T9dictionary);
  }

  public static void main(String[] args) {
    makeDictionary();
    // String response = respondQuery(args);
    //test user manual input.
    //ask the user to input the sequence
    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
    String response = "";
    String sequence = "";
    String old_sequence = "";
    int count = 0;
    while(true){
    try {
      System.out.println("Enter the sequence: ");
      //keep last sequence in memory
      if(!sequence.equals("1")){
        old_sequence = sequence;
      }

      sequence = br.readLine();
      
      if (sequence.equals("1")) {
        //cycle through the words in the queue
        count++;
        response = cycleWord(old_sequence, count);
        System.out.println(response);
      }else{
        //new sequence: call cyckleWord with count 0
        count = 0;
        response = cycleWord(sequence,count);
        System.out.println(response);
      }

    } catch (Exception e) {
      System.out.println("Error: " + e.getMessage());
    }
    }


  }

  // /**
  //  * @param queries
  //  * @return response for the query
  //  *  this method is only used when this code is run.
  //  */
  // public static String respondQuery(String[] queries) {
  //   StringBuilder response = new StringBuilder();

  //   for (String eachQuery : queries) {
  //     response.append(getResponse(eachQuery) + " ");
  //   }
  //   return response.toString();
  // }
  //respond full query
    public static String respondQueryFull(String[] queries) {
        StringBuilder response = new StringBuilder();
    
        for (String eachQuery : queries) {
        response.append(getResponseFull(eachQuery) + " ");
        }
        
        return response.toString();
    }

  /**
   * @param query
   * @return
   * @throws SequenceNotFoundException
   *             converts the digit sequence input by the user into words and
   *             returns it
   */

  public static String getResponse(String query) {
    Queue<String> WordQueue = null;
    WordQueue = getWordQueue(query);
    //debug
    // System.out.println("WordQueue in getResponse: " + WordQueue);
    return (WordQueue.peek().toString().substring(0, query.length()));
  }
    //return the whole word queue for the given sequence
  public static String getResponseFull(String query) {
    Queue<String> WordQueue = null;
    WordQueue = getWordQueue(query);
    //debug
    // System.out.println("WordQueue in getResponseFull: " + WordQueue);
    return WordQueue.toString();
  }
  /**
   * @param query
   * @return
   * @throws SequenceNotFoundException
   * returns the wordQueue corresponding to the given Sequence
   */
  private static Queue<String> getWordQueue(String query) {
    if (!T9dictionary.containsKey(query)) {
      Set<String> Keys = T9dictionary.keySet();
      for (String eachKey : Keys) {
        if (eachKey.startsWith(query)) {
          System.out.println("in loop: "+eachKey);
          return (T9dictionary.get(eachKey));
        }
      }
      
    }
    return T9dictionary.get(query);
  }

  // /**
  //  * @param eachQuery
  //  * @param mayBeThis
  //  * @throws SequenceNotFoundException 
  //  * @returns Word In case the Word at the head of the tree is not the
  //  *          expected one, on pressing * (T9GUI) this method gets Invoked and
  //  *          based on the number of times * is pressed the tree returns a
  //  *          different Word everytime
  //  */
  // public static String notThisWord(String eachQuery, int mayBeThis) {
  //   Queue<String> WordQueue = getWordQueue(eachQuery);
  //   List<String> temporaryList = new ArrayList<String>();
  
  //   int numberOfWords = WordQueue.size();
  //   int notThisWord = 1;
  //   System.out.println(numberOfWords + " "+mayBeThis+ " "+ (mayBeThis%numberOfWords));
  //   // till the tree is not empty and a different word is not encountered
    
  //   while ((!WordQueue.isEmpty())
  //       && (notThisWord != (mayBeThis%numberOfWords)) && (mayBeThis%numberOfWords!=0)) {
  //     temporaryList.add(WordQueue.remove());
  //     System.out.println("dict " + WordQueue);

  //     notThisWord = (notThisWord + 1) % numberOfWords;
  //   }
  
  //   String mayBeThisWord = WordQueue.peek().toString();
  //   WordQueue.addAll(temporaryList);
  //   return mayBeThisWord.substring(0, eachQuery.length());

  // }
  /**
   * New function, cycle through the words in the queue
   * everytime call this function, have an iteratro to cycle through the words
   */

    public static String cycleWord(String query, int count) {
        String all_options = getResponseFull(query);
        //remove the brackets
        all_options = all_options.substring(1, all_options.length()-1);

        String[] options = all_options.split(",");
        //elimante the spaces
        for(int i = 0; i < options.length; i++){
            options[i] = options[i].trim();
        }
        //cycle through the words
        
        int index = count % options.length;
        return options[index];
    }

  /**
   * reads a dicitionary word by word adding the sequence to the T9 dictionary
   */
  public static void makeDictionary() {

    try {
      FileInputStream fstream = new FileInputStream(
          "../data/dictionary.txt");
      DataInputStream in = new DataInputStream(fstream);
      BufferedReader br = new BufferedReader(new InputStreamReader(in));
      String strLine;
      String sequence;
      while ((strLine = br.readLine()) != null) {
        StringTokenizer st = new StringTokenizer(strLine);
        while(st.hasMoreTokens()) {
          String word = st.nextToken();
          sequence = generateSeq(word.toLowerCase());
          insert(sequence, word.toLowerCase());
        }      
      }
      in.close();
    } catch (Exception e) {
      System.err.println("Error: " + e.getMessage());
    }
  }

    /**
   * @param word
   * @returns an equivalent digit sequence to the word
   */
  public static String generateSeq(String word) {
    StringBuilder sequence = new StringBuilder();
    for (char c : word.toCharArray()) 
      sequence.append(getDigit(c));
    return sequence.toString();
  }

  /**
   * @param sequence
   * @param word
   *            inserts the sequence into the T9dictionary if it is not there
   *            already, updates the wordQueue with the new word or increments
   *            the wodfrequencey if it already exists
   */
  public static void insert(String sequence, String word) {
    if (T9dictionary.containsKey(sequence)) {

      Queue<String> wordQueue = T9dictionary.get(sequence);
      // System.out.println(wordQueue.contains(new Word(word)));
      if (wordQueue.contains(word)) {
        // System.out.println("Before adding: "+ wordQueue + " "+word);
        // String toUpdate = removeWord(wordQueue, new Word(word));
        String toUpdate = removeWord(wordQueue, word);
        // System.out.println("Removed Word: "+toUpdate +
        // " from : "+wordQueue);
        // toUpdate.setFrequency(toUpdate.getFrequency() + 1);
        wordQueue.add(toUpdate);
        // System.out.println("After adding: "+ wordQueue + " "+word);
      } else {
        // System.out.println("Before adding: "+ wordQueue + " "+word);
        String ne = word;
        wordQueue.add(ne);
        // System.out.println("After adding: "+ wordQueue);

      }
    } else {
      Queue<String> wordQueue = new PriorityQueue<String>();
      wordQueue.add(word);
      T9dictionary.put(sequence, (Queue<String>) wordQueue);
    }
  }

  /**
   * @param wordQueue
   * @param word
   * @return Word removes the Word from the PriorityQueue and returns the
   *         Word.
   */
  private static String removeWord(Queue<String> wordQueue, String word) {
    for (String eachWordIn : wordQueue) {
      if (eachWordIn.equals(word)) {
        wordQueue.remove(eachWordIn);
        return eachWordIn;
      }
    }
    // since the method is called only if the Word is present return null
    // statement never gets executed
    return null;
  }

  /**
   * @param alphabet
   * @return digit mapped to the corresponding character
   */
  public static char getDigit(char alphabet) {
    if (alphabet >= '0' && alphabet <= '9') {
      return alphabet;
    }
    switch (alphabet) {
    case 'a':
    case 'b':
    case 'c':
      return '2';
    case 'd':
    case 'e':
    case 'f':
      return '3';
    case 'g':
    case 'h':
    case 'i':
      return '4';
    case 'j':
    case 'k':
    case 'l':
      return '5';
    case 'm':
    case 'n':
    case 'o':
      return '6';
    case 'p':
    case 'q':
    case 'r':
    case 's':
      return '7';
    case 't':
    case 'u':
    case 'v':
      return '8';
    case 'w':
    case 'x':
    case 'y':
    case 'z':
      return '9';
    default:
      return '1';
    }
  }
}
