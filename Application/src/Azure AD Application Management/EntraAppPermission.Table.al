table 6150915 "NPR Entra App Permission"
{
    Caption = 'Entra App Permission';
    DataClassification = CustomerContent;
    TableType = Temporary;
    Access = Internal;
    Extensible = False;

    fields
    {
        field(1; "Permission Set ID"; Code[20])
        {
            Caption = 'Permission Set ID';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "Aggregate Permission Set"."Role ID";

#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
            trigger OnLookup()
            var
                AggregatePermissionSet: Record "Aggregate Permission Set";
            begin
                AggregatePermissionSet.SetFilter(Name, '%1', 'NPR API*');
                if Page.RunModal(Page::"Lookup Permission Set", AggregatePermissionSet) = Action::LookupOK then
                    Rec."Permission Set ID" := AggregatePermissionSet."Role ID";
            end;
#endif
        }
        field(2; "Permission Set Name"; Text[30])
        {
            Caption = 'Permission Set Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Aggregate Permission Set".Name where("Role ID" = field("Permission Set ID")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Permission Set ID")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        ValidatePermissionSet();
    end;

    trigger OnModify()
    begin
        ValidatePermissionSet();
    end;

    local procedure ValidatePermissionSet()
    begin
        if Rec."Permission Set ID" = 'NPR NP RETAIL' then
            FieldError(Rec."Permission Set ID");
    end;
}