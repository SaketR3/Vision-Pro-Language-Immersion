Inspiration

Language is one of the largest parts of culture; it is the medium through which beliefs, knowledge, and history are passed through the generations. Yet, over half of the world’s population only speak one language – drastically reducing their ability to engage with different cultures than their own.

Furthermore, Indigenous languages and cultures in particular are declining. For example, Nahuatl, a widely spoken Indigenous language in the Americas, is rapidly losing speakers and is at risk of extinction.

In order to expose more people to more cultures and reduce the risk of language extinction, we present Lingua Spatial, an engaging AR application that immerses people in a new language.

What it does

Lingua Spatial is a language immersion app - literally. When users look around, the app displays the names of objects around them in a certain language, such as Nahuatl or Hausa. The app will also mention cultural facts related to the objects around users, such as their importance in a certain culture.

This allows for language immersion in a much more engaging way than could be achieved otherwise. Instead of practicing words and sentences seemingly at random, users can navigate through their daily lives and, with the combination of translations and cultural facts, experience the world around them in the same way other language speakers do. This turns language preservation into an engaging act, rather than a seemingly niche project.

Beyond this, language learning is a large consumer-facing problem, with one in four people worldwide attempting to learn a new language and a total market size of $61.5 billion in 2023. Our application provides a much more engaging way of language learning than phone apps such as Duolingo.

How we built it

We used Apple’s CreateML library to create models that recognize objects, and Apple’s ARKit library to track the recognized objects. Additionally, we used Flask and the Gemini API to translate the names of detected objects and generate informative corresponding cultural facts, and used ElevenLabs’ text-to-speech capabilities to create captivating voiceovers of the cultural facts. For the UI/UX, we prototyped the interaction model on Figma.

The Gemini and ElevenLabs APIs were crucial parts of this project. Without Gemini, we couldn't have generated informative facts, and without ElevenLabs we couldn't have generated high-quality, captivating voiceovers. We believe these are the best uses of these APIs, as they helped our application become far more engaging, helping more people than ever truly appreciate -- not just learn about -- other languages and cultures.

Challenges we ran into

Even though two of us had previous experience with Apple Vision Pro development, we still ran into several major challenges. In particular, object detection was quite difficult to implement. The usual object detection flow for Apple AR development is loading a pretrained model in using Apple’s CoreML library, then feeding screenshots of the environment to the model. However, for privacy reasons, Apple disallows developers from accessing screenshots taken on the Vision Pro. To get around this major restriction, we had to create 3D models of the objects we were interested in, and then set up ARKit to track these objects. If Apple removes this restriction in the future, we’re confident the project would be much more extensible.

Furthermore, creating the 3D models itself was not straightforward. At first, we used Reality Composer to create high-quality scans of the objects we were interested in. However, these scans were too high-quality, and it would have taken over eight hours to train models to recognize the scans. So, we had to search for pre-made 3D models on Sketchfab, which were lower-quality (although this still took around five hours of model training per object). Because the models we found had to match objects we had access to at the hackathon, this again was a major restriction because we could only use 3D models of common objects.

Beyond this, object positioning was also a major challenge. It was very difficult to ensure the labels stayed anchored to the detected objects. Another challenge was the Gemini API. At first, we tried to use Firebase’s Swift SDK, but it wasn’t updated to support the latest visionOS version, so we ended up creating a Flask API wrapping the Gemini Python API, and calling this instead.

Overall, this project was a large challenge, even with a couple of us having experience with Vision Pro development. Considering the potential of AR/VR applications, we think Vision Pro development will continue to evolve and become more developer-friendly.

Accomplishments that we're proud of

We’re proud that we were able to implement object detection. Considering the major restriction of not being able to send Vision Pro screen captures to models, at first we weren’t sure if we’d be able to implement object detection at all. We’re proud that we were able to work around this and take advantage of ARKit’s 3D model tracking capabilities.

What we learned

We learned a great deal about integrating ML into AR experiences. For the most part, the members on our team either had experience with ML but not AR or AR but not ML, which provided a great educational opportunity for all of us to learn how to integrate the two fields.

What's next for Lingua Spatial

To achieve the best translations for Indigenous languages, we’d incorporate Ind5, a transformer model trained specifically on Indigenous languages, in addition to the Gemini API.

Furthermore, we have many ideas for additional modes that could be added to the application. There could be a more interactive mode, where users look at an object and say what they think the object is called in the language they’re trying to learn, and the app provides them with feedback. There could also be a conversational immersion mode, where users talk with an AI assistant about the environment around them in their target language. Finally, there could be a game mode where users try to correctly name as many things around them in their target language as they can.
