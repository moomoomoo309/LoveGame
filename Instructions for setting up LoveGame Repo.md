#Instructions for setting up LoveGame Repo:


##Before setting up:
* Install git, using any of the following:
  * Git for Windows (has a bunch of extra shit, like a GUI and full BASH shell) https://git-for-windows.github.io/
  * GitHub Desktop (has even more extra shit, with better github integration) https://desktop.github.com/
  * Tortoise Git (Simple gui+git, nothing else, works as well as GitHub Desktop, but simpler) https://tortoisegit.org/
* Open a terminal and run git. If it isn't found, add it to your PATH environment variable:
  * Instructions: https://www.kb.wisc.edu/cae/page.php?id=24500  

---
##Sublime Text 2/3:
  * Install Package Control if it's not already installed. (Ctrl+shift+p, type package, if it shows up, you're good!)
	
  * Install the following packages:
     * SublimeLove (Love2D integration and build system)
     * GitSavvy (Git integration)
     * Floobits (Real-time collaboration)
	
  * Optional Packages I recommend, but you don't need: 
     * Restart (f5 to restart Sublime)
     * FormatLua (adds alt+l shortcut to format Lua code)
     * LuaSmartTips (adds auto-complete information for Lua code)
     * SidebarEnhancements (adds more options to the right click menu of files/folders in the sidebar)
	
  * Go to tools->build system, and switch it to Love.
	  * Press ctrl+shift+p, run git: clone, enter https://github.com/moomoomoo309/LoveGame as the URL.
	
  * Use these instructions to generate an access token for your GitHub account.
     * https://help.github.com/articles/creating-an-access-token-for-command-line-use/
	
  * Open a terminal, and cd into the directory of the repository.
     * If you don't know how to do this...you really should.
     * cd stands for "change directory", and will go from your current directory (to the left of your cursor) into the directory you specify.
     * For example, if you are in a folder called "home", and you want to access a subfolder called "sub", you run cd sub.
     * If you want to go to the parent folder, use .. to refer to the parent directory.
	
  * Run git config remote.origin.url "https://{token}@github.com/username/project.git"
     * Replace {token} with the token you generated on the GitHub site.
	
  * To make sure it works, hit ctrl+shift+p and run git: commit, and follow the instructions there.
     * Make the commit message something like "sublime text test commit"
     * Finally, hit ctrl+shift+p again, and run git: push.
     * Go to the repo at https://github.com/moomoomoo309/LoveGame and you should see your commit.  

---
##IntelliJ-based IDEs (PyCharm, IntelliJ, etc.):
  * Go to help->find action, and go to Plugins...
  * Click on "Browse additional repositories"
  * Search for and install the following:
    * Floobits
    * Lua
  * Install the love-IDEA-plugin using the instructions on the page.
     * https://github.com/rm-code/love-IDEA-plugin
  * Go to New->Project from Version Control->GitHub, and use the following URL.
     * https://github.com/moomoomoo309/LoveGame
		
