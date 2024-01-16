
# Using Github

## Why Git and Github?

Git is a version control system that enables you to track the history of your files and to share them with others. Github  is a cloud-based platform that allows you to share these files and easily synchronize them. For example, I can push new lectures to Github and you can pull them onto your computer with a click of a button.

There are several benefits of these tools. First, it is a convenient way to share course materials and assignments. Second, it will help you to manage and keep track of your projects, which can easily become unwieldy. Third, it will encourage you to develop a reproducible workflow, helping to improve transparency in social scientific research. Fourth, the open-source software we will be using in class is all maintained via Github. Knowledge of how the platform works will make it easier for you to understand this software and potentially contribute to it.

Github is not intended for storage of large files. You should use another service like Google Drive or Box for this purpose. And be careful what you share. By default, most repositories are public, so ensure not to share sensitive data or credentials.

## Setting up Git and Github

Follow these steps to get a Github account, install and set up Git on your computer, integrate it with RStudio, and verify that it is working. The process should take approximately half an hour to complete, although there are always things that go wrong.

I strongly recommend browsing the resources below and familiarizing yourself with Git and Github before proceeding. If you get stuck at any point, there are plenty of resources to assist, but feel free to reach out with any questions.

1. Set up an account on Github https://github.com (we will be using the free version so no need to pay).

2. Install Git on your computer following instructions here https://github.com/git-guides/install-git.

Please note that the instructions vary depending on your operating system. If you are using MacOS then you may have Github installed already. 

3. Now you have Git on your computer. You need to run a command in R to associate it with the account you set up in Step 1.

Luckily there is an R package to help you do this All you need to do is install the following package and run this command in the R console (replacing the username and email address).

```
install.package("usethis")
library(usethis)
use_git_config(user.name = "t-davidson", user.email = "thomas.davidson@rutgers.edu")
```

4. At this point Git is set up on your computer.  Proceed to Step 5, but if you find you have an access or permission error then you may need to complete this step:

Follow these instructions to generate and store an access token: https://happygitwithr.com/https-pat.html

5. Finally, you can use Github to get the latest version of all the course files (including this one!) on your computer.

Return to RStudio and click the `File` tab at the top of the page and select `New Project...` from the dropdown. This will open up the project wizard. Click the `Version Control` option then `Git`. Paste the URL for this project (https://github.com/t-davidson/computational-sociology/blob/main/2024/course-materials/github_setup.md) into the Repository URL box and select an appropriate directory to store it (this is where the files will all live). When you're ready, click `Create Project`

You will see a window pop up and then you will return to RStudio when the process is completed. If you look in the `Files` pane you should see the files from the course. You should also see a tab titled `Git` at the top. Now, whenever there is an update to the course, all you need to do is click the downwards facing green arrow to "pull" the files onto your computer.

## Next steps

I recommend trying to set up a repository to test it out and learn some core functionality.

Set up a new repository on the Github website, clone it using RStudio, then commit and push a change, before verifying it on the website. You will need to do this for your final project so you might want to call the repository something related, e.g. "computational-project"

Follow the instructions here: https://happygitwithr.com/rstudio-git-github.html

## Using Github for homework assignments

We will be using something called Github Classroom for the homework assignments. Each homework assignment will be a separate Github repository, where each student gets a personal version. You will need to clone this repository using the same process as in Step 6. You can then submit your solutions by committing changes and pushing them to your repository.

### How to commit changes to the homework

- Save the files you want to update
- Navigate to the Git tab in RStudio and click the check-box for the file then click `Commit`
- A dialogue box will open. Add a short message to the `Commit message` box, then click the `Commit` button again.
- Finally, click the `Push` button with the upwards arrow to send the change to your cloud-based repository
- Visit the Github webpage for your homework repository and you should see your commit message next to the file name, showing it is updated.

You can commit as many times as you want. I recommend testing this process our before your final submission.

For the final submission, please use the commit message indicated at the bottom of the `.Rmd` file to confirm.

## On projects

Over the course of the semester you will likely have multiple different Github repositories (main course repo, homeworks, papers).

The simplest way to open a project is to open the `.RProj` file located in each folder or to use the dropdown menu in RStudio to open projects.

You can learn more about projects in the *R for Data Science* book: https://r4ds.had.co.nz/workflow-projects.html

## Resources

There are a ton of videos on YouTube, from short explainers to multi-hour marathons
Some of the instructions here are part of detailed guide to all you could every want to know about RStudio and Github https://happygitwithr.com/index.html
Github provides guides and lots of documentation on its website https://github.com/git-guides
Github cheatsheet (multilingual) https://training.github.com/

## Student developer pack
Students can get free access to some premium features by signing up for the Student Developer Pack: https://education.github.com/pack. It is not essential for our purposes, but I highly recommend doing so. The most clear perk is the ability to create private repositories.
