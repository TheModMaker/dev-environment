:: Copyright 2023 Jacob Trimble
::
:: Licensed under the Apache License, Version 2.0 (the "License");
:: you may not use this file except in compliance with the License.
:: You may obtain a copy of the License at
::
::     http://www.apache.org/licenses/LICENSE-2.0
::
:: Unless required by applicable law or agreed to in writing, software
:: distributed under the License is distributed on an "AS IS" BASIS,
:: WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
:: See the License for the specific language governing permissions and
:: limitations under the License.

@echo off

set "THIS_DIR=%~dp0"
set "THIS_DIR=%THIS_DIR:\=/%"

set "VIMDIR=%localappdata%/nvim"
for %%a in (autoload,swap,backup) do (
  if not exist "%VIMDIR%/%%a" (mkdir "%VIMDIR%/%%a")
)

:: Copy over config files
call :handle_template "%THIS_DIR%/gitconfig.in" "%userprofile%/.gitconfig"
call :handle_template "%THIS_DIR%/vimrc.in" "%VIMDIR%/init.vim"

:: Install deps
winget install Neovim.Neovim

:: Install (neo)vim plugins
set PLUG_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
if not exist "%VIMDIR%/autoload/plug.vin" (
  powershell -Command "Invoke-WebRequest '%PLUG_URL%' -OutFile '%VIMDIR%/autoload/plug.vim'"
)
nvim -es -i NONE -c PlugInstall -c qa

exit /b %errorlevel%


:handle_template
if exist %2 (
  set /p "do_copy=Overwrite existing %~nx2 (y/N): "
) else (
  set do_copy=y
)
if /i "%do_copy%"=="y" (
  :: Use Powershell to edit the file so we can search-and-replace easily
  powershell -Command "(gc '%~1') -replace '{{BASE_DIR}}', '%THIS_DIR%' | Out-File -encoding ASCII '%~2'"
)
exit /b 0
