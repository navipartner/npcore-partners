codeunit 6014529 "NPR Remote Configuration Mgt."
{
    // NPR4.02/MH/20150325  CASE 207206 Added function for Disabling Task Queue Lines


    trigger OnRun()
    begin
    end;

    procedure DisableTaskQueue()
    var
        TaskLine: Record "NPR Task Line";
    begin
        //-NPR4.02
        TaskLine.SetRange(Enabled, true);
        if TaskLine.FindSet then
            repeat
                TaskLine.Validate(Enabled, false);
                TaskLine.Modify(true);
            until TaskLine.Next = 0;
        //+NPR4.02
    end;

    procedure SetCompanyName(Name: Text)
    var
        CompanyInformation: Record "Company Information";
    begin
        if not CompanyInformation.Get then CompanyInformation.Insert;
        CompanyInformation.Name := Name;
        CompanyInformation.Modify;
    end;

    procedure SetCVRNo(CVRNo: Text)
    var
        CompanyInformation: Record "Company Information";
    begin
        if not CompanyInformation.Get then CompanyInformation.Insert;
        CompanyInformation."VAT Registration No." := CVRNo;
        CompanyInformation.Modify;
    end;

    procedure SetUserLanguage(UserIDAndLanguageID: Text)
    var
        User: Record User;
        UserPersonalization: Record "User Personalization";
        String: Codeunit "NPR String Library";
    begin
        String.Construct(UserIDAndLanguageID);

        User.SetRange("User Name", String.SelectStringSep(1, ';'));
        User.FindFirst;
        UserPersonalization.SetRange("User SID", User."User Security ID");
        if not UserPersonalization.FindFirst then begin
            UserPersonalization."User SID" := User."User Security ID";
            UserPersonalization."Profile ID" := 'RETAIL';
            UserPersonalization.Insert;
        end;

        Evaluate(UserPersonalization."Language ID", String.SelectStringSep(2, ';'));
        UserPersonalization.Modify;
    end;
}

