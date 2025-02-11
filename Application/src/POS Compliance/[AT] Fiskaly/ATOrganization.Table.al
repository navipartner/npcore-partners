table 6150830 "NPR AT Organization"
{
    Access = Internal;
    Caption = 'AT Organization';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR AT Organization List";
    LookupPageId = "NPR AT Organization List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "FON Authentication Status"; Enum "NPR AT FON Auth. Status")
        {
            Caption = 'FinanzOnline Authentication Status';
            DataClassification = CustomerContent;
            Editable = false;

            trigger OnValidate()
            begin
                Clear("FON Authenticated At");
            end;
        }
        field(21; "FON Authenticated At"; DateTime)
        {
            Caption = 'FinanzOnline Authenticated At';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        ATSCU: Record "NPR AT SCU";
        CannotDeleteErr: Label 'You cannot delete %1 %2 since there is at least one related %3 which has been already sent to Fiskaly. You must delete this record(s) first.', Comment = '%1 - AT Organization table caption, %2 - AT Organization Code field value, %3 - AT SCU table caption';
    begin
        ATSCU.SetRange("AT Organization Code", Code);
        ATSCU.FilterGroup(-1);
        ATSCU.SetFilter("Pending At", '<>%1', 0DT);
        ATSCU.SetFilter("Created At", '<>%1', 0DT);
        ATSCU.FilterGroup(0);
        if not ATSCU.IsEmpty() then
            Error(CannotDeleteErr, TableCaption(), Code, ATSCU.TableCaption());
    end;

    internal procedure GetWithCheck(ATOrganizationCode: Code[20])
    begin
        Get(ATOrganizationCode);
        TestField("FON Authentication Status", "FON Authentication Status"::AUTHENTICATED);
    end;

    internal procedure GetAPIKeyName(): Text
    begin
        if IsNullGuid(SystemId) then
            exit('');

        exit('ATFiskalyAPIKey_' + SystemId);
    end;

    internal procedure GetAPISecretName(): Text
    begin
        if IsNullGuid(SystemId) then
            exit('');

        exit('ATFiskalyAPISecret_' + SystemId);
    end;

    internal procedure CheckIsFONAuthenticationStatusNotAuthenticated()
    var
        FONAuthenticationStatusErr: Label '%1 must not be %2 for %3 %4.', Comment = '%1 - FON Authentication Status field caption, %2 - FON Authentication Status field value, %3 - Code field caption, %4 - Code field value';
    begin
        if "FON Authentication Status" = "FON Authentication Status"::AUTHENTICATED then
            Error(FONAuthenticationStatusErr, FieldCaption("FON Authentication Status"), "FON Authentication Status", FieldCaption(Code), Code);
    end;
}
