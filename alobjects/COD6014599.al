codeunit 6014599 "Connection Profile Management"
{

    trigger OnRun()
    begin
    end;

    procedure GetCreditCardExtension(): Text[50]
    var
        ConnectionProfile: Record "Connection Profile";
        RetailSetup: Record "Retail Setup";
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId) and (UserSetup."Connection Profile Code" <> '') then begin
          ConnectionProfile.Get(UserSetup."Connection Profile Code");
          if ConnectionProfile."Credit Card Extension" <> '' then
            exit(ConnectionProfile."Credit Card Extension")
        end;

        RetailSetup.Get;
        exit(RetailSetup."Credit Card Extension")
    end;

    procedure GetHostingType(): Integer
    var
        ConnectionProfile: Record "Connection Profile";
        RetailSetup: Record "Retail Setup";
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId) and (UserSetup."Connection Profile Code" <> '') then begin
          ConnectionProfile.Get(UserSetup."Connection Profile Code");
          exit(ConnectionProfile."Hosting type")
        end;

        RetailSetup.Get;
        exit(RetailSetup."Hosting type")
    end;
}

