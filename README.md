# Sorted Storage

This project provides users a sorted way to view their media and documents which are 
saved in cloud storage. 

## Getting Started

there are a few steps to get this project running locally: 
1. Google sign in only allows port 5000 from localhost so we need to run flutter web as follows:
```flutter run -d chrome --web-hostname localhost --web-port 5000```
2. You will need to create your own google api key  e.g. go to 
[Google credentials](https://console.cloud.google.com/apis/credentials) and 
create credentials -> API Key. 
Copy this API Key and replace ```GOOGLE_API_KEY``` in the constants.dart file

