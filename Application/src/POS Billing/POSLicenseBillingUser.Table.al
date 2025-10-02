#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
table 6151229 "NPR POS License Billing User"
{
    Access = Internal;
    Caption = 'POS License Billing User';
    DataClassification = CustomerContent;
    LookupPageId = "NPR POS License Billing Users";
    DrillDownPageId = "NPR POS License Billing Users";
    DataCaptionFields = "User Security ID", "User Name";

    fields
    {
        field(1; "User Security ID"; Guid)
        {
            Caption = 'User Security ID';
            ToolTip = 'Specifies the unique security identifier for the user that will be counted as a POS licensed user.';
            TableRelation = User."User Security ID";
            NotBlank = true;

            trigger OnValidate()
            var
                UserRec: Record User;
            begin
                if (IsNullGuid(Rec."User Security ID")) then
                    exit;

                UserRec.Get(Rec."User Security ID");
            end;

            trigger OnLookup()
            var
                UserRec: Record User;
                UsersPage: Page Users;
            begin
                UserRec.Reset();
                UserRec.SetRange(State, UserRec.State::Enabled);
                UsersPage.SetTableView(UserRec);
                UsersPage.LookupMode(true);
                if (UsersPage.RunModal() = Action::LookupOK) then begin
                    UsersPage.GetRecord(UserRec);
                    Rec.Validate("User Security ID", UserRec."User Security ID");
                end;
            end;
        }

        field(2; "User Name"; Code[50])
        {
            Caption = 'User Name';
            ToolTip = 'Specifies the user name of the selected user.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup(User."User Name" where("User Security ID" = field("User Security ID")));
        }

        field(3; "Full Name"; Text[80])
        {
            Caption = 'Full Name';
            ToolTip = 'Specifies the full name of the selected user.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup(User."Full Name" where("User Security ID" = field("User Security ID")));
        }

        field(11; "Last Login (DateTime)"; DateTime)
        {
            Caption = 'Last Login';
            ToolTip = 'Specifies the last login date and time of the selected user.';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "User Security ID")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "User Name", "Full Name")
        {
        }
    }

    var
        DeleteLicenseQst: Label 'Are you sure you want to delete the POS license for user %1?', Comment = 'Delete POS License Confirmation Message. %1 = User Name';

    trigger OnDelete()
    var
        ConfirmMgt: Codeunit "Confirm Management";
    begin
        if (not ConfirmMgt.GetResponseOrDefault(StrSubstNo(DeleteLicenseQst, "User Name"))) then
            Error('');
    end;
}
#endif