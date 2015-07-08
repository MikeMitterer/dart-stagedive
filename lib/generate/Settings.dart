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

class Setting {
    final String key;
    final String value;

    Setting(this.key, this.value) {
        Validate.notBlank(key);
        Validate.notBlank(value);
    }
}

abstract class Settings {

    List<Setting> get settings;
    //- private -----------------------------------------------------------------------------------
}

class SettingsFromManifest implements Settings {
    final Logger _logger = new Logger('stagedive.SettingsFromManifest');

    final File _manifest;

    SettingsFromManifest(this._manifest) {
        Validate.notNull(_manifest);
    }

    List<Setting> get settings {
        final List<Setting> _settings = new List<Setting>();

        final yaml.YamlMap map = yaml.loadYaml(_manifest.readAsStringSync());
        map.forEach((final key,final value) {
            if(value is String) {

                final Setting setting = new Setting(key.toString(),value.toString());
                _logger.fine("Setting: ${setting.key}:${setting.value}");

                _settings.add(setting);

            }
        });

        return _settings;
    }


}

