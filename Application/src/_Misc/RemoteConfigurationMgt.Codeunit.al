codeunit 6014529 "NPR Remote Configuration Mgt."
{
    procedure DisableTaskQueue()
    var
        TaskLine: Record "NPR Task Line";
    begin
        TaskLine.SetRange(Enabled, true);
        if TaskLine.FindSet() then
            repeat
                TaskLine.Validate(Enabled, false);
                TaskLine.Modify(true);
            until TaskLine.Next() = 0;
    end;

    procedure SetCompanyName(Name: Text)
    var
        CompanyInformation: Record "Company Information";
    begin
        if not CompanyInformation.Get() then
            CompanyInformation.Insert();
        CompanyInformation.Name := Name;
        CompanyInformation.Modify();
    end;

    procedure SetCVRNo(CVRNo: Text)
    var
        CompanyInformation: Record "Company Information";
    begin
        if not CompanyInformation.Get() then
            CompanyInformation.Insert();
        CompanyInformation."VAT Registration No." := CVRNo;
        CompanyInformation.Modify();
    end;

    procedure SetUserLanguage(UserIDAndLanguageID: Text)
    var
        User: Record User;
        UserPersonalization: Record "User Personalization";
        String: Codeunit "NPR String Library";
        RetailLbl: Label 'RETAIL';
    begin
        String.Construct(UserIDAndLanguageID);

        User.SetRange("User Name", String.SelectStringSep(1, ';'));
        User.FindFirst();
        UserPersonalization.SetRange("User SID", User."User Security ID");
        if not UserPersonalization.FindFirst then begin
            UserPersonalization."User SID" := User."User Security ID";
            UserPersonalization."Profile ID" := RetailLbl;
            UserPersonalization.Insert();
        end;

        Evaluate(UserPersonalization."Language ID", String.SelectStringSep(2, ';'));
        UserPersonalization.Modify();
    end;
}

