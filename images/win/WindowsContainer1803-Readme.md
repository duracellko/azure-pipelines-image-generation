# VSTS Windows Container(1803) image

The following software is installed on machines in the VSTS **Windows Container(1803)** pool.

Components marked with **\*** have been upgraded since the previous version of the image.


## Chocolatey

_Version:_ 0.10.11<br/>
_Environment:_
* PATH: contains location for choco.exe

## Docker

_Version:_ 17.06.2-ee-16<br/>
_Environment:_
* PATH: contains location of docker.exe

## Docker-compose

_Version:_ 1.22.0<br/>
_Environment:_
* PATH: contains location of docker-compose.exe

## Docker images

The following container images have been cached:
* microsoft/aspnetcore-build:(sha256:82ad5218bb554d0b44ca54c21aba78b5ae10b92cead389d71328614b99fc47af)
* microsoft/aspnet:(sha256:615b7779f5f9aed1cb87516a9423e5647e4970093eb53b327c8db69fb65b0af9)
* microsoft/dotnet-framework:(sha256:8b4faf59a1507a68c4e1f52c107b970e9db3a93d27dde1012773ad952e57f586)
* microsoft/windowsservercore:(sha256:11827f8ee0c02106489e553be170c083381ee362687f0ae097a2ac5482b72778)
* microsoft/nanoserver:(sha256:9749b36d953302ce1721fd47943e8fe7a0fddc87493c74a14e19e531e825937f)
* microsoft/windowsservercore:(sha256:06349a37774c52fd65cf87485ab7455e1745ea1f752da52bf4c1b1f44b242fb7)
* microsoft/nanoserver:(sha256:0b788ec819b0eb1c1f62677206fdb536eeba44d805cfcc21e7240e860eeeb5e0)

## Node.js

_Version:_ 8.11.4<br/>
_Environment:_
* PATH: contains location of node.exe<br/>

> Note: You can install and use another version of Node.js on Microsoft-hosted agent pools using the [Node tool installer](https://docs.microsoft.com/vsts/pipelines/tasks/tool/node-js) task.

## npm

_Version:_ 5.6.0<br/>
_Environment:_
* PATH: contains location of npm.cmd

## .NET Core

The following runtimes and SDKs are installed:

_Environment:_
* PATH: contains location of dotnet.exe

_SDK:_
* 2.1.401 C:\Program Files\dotnet\sdk\2.1.401
* 2.1.400 C:\Program Files\dotnet\sdk\2.1.400
* 2.1.4 C:\Program Files\dotnet\sdk\2.1.4
* 2.1.302 C:\Program Files\dotnet\sdk\2.1.302
* 2.1.301 C:\Program Files\dotnet\sdk\2.1.301
* 2.1.300 C:\Program Files\dotnet\sdk\2.1.300
* 2.1.202 C:\Program Files\dotnet\sdk\2.1.202
* 2.1.201 C:\Program Files\dotnet\sdk\2.1.201
* 2.1.200 C:\Program Files\dotnet\sdk\2.1.200
* 2.1.2 C:\Program Files\dotnet\sdk\2.1.2
* 2.1.105 C:\Program Files\dotnet\sdk\2.1.105
* 2.1.104 C:\Program Files\dotnet\sdk\2.1.104
* 2.1.103 C:\Program Files\dotnet\sdk\2.1.103
* 2.1.102 C:\Program Files\dotnet\sdk\2.1.102
* 2.1.101 C:\Program Files\dotnet\sdk\2.1.101
* 2.1.100 C:\Program Files\dotnet\sdk\2.1.100
* 2.0.3 C:\Program Files\dotnet\sdk\2.0.3
* 2.0.0 C:\Program Files\dotnet\sdk\2.0.0
* 1.1.9 C:\Program Files\dotnet\sdk\1.1.9
* 1.1.8 C:\Program Files\dotnet\sdk\1.1.8
* 1.1.7 C:\Program Files\dotnet\sdk\1.1.7
* 1.1.5 C:\Program Files\dotnet\sdk\1.1.5
* 1.1.4 C:\Program Files\dotnet\sdk\1.1.4
* 1.1.10 C:\Program Files\dotnet\sdk\1.1.10
* 1.0.4 C:\Program Files\dotnet\sdk\1.0.4
* 1.0.1 C:\Program Files\dotnet\sdk\1.0.1

_Runtime:_
* 2.1.3 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\2.1.3
* 2.1.2 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\2.1.2
* 2.1.1 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\2.1.1
* 2.1.0 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\2.1.0
* 2.0.9 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\2.0.9
* 2.0.7 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\2.0.7
* 2.0.6 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\2.0.6
* 2.0.5 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\2.0.5
* 2.0.3 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\2.0.3
* 2.0.0 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\2.0.0
* 1.1.9 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\1.1.9
* 1.1.8 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\1.1.8
* 1.1.7 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\1.1.7
* 1.1.6 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\1.1.6
* 1.1.5 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\1.1.5
* 1.1.4 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\1.1.4
* 1.1.2 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\1.1.2
* 1.1.1 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\1.1.1
* 1.0.9 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\1.0.9
* 1.0.8 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\1.0.8
* 1.0.7 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\1.0.7
* 1.0.5 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\1.0.5
* 1.0.4 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\1.0.4
* 1.0.12 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\1.0.12
* 1.0.11 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\1.0.11
* 1.0.10 C:\Program Files\dotnet\shared\Microsoft.NETCore.App\1.0.10

## Git

_Version:_ 2.18.0<br/>
_Environment:_
* PATH: contains location of git.exe

## Git LFS

_Version:_ 2.4.2<br/>
_Environment:_
* PATH: contains location of git-lfs.exe
* GIT_LFS_PATH: location of git-lfs.exe

## Subversion

_Version:_ 1.8.17<br/>
_Environment:_
* PATH: contains location of svn.exe
