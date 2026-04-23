function MY_GEMINI(prompt, cellContent) {
  const API_KEY = '#############';
  const url = "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=" + API_KEY;

  const payload = {
    contents: [{
      parts: [{ text: prompt + ": " + cellContent }]
    }]
  };

  const options = {
    method: 'post',
    contentType: 'application/json',
    payload: JSON.stringify(payload),
    muteHttpExceptions: true
  };

  let attempts = 3;

  while (attempts > 0) {
    try {
      const response = UrlFetchApp.fetch(url, options);
      const json = JSON.parse(response.getContentText());

      if (json.candidates && json.candidates.length > 0) {
        return json.candidates[0].content.parts[0].text.trim();
      }

      // Handle API error message
      if (json.error) {
        if (json.error.message.includes("high demand")) {
          Utilities.sleep(2000); // wait 2 seconds
          attempts--;
          continue;
        }
        return "AI Error: " + json.error.message;
      }

      return "AI Error: Empty response";

    } catch (e) {
      return "Script Error: " + e.toString();
    }
  }

  return "AI Error: Failed after retries";
}