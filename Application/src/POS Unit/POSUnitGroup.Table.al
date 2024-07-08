table 6014684 "NPR POS Unit Group"
{
    Access = Internal;
    Caption = 'POS Unit Group';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Unit Groups";
    LookupPageID = "NPR POS Unit Groups";


    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
            NotBlank = true;
        }
        field(10; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    var
        CannotRenameErr: Label 'You cannot rename a %1.';

    trigger OnDelete()
    begin
        UpdateSalespersons();
        UpdateLines();
    end;

    trigger OnRename()
    begin
        Error(CannotRenameErr, TableCaption);
    end;

    local procedure UpdateSalespersons()
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        ToModifySalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        SalespersonPurchaser.SetRange("NPR POS Unit Group", Rec."No.");
        if SalespersonPurchaser.IsEmpty() then
            exit;
        SalespersonPurchaser.FindSet();
        repeat
            ToModifySalespersonPurchaser := SalespersonPurchaser;
            ToModifySalespersonPurchaser."NPR POS Unit Group" := '';
            ToModifySalespersonPurchaser.Modify();
        until SalespersonPurchaser.Next() = 0;
    end;

    local procedure UpdateLines()
    var
        POSUnitGroupLine: Record "NPR POS Unit Group Line";
    begin
        POSUnitGroupLine.SetRange("No.", Rec."No.");
        if POSUnitGroupLine.IsEmpty() then
            exit;
        POSUnitGroupLine.DeleteAll();
    end;
}