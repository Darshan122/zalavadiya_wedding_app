@echo off
chcp 65001 > nul
echo ============================================================
echo   ઝાલાવડીયા પરિવાર - દર્શન weds બ્રિજળ GitHub Push Script
echo ============================================================
echo.

set /p REPO_URL="તમારી GitHub Repository ની URL લખો (દા.ત. https://github.com/Darshan122/zalavadiya_wedding_app.git): "

if "%REPO_URL%"=="" (
    echo [ERROR] URL ખાલી રાખી શકાતી નથી!
    pause
    exit /b 1
)

echo.
echo [1/4] Remote origin સેટ થઈ રહ્યું છે...
git remote remove origin 2>nul
git remote add origin %REPO_URL%

echo [2/4] 'dev' બ્રાન્ચમાં કોડ પુશ થઈ રહ્યો છે...
git checkout dev
git push -u origin dev
if errorlevel 1 (
    echo [ERROR] dev બ્રાન્ચ પુશ કરવામાં ભૂલ આવી. કૃપા કરીને તમારું ગીટહબ લોગિન ચેક કરો.
    pause
    exit /b 1
)

echo [3/4] 'main' બ્રાન્ચમાં કોડ પુશ થઈ રહ્યો છે...
git checkout main
git merge dev
git push -u origin main
if errorlevel 1 (
    echo [ERROR] main બ્રાન્ચ પુશ કરવામાં ભૂલ આવી.
    pause
    exit /b 1
)

echo.
echo ============================================================
echo   સફળતાપૂર્વક બંને બ્રાન્ચ (dev અને main) GitHub પર પુશ થઈ ગઈ!
echo ============================================================
git checkout dev
pause
