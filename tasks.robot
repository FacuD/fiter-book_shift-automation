*** Settings ***
Documentation       Robot to reserve a shift for the Fiter gym

Library             RPA.Browser.Selenium
Library             RPA.Email.ImapSmtp    smtp_server=smtp.gmail.com    smtp_port=587
Library             re
Library             DateTime
Library             Collections
Library             RPA.Robocorp.Vault
# Library    ImapLibrary2


*** Variables ***
${URL}          https://turni.to/fiter
${URL_REGEX}    http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+


*** Tasks ***
Reservate turn
    Open Turnito
    Select Today Turn
    Confirm Reservation On Gmail


*** Keywords ***
Open Turnito
    Open Available Browser    ${URL}    browser_selection=chrome

Select Today Turn
    ${currentDate}    Get Format Today Date    %Y-%m-%d
    Click Button    xpath://button[@data-cy='book']
    Click Link    Fiter Almagro
    Click Link    Acceso a Sucursal
    Wait Until Element Is Enabled    xpath://a[@data-cy='date-${currentDate}']
    Click Link    xpath://a[@data-cy='date-${currentDate}']
    Wait Until Element Is Enabled    xpath://a[@data-cy='slot-${currentDate}T07:00']
    Click Link    xpath://a[@data-cy='slot-${currentDate}T07:00']
    Click Button    xpath://button[@data-cy='complete']
    Wait Until Element Is Enabled    name=email
    ${gmail}    Get Secret Value    gmail
    Input Text    name=email    ${gmail}
    Click Button    xpath://button[@type="submit"]

Confirm Reservation On Gmail
    ${link}    Get Email Link
    Go To    url=${link}
    Wait Until Page Contains Element    css:span.ACCEPTED
    Capture Page Screenshot    result.png
    [Teardown]    Close Browser

Get Email Link
    ${currentDate}    Get Format Today Date    %d-%b-%Y
    ${gmail}    Get Secret Value    gmail
    ${gmailPassword}    Get Secret Value    password
    Authorize    account=${gmail}    password=${gmailPassword}
    @{emails}    Wait For Message
    ...    SUBJECT "Confirma tu reserva" UNSEEN SENTON ${currentDate}
    ...    timeout=30
    ...    interval=1
    Delete Message    SUBJECT "Confirma tu reserva" UNSEEN SENTON ${currentDate}
    ${emailBody}    Get From Dictionary    ${emails[0]}    Body
    @{links}    re.findall    ${URL_REGEX}    ${emailBody}
    RETURN    ${links[2]}

Get Format Today Date
    [Arguments]    ${format}
    ${currentDate}    Get Current Date    result_format=${format}
    RETURN    ${currentDate}

Get Secret Value
    [Arguments]    ${key}
    ${credentials}    Get secret    credentials
    RETURN    ${credentials}[${key}]
