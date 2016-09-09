#!/bin/bash

# https://developer.apple.com/library/mac/releasenotes/DeveloperTools/RN-MallocOptions/
export MallocGuardEdges=1
export MallocScribble=1
export MallocCheckHeapStart=0
export MallocCheckHeapEach=1000 # default
export MallocCheckHeapAbort=1
export MallocErrorAbort=1s

export MallocPreScribble=1
export MallocScribble=1