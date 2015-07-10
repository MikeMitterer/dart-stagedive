/**
 * Copyright (c) 2015, Michael Mitterer (office@mikemitterer.at),
 * IT-Consulting and Development Limited.
 *
 * All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

part of stagedive;


/**
 * Asks you some questions
 */
class Prompter {
    final Logger _logger = new Logger('stagedive.Prompter');

    final List<Setting> settings = new List<Setting>();

    void ask(final List<Question> questions) {
        Validate.notNull(questions);

        if(questions.isNotEmpty) {
            _logger.info("Please anser the followoing questions");
            _logger.info("Some questions may have special markers.\n");
            _logger.info("  - [?] For this question is a 'hint' available. Enter a question mark and you'll see it");
            _logger.info("  - [l] Whatever you enter - it will be changed to lowercase");
            _logger.info("  - [u] Whatever you enter - it will be changed to uppercase");

            _logger.info("");
        }
        int length = _maxQuestionLength(questions);
        questions.forEach( (final Question question) {

            String result = "";
            int questionCounter = 0;
            do {
                String askThisQuestion = "  " + _addMarkers(question,question.question);

                stdout.write(askThisQuestion.padRight(length + 10));
                result = stdin.readLineSync().trim();
                if(result == "?" && question.hint.isNotEmpty) {
                    _logger.info("    - ${question.hint}\n");
                }

                questionCounter++;
            } while(result == "?" && questionCounter < 5);

            if(questionCounter == 5) {
                throw new ArgumentError("Hmmm... 5 times the same action with the same result...");
            }

            if(result.isEmpty) {
                throw new ArgumentError("The answer to '${question.question}' may not be empty - sorry!");
            }
            question.result = result;

            if(question.type == InputType.LOWERCASE) {
                question.result = result.toLowerCase();
            }
            if(question.type == InputType.UPPERCASE) {
                question.result = result.toUpperCase();
            }
            settings.add(new Setting(question.name,question.result));
        });
    }

    //- private -----------------------------------------------------------------------------------

    String _addMarkers(final Question question, String askThisQuestion) {
        bool hasColon = askThisQuestion.endsWith(":");
        if(hasColon) {
            askThisQuestion = askThisQuestion.replaceFirst(new RegExp(r":$"),"");
        }

        final List<String> markers = new List<String>();

        if(question.hint.isNotEmpty) {
            markers.add("?");
        }
        if(question.type == InputType.LOWERCASE) {
            markers.add("l");
        }
        if(question.type == InputType.UPPERCASE) {
            markers.add("u");
        }

        return "${askThisQuestion.trim()} [${markers.join(",")}]${hasColon ? ':' : ''} ";
    }

    int _maxQuestionLength(final List<Question> questions) {
        int length = 0;
        questions.forEach((final Question question) {
            length = max(length, question.question.length);
        });

        return length;
    }
}


