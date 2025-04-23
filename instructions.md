Here are the instructions for the architect and the research team, based on the provided sources:
Instructions for the Software Architect:
As the software architect, your primary responsibility is to guide the development team in creating a Ruby on Rails application that fulfills the requirements of the Apple coding assessment. Your instructions to the team should emphasize the following:
•
Core Functionality: Design and build a Ruby on Rails application that accepts an address as input and retrieves forecast data for that address. The absolute must-have is displaying the current temperature.
•
Bonus Features (Investigate): Explore the feasibility of including bonus features such as high/low temperatures and an extended forecast. The research team will provide information on available weather APIs to inform this decision, but do not let this block the development of the core functionality.
•
Caching: Implement a 30-minute caching mechanism for forecast data based on the zip code of the input address. This is a crucial non-functional requirement emphasizing performance and resource use.
•
Cache Indicator: The user interface must clearly indicate whether the displayed forecast data is fresh or pulled from the cache.
•
Unit Testing: Plan for and implement a comprehensive unit testing strategy. Pay special attention to testing the external API calls and the caching logic. Treat this as production-level code, not just an exercise.
•
Documentation: Ensure clear and concise internal code documentation (comments) and a detailed README file explaining setup, functionality, and design choices. Include decomposition of the objects in the documentation.
•
User Interface (UI): Include basic UI elements sufficient to display the requested forecast data and the cache status. While functionality is the priority over a super polished UI initially, a functional interface is required.
•
Code Quality: Emphasize code quality throughout the development process. This includes good object decomposition, proper encapsulation (methods doing one thing well), adherence to standard naming conventions, and a balance in code reuse (DRY principle without over-engineering).
•
Error Handling: Build in robust error handling for the external API integration from the start. Consider scenarios where the API might be down or return bad data.
•
Design Patterns: Consider the application of relevant design patterns where applicable to ensure well-structured code. The research team will provide suggestions for relevant patterns.
•
Scalability: While this is a small application, be mindful of scalability considerations in your design.
•
Submission: The final submission should be a single GitHub link containing the code, README file, and unit tests.
Remember that this assessment reflects the expectations for a senior Ruby on Rails developer in an enterprise production-level code environment.
Instructions for the Research Team:
Your role is to provide crucial information and recommendations to the software architect to facilitate the efficient and effective development of the Ruby on Rails coding assessment project. Your tasks include:
•
Weather APIs: Investigate and compare available weather APIs that can provide forecast data based on an address. Your research should cover:
◦
Data points available (current temperature, high/low, extended forecast).
◦
Ease of integration and use within a Ruby on Rails application.
◦
Cost, usage limits, and reliability of each API.
◦
Data formats provided (e.g., JSON, XML). Present a summary of your findings, highlighting the pros and cons of at least two potential APIs, to the architect.
•
Caching Strategies: Research different caching strategies in Ruby on Rails that go beyond basic Rails.cache.fetch with a simple expiration. Specifically focus on:
◦
Effective ways to handle caching based on zip codes.
◦
Considerations for a 30-minute expiration period.
◦
Potential gotchas or best practices for this specific caching requirement. Provide recommendations to the architect on the most suitable caching approach.
•
Design Patterns: Identify and suggest applicable design patterns that would be beneficial for this type of Ruby on Rails application involving external API calls and caching. Explain how these patterns could improve the structure, maintainability, and testability of the code.
•
Unit Testing Best Practices: Research best practices for writing unit tests in Ruby on Rails, with a particular focus on:
◦
Effectively testing interactions with external APIs (e.g., using mocking or VCR).
◦
Strategies for testing the caching logic to ensure it functions correctly. Provide examples or guidance on how to implement robust unit tests for these critical areas.
•
Documentation Standards: Define standards for code commenting and README file content in the context of a professional Ruby on Rails project. Provide examples of what constitutes good code comments and what information should be included in the README file (e.g., setup instructions, functionality overview, design decisions).
Your findings will be crucial in informing the architect's decisions and guiding the development team towards building a high-quality solution that meets the expectations of the coding assessment