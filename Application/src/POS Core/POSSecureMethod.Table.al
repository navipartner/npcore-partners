table 6150725 "NPR POS Secure Method"
{
    Access = Internal;
    // NPR5.43/VB  /20180611  CASE 314603 Implemented secure method behavior functionality.
    // NPR5.46/TSA /20180914 CASE 314603 Added overflow protection in DiscoverSecureMethod()

    Caption = 'POS Secure Method';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Secure Methods";
    LookupPageID = "NPR POS Secure Methods";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Custom,Password Client,Password Server';
            OptionMembers = Custom,"Password Client","Password Server";
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Password Server will be the only choice in the future, implicitly';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label 'No subscriber responded to OnDiscoverCustomSecureMethodCode for %1 secure method.';

    procedure RunDiscovery()
    var
        CopyRec: Record "NPR POS Secure Method";
    begin
        CopyRec := Rec;
        Rec.DeleteAll();
        OnDiscoverSecureMethods();
        Rec := CopyRec;
        if not Rec.Find('=<>') then;
    end;

    procedure GetCustomMethodCode(): Text
    var
        Handled: Boolean;
        CustomCode: Text;
    begin
        if Type <> Type::Custom then
            exit('');

        OnDiscoverCustomSecureMethodCode(Code, CustomCode, Handled);
        if not Handled then
            Error(Text001, Code);
        exit(CustomCode);
    end;

    procedure DiscoverSecureMethod(ParamCode: Code[10]; ParamDescription: Text; Param: Option)
    begin
        Rec.Init();
        Rec.Code := CopyStr(ParamCode, 1, MaxStrLen(Rec.Code));
        Rec.Description := CopyStr(ParamDescription, 1, MaxStrLen(Rec.Description));
        Rec.Type := Param;
        if not Rec.Insert() then
            Rec.Modify();
    end;

    [BusinessEvent(TRUE)]
    local procedure OnDiscoverSecureMethods()
    begin
    end;

    [BusinessEvent(false)]
#pragma warning disable AA0150
    local procedure OnDiscoverCustomSecureMethodCode("Code": Code[10]; var CustomCode: Text; var Handled: Boolean)
#pragma warning restore    
    begin
    end;
}

