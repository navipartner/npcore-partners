tableextension 6014417 "NPR Default Dimension" extends "Default Dimension"
{

    fields
    {
        field(6151479; "NPR Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }

    }
    keys
    {
        key("NPR Key1"; "NPR Replication Counter")
        {
            ObsoleteState = Pending;
            ObsoleteTag = 'NPR23.0';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key("NPR Key2"; SystemRowVersion)
        {
        }
#ENDIF
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
