table 6151533 "NPR Nc Endpoint"
{
    Caption = 'Nc Endpoint';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(20; "Endpoint Type"; Code[20])
        {
            Caption = 'Endpoint Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR Nc Endpoint Type";
        }
        field(30; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(40; "Setup Summary"; Text[100])
        {
            Caption = 'Setup Summary';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60; "Linked Endpoints"; Integer)
        {
            CalcFormula = Count("NPR Nc Endpoint Trigger Link" WHERE("Endpoint Code" = FIELD(Code)));
            Caption = 'Linked Endpoints';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    trigger OnInsert()
    begin
        SetupEndpoint();
    end;

    trigger OnRename()
    var
        RenamingNotAllwedErr: Label 'Renaming %1 is not allowed.', Comment = '%1="NPR Nc Endpoint"."TableCaption()"';
    begin
        Error(RenamingNotAllwedErr, TableCaption());
    end;

    procedure SetupEndpoint()
    begin
        if "Endpoint Type" = '' then
            if not ChooseEndpoint() then
                exit;
        OpenEndpointSetup();
    end;

    local procedure ChooseEndpoint(): Boolean
    var
        NcEndpointType: Record "NPR Nc Endpoint Type";
    begin
        NcEndpointType.Reset();
        if PAGE.RunModal(PAGE::"NPR Nc Endpoint Types", NcEndpointType) = ACTION::LookupOK then begin
            Validate("Endpoint Type", NcEndpointType.Code);
            exit(true);
        end else
            exit(false);
    end;

    local procedure OpenEndpointSetup()
    var
        Handled: Boolean;
        TextNoSetupErr: Label 'No setup is associated with %1 %2.', Comment = '%1=Rec.FieldCaption("Endpoint Type");%2=Rec."Endpoint Type"';
    begin
        TestField("Endpoint Type");
        Handled := false;
        OnOpenEndpointSetup(Handled);
        if not Handled then
            Error(TextNoSetupErr, Rec.FieldCaption("Endpoint Type"), Rec."Endpoint Type");
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnOpenEndpointSetup(var Handled: Boolean)
    begin
    end;
}

