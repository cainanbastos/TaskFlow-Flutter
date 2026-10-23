@echo off
cd /d "%~dp0"
where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter nao encontrado no PATH. Abra a pasta no terminal com Flutter configurado.
  pause
  exit /b 1
)
call flutter create --platforms=android --project-name taskflow_flutter .
if errorlevel 1 goto erro
call flutter pub get
if errorlevel 1 goto erro
call flutter analyze
if errorlevel 1 goto erro
call flutter test
if errorlevel 1 goto erro
echo.
echo Projeto preparado. Conecte seu tablet e execute flutter run.
pause
exit /b 0
:erro
echo Verifique a mensagem acima. Nenhuma permissao de administrador e necessaria.
pause
exit /b 1
