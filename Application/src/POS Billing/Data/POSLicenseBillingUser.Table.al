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
                LicenseTypeOrdinal: Integer;
            begin
                if (IsNullGuid(Rec."User Security ID")) then
                    exit;

                UserRec.Get(Rec."User Security ID");

                Rec.Status := Rec.Status::Pending;
                SyncLicenseTypeAllowances();
                IF (LicenseTypeAllowances.Count = 1) then begin
                    LicenseTypeAllowances.Keys().Get(1, LicenseTypeOrdinal);
                    Rec.Validate("License Type", LicenseTypeOrdinal);
                end;
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
        field(4; Status; Enum "NPR POS Lic. Bill. User Status")
        {
            Caption = 'Status';
            ToolTip = 'Specifies the status of the selected user.';
            Editable = false;

            trigger OnValidate()
            var
                ChangeDateTime: DateTime;
            begin
                ChangeDateTime := CurrentDateTime();

                if (Rec."Status" <> xRec."Status") then begin
                    Rec.Validate("Status Changed At", ChangeDateTime);

                    case Rec."Status" of
                        Rec."Status"::Active:
                            begin
                                Rec.TestField("License Type");
                                Rec.Validate("Activated At", ChangeDateTime);
                                Rec.Validate("Activated By", UserSecurityId());
                            end;
                        Rec."Status"::DisabledManually, Rec.Status::SuspendedAutomatically:
                            begin
                                Rec.Validate("Deactivated At", ChangeDateTime);
                                Rec.Validate("Deactivated By", UserSecurityId());
                            end;
                    end;
                end;
            end;
        }
        field(5; "Activated At"; DateTime)
        {
            Caption = 'Activated At';
            ToolTip = 'Specifies the date and time when the selected user was activated.';
            Editable = false;
        }
        field(6; "Activated By"; Guid)
        {
            Caption = 'Activated By';
            ToolTip = 'Specifies the user who activated the selected user.';
            Editable = false;
            TableRelation = User."User Security ID";
        }
        field(7; "Activated By Name"; Text[80])
        {
            Caption = 'Activated By Name';
            ToolTip = 'Specifies the name of the user who activated the selected user.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup(User."Full Name" where("User Security ID" = field("Activated By")));
        }
        field(8; "Deactivated At"; DateTime)
        {
            Caption = 'Deactivated At';
            ToolTip = 'Specifies the date and time when the selected user was deactivated.';
            Editable = false;
        }
        field(9; "Deactivated By"; Guid)
        {
            Caption = 'Deactivated By';
            ToolTip = 'Specifies the user who deactivated the selected user.';
            Editable = false;
            TableRelation = User."User Security ID";
        }
        field(10; "Deactivated By Name"; Text[80])
        {
            Caption = 'Deactivated By Name';
            ToolTip = 'Specifies the name of the user who deactivated the selected user.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = Lookup(User."Full Name" where("User Security ID" = field("Deactivated By")));
        }
        field(12; "License Type"; Enum "NPR POS Lic. Billing Lic. Type")
        {
            Caption = 'License Type';
            ToolTip = 'Specifies the license type of the selected user.';
            Editable = true;
            NotBlank = true;

            trigger OnValidate()
            begin
                if (Rec."License Type" <> xRec."License Type") then
                    if (Rec.Status = Rec.Status::Active) then
                        Error(CannotChangeLicTypeWhenActiveErr);
            end;
        }
        field(13; "Status Changed At"; DateTime)
        {
            Caption = 'Status Changed At';
            ToolTip = 'Specifies the date and time when the status of the selected user was changed.';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "User Security ID")
        {
            Clustered = true;
        }
        key(StatusChangeKey; "License Type", Status, "Status Changed At")
        {
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
        CannotChangeLicTypeWhenActiveErr: Label 'You cannot change the license type for an active user. Please deactivate the user first.';
        CouldNotVerifyLicenseErr: Label 'Could not verify license information with the license server. Please try again later.';
        ActionCanceledByUserErr: Label 'Action canceled by user.';
        LicenseTypeAllowances: Dictionary of [Integer, Integer];
        LicenseTypeAllowancesInitialized: Boolean;

    trigger OnDelete()
    var
        ConfirmMgt: Codeunit "Confirm Management";
    begin
        Rec.CalcFields("User Name");
        if (not ConfirmMgt.GetResponseOrDefault(StrSubstNo(DeleteLicenseQst, Rec."User Name"))) then
            Error(ActionCanceledByUserErr);
    end;

    local procedure SyncLicenseTypeAllowances()
    var
        POSLicenseBillingMgt: Codeunit "NPR POS License Billing Mgt.";
        LicenseTypeAllowancesSyncedFromPOSBillingAPI: Boolean;
    begin
        if (not LicenseTypeAllowancesInitialized) then begin
            LicenseTypeAllowances := POSLicenseBillingMgt.GetAllowanceDictionaryPerLicenseType(LicenseTypeAllowancesSyncedFromPOSBillingAPI);
            if (not LicenseTypeAllowancesSyncedFromPOSBillingAPI) then
                Error(CouldNotVerifyLicenseErr);

            LicenseTypeAllowancesInitialized := true;
        end;
    end;
}
#endif