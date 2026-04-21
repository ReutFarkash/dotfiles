

# Ideas: https://lore.kernel.org/git/YHofmWcIAidkvJiD@google.com/

# git submodule update
# git submodule status
# git submodule update --remote
# git submodule foreach 'git branch'
# lazygit "some message"
# git submodule foreach 'git fetch'
# graph_submodules


# gs_clone


## begin working on a feature:
# git switch -c feature  # since the new branch is being created, a new branch 'feature' will be created for each submodule, pointing to the submodule's current 'HEAD'


# gs_commit  # when in a submodule: commit, in super switch to corrosponding branch (stash?), in super add submodule, in super commit "submodule <name> commit: <same message / altered message if flaged>", return to original state in super (branch / stash... ?)  # what about other files added in super?  # What about commiting multiple submodules?

# gs_push  # similar to gs_commit  # consider the need to push other submodules from previous commits that affected super  -> would use gs_super_push to push all submodules required by state of super

# what if git switch other-feature only envolves some of the submodules? create relevent vranches and earase them if they are not used?



