table 6151533 "Nc Endpoint"
{
    // NC2.01\BR\20160921  CASE 248630 Object created

    Caption = 'Nc Endpoint';

    fields
    {
        field(10;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(20;"Endpoint Type";Code[20])
        {
            Caption = 'Endpoint Type';
            TableRelation = "Nc Endpoint Type";
        }
        field(30;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(40;"Setup Summary";Text[100])
        {
            Caption = 'Setup Summary';
            Editable = false;
        }
        field(50;Enabled;Boolean)
        {
            Caption = 'Enabled';
            Editable = false;
        }
        field(60;"Linked Endpoints";Integer)
        {
            CalcFormula = Count("Nc Endpoint Trigger Link" WHERE ("Endpoint Code"=FIELD(Code)));
            Caption = 'Linked Endpoints';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        SetupEndpoint;
    end;

    trigger OnRename()
    var
        TextRenameNotAllowed: Label 'Renaming %1 is not allowed.';
    begin
        Error(TextRenameNotAllowed,TableCaption);
    end;

    procedure SetupEndpoint()
    begin
        if "Endpoint Type" = '' then
          if not ChooseEndpoint then
            exit;
        OpenEndpointSetup;
    end;

    local procedure ChooseEndpoint(): Boolean
    var
        NcEndpointType: Record "Nc Endpoint Type";
    begin
        NcEndpointType.Reset;
        if PAGE.RunModal(PAGE::"Nc Endpoint Types",NcEndpointType) = ACTION::LookupOK then begin
          Validate("Endpoint Type",NcEndpointType.Code);
          exit(true);
        end else
          exit(false);
    end;

    local procedure OpenEndpointSetup()
    var
        Handled: Boolean;
        TextNoSetup: Label 'No setup is associated with %1 %2.';
    begin
        TestField("Endpoint Type");
        Handled := false;
        OnOpenEndpointSetup(Handled);
        if not Handled then
           Error(TextNoSetup,FieldCaption("Endpoint Type"),"Endpoint Type");
    end;

    [IntegrationEvent(TRUE, false)]
    local procedure OnOpenEndpointSetup(var Handled: Boolean)
    begin
    end;
}

