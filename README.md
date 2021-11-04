# RAP Auction model
Auction model powered by ABAP RESTful programming model. Project has simple structure of business objects(BO) and uses standard features provided by RAP.
There you can find implementation of common RAP tasks.
## How to launch and test this project?
The most convenient way to test the project and explore the code is to clone this project into your system (Steampunk or On-Premise).
To clone use [abapGit](https://docs.abapgit.org/guide-install.html) - tool to enable Git while developing your ABAP objects.
### Humble step-by-step instructure
1. [Install](https://help.sap.com/viewer/65de2977205c403bbc107264b8eccf4b/Cloud/en-US/2002380aeda84875a5fae4adc66b3fdb.html) abapGit for ADT
2. With installed abapGit (in Eclipse) go to Window->Show view->Other... and select *abapGit Repositories*
3. Please create new package (and trasnport if you like), where cloned project will take place.
4. Copy link of the repository to clone from the code section: ```https://github.com/tsudd/rap-auction-model.git```
5. Go back to eclipse and press button ```Link New abapGit repository``` in *abapGit Repositories* window
6. New form will appear, paste copied link and proceed
7. Select previosly created package and input other required info
8. Congrats! You've cloned the project to your system and it ready to be executed and reviewed

**P. S.** While using abapGit in Eclipse it may ask you to authorize using GitHub account. In that case you definitely should use personal access token rather than password.
Check out [this](https://catalyst.zoho.com/help/tutorials/githubbot/generate-access-token.html) instructure to generate one, then copy it and
paste in the password input box. 
