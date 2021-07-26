tableextension 6014417 "NPR Default Dimension" extends "Default Dimension"
{

    fields
    {
        field(6151479; "NPR Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
        }

    }
    keys
    {
        key("NPR Key1"; "NPR Replication Counter")
        {
        }
    }

    trigger OnAfterInsert()
    begin
        UpdateGlobalDimensions(Rec."Dimension Value Code");
    end;

    trigger OnAfterModify()
    begin
        UpdateGlobalDimensions(Rec."Dimension Value Code");
    end;

    trigger OnAfterDelete()
    begin
        UpdateGlobalDimensions('');
    end;

    local procedure UpdateGlobalDimensions(DimensionValueCode: Code[20])
    var
        GLSetup: Record "General Ledger Setup";
        DefaultDimensionMgt: Codeunit "NPR Default Dimension Mgt.";
    begin
        GLSetup.Get();
        if Rec."Dimension Code" = GLSetup."Global Dimension 1 Code" then
            DefaultDimensionMgt.UpdateGlobalDimCode(1, Rec."Table ID", Rec."No.", DimensionValueCode);
        if Rec."Dimension Code" = GLSetup."Global Dimension 2 Code" then
            DefaultDimensionMgt.UpdateGlobalDimCode(2, Rec."Table ID", Rec."No.", DimensionValueCode);
    end;
}