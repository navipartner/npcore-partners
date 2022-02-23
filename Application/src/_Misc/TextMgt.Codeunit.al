codeunit 6014494 "NPR Text Mgt."
{
    Access = Internal;

    procedure GetSecretFailedErr(): Text
    var
        GetSecretFailedLbl: Label 'Failed to retrieve Azure KeyVault secret %1', Comment = '%1 = Azure KeyVault secret name';
    begin
        exit(GetSecretFailedLbl);
    end;
}