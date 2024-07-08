codeunit 6151319 "NPR Base Data"
{
    Access = Internal;

    internal procedure GetBaseUrl(): Text
    begin
        exit('https://npretailbasedata.blob.core.windows.net');
    end;
}