codeunit 6060022 "NPR WebServiceAuthHelp. Public"
{
    procedure GetApiPassword(APIPassGUID: Guid) PasswordValue: Text
    var
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        PasswordValue := WebServiceAuthHelper.GetApiPassword(APIPassGUID);
    end;

    procedure SetApiPassword(NewPassword: Text; var APIPassGUID: Guid)
    var
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        WebServiceAuthHelper.SetApiPassword(NewPassword, APIPassGUID);
    end;
}
