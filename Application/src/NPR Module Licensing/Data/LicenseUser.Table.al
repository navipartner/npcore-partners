table 6150659 "NPR License User"
{
    Access = Internal;
    DataPerCompany = false;
    Caption = 'NPR License User';
    DataClassification = CustomerContent;
    LookupPageId = "NPR Licensed Users";
    DrillDownPageId = "NPR Licensed Users";
    DataCaptionFields = "User Security ID", "User Name";

    fields
    {
        field(1; "User Security ID"; Guid)
        {
            Caption = 'User Security ID';
            ToolTip = 'Specifies the user that holds this module license.';
            TableRelation = User."User Security ID";
            NotBlank = true;

            trigger OnLookup()
            var
                UserRec: Record User;
                UsersPage: Page Users;
            begin
                UserRec.SetRange(State, UserRec.State::Enabled);
                UsersPage.SetTableView(UserRec);
                UsersPage.LookupMode(true);
                if UsersPage.RunModal() = Action::LookupOK then begin
                    UsersPage.GetRecord(UserRec);
                    Validate("User Security ID", UserRec."User Security ID");
                end;
            end;

            trigger OnValidate()
            var
                UserRec: Record User;
            begin
                if IsNullGuid(Rec."User Security ID") then
                    exit;

                UserRec.Get(Rec."User Security ID");
                Rec.Status := Rec.Status::Pending;
                Rec."License Term" := Rec."License Term"::_;
            end;
        }
        field(2; "User Name"; Code[50])
        {
            Caption = 'User Name';
            ToolTip = 'Specifies the user name of the selected user.';
            FieldClass = FlowField;
            CalcFormula = lookup(User."User Name" where("User Security ID" = field("User Security ID")));
            Editable = false;
        }
        field(3; "Full Name"; Text[80])
        {
            Caption = 'Full Name';
            ToolTip = 'Specifies the full name of the selected user.';
            FieldClass = FlowField;
            CalcFormula = lookup(User."Full Name" where("User Security ID" = field("User Security ID")));
            Editable = false;
        }
        field(4; Module; Enum "NPR License Module")
        {
            Caption = 'Module';
            ToolTip = 'Specifies the module this license applies to.';
            NotBlank = true;
        }
        field(5; Status; Enum "NPR License User Status")
        {
            Caption = 'Status';
            ToolTip = 'Specifies the status of this license.';
            Editable = false;

            trigger OnValidate()
            var
                ChangeDateTime: DateTime;
            begin
                if Rec.Status = xRec.Status then
                    exit;

                ChangeDateTime := CurrentDateTime();
                Rec."Status Changed At" := ChangeDateTime;
                case Rec.Status of
                    Rec.Status::Active:
                        begin
                            Rec.TestField("License Term");
                            Rec."Activated At" := ChangeDateTime;
                            Rec."Activated By" := UserSecurityId();
                        end;
                    Rec.Status::DisabledManually, Rec.Status::SuspendedAutomatically:
                        begin
                            Rec."Deactivated At" := ChangeDateTime;
                            Rec."Deactivated By" := UserSecurityId();
                        end;
                end;
            end;
        }
        field(6; "Activated At"; DateTime)
        {
            Caption = 'Activated At';
            ToolTip = 'Specifies when the license was activated.';
            Editable = false;
        }
        field(7; "Activated By"; Guid)
        {
            Caption = 'Activated By';
            ToolTip = 'Specifies who activated the license.';
            Editable = false;
            TableRelation = User."User Security ID";
        }
        field(8; "Activated By Name"; Text[80])
        {
            Caption = 'Activated By Name';
            ToolTip = 'Specifies the name of the user who activated the license.';
            FieldClass = FlowField;
            CalcFormula = lookup(User."Full Name" where("User Security ID" = field("Activated By")));
            Editable = false;
        }
        field(9; "Deactivated At"; DateTime)
        {
            Caption = 'Deactivated At';
            ToolTip = 'Specifies when the license was deactivated.';
            Editable = false;
        }
        field(10; "Deactivated By"; Guid)
        {
            Caption = 'Deactivated By';
            ToolTip = 'Specifies who deactivated the license.';
            Editable = false;
            TableRelation = User."User Security ID";
        }
        field(11; "Deactivated By Name"; Text[80])
        {
            Caption = 'Deactivated By Name';
            ToolTip = 'Specifies the name of the user who deactivated the license.';
            FieldClass = FlowField;
            CalcFormula = lookup(User."Full Name" where("User Security ID" = field("Deactivated By")));
            Editable = false;
        }
        field(12; "Last Login (DateTime)"; DateTime)
        {
            Caption = 'Last Login';
            ToolTip = 'Specifies the last login of the user.';
            Editable = false;
        }
        field(13; "License Term"; Enum "NPR License Term")
        {
            Caption = 'License Term';
            ToolTip = 'Specifies the license term assigned to the user.';
            NotBlank = true;

            trigger OnValidate()
            begin
                if (Rec."License Term" <> xRec."License Term") and (Rec.Status = Rec.Status::Active) then
                    Error(CannotChangeLicTypeWhenActiveErr);
            end;
        }
        field(14; "Status Changed At"; DateTime)
        {
            Caption = 'Status Changed At';
            ToolTip = 'Specifies when the status last changed.';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "User Security ID", Module)
        {
            Clustered = true;
        }
        key(StatusChangeKey; Module, "License Term", Status, "Status Changed At")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "User Name", "Full Name", Module, Status, "License Term")
        {
        }
    }

    var
        DeleteLicenseQst: Label 'Are you sure you want to delete the %1 license for user %2?', Comment = '%1 = Module, %2 = User Name';
        ActionCanceledByUserErr: Label 'Action canceled by user.';
        CannotChangeLicTypeWhenActiveErr: Label 'You cannot change the license term for an active user. Please deactivate the user first.';
        CannotDeleteActiveErr: Label 'You cannot delete an active license. Please deactivate the user first.';

    trigger OnDelete()
    var
        ConfirmMgt: Codeunit "Confirm Management";
    begin
        if Rec.Status = Rec.Status::Active then
            Error(CannotDeleteActiveErr);

        // Allow deletion only when running UI session here, otherwise write a dedicated function to delete the licenses (e.g. cleanup task).
        if not GuiAllowed() then
            exit;

        Rec.CalcFields("User Name");
        if not ConfirmMgt.GetResponseOrDefault(StrSubstNo(DeleteLicenseQst, Rec.Module, Rec."User Name"), false) then
            Error(ActionCanceledByUserErr);
    end;
}
