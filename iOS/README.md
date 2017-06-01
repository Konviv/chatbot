[![N|Solid](https://avatars1.githubusercontent.com/u/25093065?v=3&s=400)](https://nodesource.com/products/nsolid)
# Steps
- clone the repository
- pod install `Make you that you pods repositories are updated`
# !IMPORTANT 
### Uploading the app on iTunes connect
##### RECOMENDATION
`Is strongly recommended make a commit before do this process because after run the script you can't run anymore the app on emulators`
The application works with a pod that allow to the user add banks, this pod works in devices and emulators, however when the application is ready to distribution you `must` run the script below, to delete all the computer processor architectures.
```sh
"${PROJECT_DIRECTORY}"/LinkKit.framework/prepare_for_distribution.sh"${CODESIGNING_FOLDER_PATH}"/Frameworks/LinkKit.framework/prepare_for_distribution.sh"${CODESIGNING_FOLDER_PATH}"/Frameworks/LinkKit.framework/prepare_for_distribution.sh
```
You only need to change the `${PROJECT_DIRECTORY}` to your project path directory like this 
```sh
"/Users/{project_path_directory}/chatbot/iOS/Konviv/Pods/Plaid/ios" 
```
the place where you are going to run this script is in `XCode`, so go the `Targets>Konviv` and select `Build Phases` you are going to see a list of items, open the one with the title `"Prepare for distribution"` and in the box `paste the code` then archive the project `product>archive` and follow all the steps to distribute the app as usual you do it, at the final of the process go to your terminal and `undo the changes` with 

```sh
$ git checkout .
```
