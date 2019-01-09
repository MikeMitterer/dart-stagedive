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

enum InputType {
    INPUT, LOWERCASE, UPPERCASE
}

abstract class Questions {
    List<Question> get questions;
}

class Question {
    final InputType type;
    final String name;
    final String question;
    final String hint;

    String result = "";

    Question(this.type, this.name, this.question,this.hint);
}

class QuestionsFromManifest implements Questions {
    final Logger _logger = new Logger("stagedive.QuestionsFromManifest");

    final File _manifest;

    QuestionsFromManifest(this._manifest) {
        Validate.notNull(_manifest);
    }

    @override
    List<Question> get questions {
        final List<Question> _questions = new List<Question>();

        final yaml.YamlMap map = yaml.loadYaml(_manifest.readAsStringSync());

        _logger.fine("Prompts:");
        map["prompts"].forEach((final dynamic name, final yaml.YamlNode node) {

            _logger.fine("    $name");
            (node as yaml.YamlMap).forEach((final dynamic key, _) {
                _logger.fine("        ${key}: ${node.value[key.toString()]}");
            });

            _questions.add(new Question(
                _getType( (node as yaml.YamlMap)["type"]),
                    name,
                    (node as yaml.YamlMap)["question"],
                    _getHint((node as yaml.YamlMap)["hint"]))
            );
        });


        return _questions;
    }

    // -- private -------------------------------------------------------------

    InputType _getType(final String typeAsString,{ final InputType defaultType: InputType.INPUT }) {
        if(typeAsString == null || typeAsString.isEmpty) {
            return defaultType;
        }

        switch(typeAsString.toLowerCase()) {
            case "lowercase":
                return InputType.LOWERCASE;
            case "uppercase":
                return InputType.UPPERCASE;
            default:
                return defaultType;
        }
    }

    String _getHint(final String fieldvalue) {
        if(fieldvalue == null) {
            return "";
        }
        else {
            return fieldvalue;
        }
    }

}