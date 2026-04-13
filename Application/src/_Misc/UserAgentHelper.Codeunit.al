codeunit 6151146 "NPR UserAgent Helper"
{
    Access = Internal;

    procedure GetUserAgentHeader(): Text
    begin
        exit('Microsoft-Dynamics-365-Business-Central-NP-Retail');
    end;
}
