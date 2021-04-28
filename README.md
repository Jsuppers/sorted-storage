![Flutter Web Workflow](https://github.com/Jsuppers/sorted-storage/workflows/Flutter%20Web/badge.svg)
[![codecov](https://codecov.io/gh/Jsuppers/sorted-storage/branch/main/graph/badge.svg?branch=master)](https://codecov.io/gh/Jsuppers/sorted-storage)
[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)


![](assets/images/logo_tiny.png)


This project provides users a sorted way to view their media and documents which are 
saved in cloud storage. It is hosted on [sortedstorage.com](https://sortedstorage.com)
 
### Getting Started

there are a few steps to get this project running locally: 
1. create a .env file in the root directory with ```GOOGLE_API_KEY``` which should hold a google api key which can be created
from [Google credentials](https://console.cloud.google.com/apis/credentials) (create credentials -> API Key).
<br/> **recommended** restrict the api key
2. Generate envify file: <br/> ```flutter pub run build_runner build```
3. Google sign in only allows port 5000 from localhost so we need to run flutter web as follows: <br/>
```flutter run -d chrome --web-hostname localhost --web-port 5000```

### Testing
1. ```flutter test --coverage```
4. ```genhtml coverage/lcov.info -o coverage --no-source``` If you don't have genhtml: <br/>
    - ```sudo apt-get update -qq -y``` <br/>
    - ```sudo apt-get install lcov -y``` <br/>

Then you can open the file coverage/index.html

### Useful commands
1. dart analyze
2. dart format --fix .
3. flutter pub run import_sorter:main

