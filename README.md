# StageDive - Template-Base project generator
### Define your own variables for your templates

## Install
Install
```shell
    pub global activate stagedive
```

Update
```shell
    # activate stagedive again
    pub global activate stagedive
```

Uninstall
```shell
    pub global deactivate stagedive   
```    

## Usage

```shell
Usage: stagedive -n <new project folder> -p <template project> -t <template name>
    -s, --settings           Prints settings
    -h, --help               Shows this message
    -l, --list               List available templates
    -n, --newprojectdir      New project folder
    -p, --templateproject    Template project (e.g. stagedive)
    -t, --template           Template name (e.g. console)
    -v, --loglevel           Sets the appropriate loglevel
                             [info, debug, warning]

Sample:

    Generate project in example/console:
        'stagedive -n example/console -p stagedive -t console'
```

`stagedive -l` - List the available templates  
It looks for a template in lib\_templates. If it finds a \_template folder it scans for subfolders with manifest.yaml.  
At the moment the only packages that has a \_template folder is StageDive but you
can define your own \_templates-folder in your package.

Try `stagedive -n example/console -p stagedive -t console` 
This command will prompt you for your name and your email address.  

StageDive creates the appropriate sample in example/console.

StageDive takes all variables defined in the manifest.yaml and replaces the according template fields.  
There is one extra variable: `basename` 
`basename` is the name you specify with the -t option.  
 
File-Content-Format: `<%= varname %>`  
File-Name-Format: `{varname}`

### Sample manifest.yaml

```yaml
#templatename is not optional!
templatename: Simple Console

prompts:
  name:
    type: input
    question: "Add your name:"

  email:
    type: input
    question: "Your email address:"
```

At the moment the there are two input types: `input` and `lowercase`.

- `input`:      Asks you the 'question' and stores the answer in the defined variable.
- `lowercase`:  Same as input but changes the answer to lowercase.

### Important
StageDive scans your installed packages (pub-cache).  
This means StageDive recognizes only installed packages by default.
If you want to change this behaviour or if you want to test your templates before installing them
do the following:  

In your project folder, create `.stagedive/config.yaml`
```yaml
templatefolder: lib/_templates
```

or for multiple templates:
```yaml
templatefolder: 
    - lib/_templates
    - temp/_templates
```

With this - StageDive knows how to find your local templates!
 
### License
  
      Copyright 2015 Michael Mitterer (office@mikemitterer.at),
      IT-Consulting and Development Limited, Austrian Branch
  
      Licensed under the Apache License, Version 2.0 (the "License");
      you may not use this file except in compliance with the License.
      You may obtain a copy of the License at
  
         http://www.apache.org/licenses/LICENSE-2.0
  
      Unless required by applicable law or agreed to in writing,
      software distributed under the License is distributed on an
      "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
      either express or implied. See the License for the specific language
      governing permissions and limitations under the License.
  
  
If this plugin is helpful for you - please [(Circle)](http://gplus.mikemitterer.at/) me
or **star** this repo here on GitHub.



