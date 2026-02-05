#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
table 6151255 "NPR NaviPartner API Key Perm."
{
    Caption = 'NaviPartner API Key Permission';
    DataClassification = CustomerContent;
    Access = Internal;
    Extensible = false;
    DataPerCompany = false;

    fields
    {
        field(1; "NPR NP API Key Id"; Guid)
        {
            Caption = 'NaviPartner API Key Id';
            Editable = false;
            NotBlank = true;
            TableRelation = "NPR NaviPartner API Key";
            ToolTip = 'Specifies a link with NaviPartner API Key.';
        }
        field(2; "Permission Set ID"; Code[20])
        {
            Caption = 'Permission Set ID';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "Aggregate Permission Set"."Role ID";
            ValidateTableRelation = true;
            ToolTip = 'Specifies the ID of the permission set assigned to the API key.';

            trigger OnLookup()
            var
                AggregatePermissionSet: Record "Aggregate Permission Set";
            begin
                AggregatePermissionSet.SetFilter(Name, '%1', 'NPR API*');
                if (Page.RunModal(Page::"Lookup Permission Set", AggregatePermissionSet) = Action::LookupOK) then
                    Rec."Permission Set ID" := AggregatePermissionSet."Role ID";
            end;
        }
        field(3; "Permission Set Name"; Text[30])
        {
            Caption = 'Permission Set Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Aggregate Permission Set".Name where("Role ID" = field("Permission Set ID")));
            Editable = false;
            ToolTip = 'Specifies the name of the permission set assigned to the API key.';
        }
    }

    keys
    {
        key(PK; "NPR NP API Key Id", "Permission Set ID")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        ValidatePermissionSet();
    end;

    trigger OnRename()
    begin
        ValidatePermissionSet();
    end;

    local procedure ValidatePermissionSet()
    begin
        if (Rec."Permission Set ID" = 'NPR NP RETAIL') then
            Rec.FieldError("Permission Set ID");
    end;
}
#endif