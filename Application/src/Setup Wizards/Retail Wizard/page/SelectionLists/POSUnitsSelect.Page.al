page 6059780 "NPR POS Units Select"
{
    Caption = 'POS Unit List';
    PageType = List;
    SourceTable = "NPR POS Unit";
    SourceTableTemporary = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Status; Status)
                {
                    Visible = POSUnitMode;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    Visible = POSUnitMode;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    Visible = POSUnitMode;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                }
                field(LocationCode; LocationCode)
                {
                    Visible = POSUnitMode;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the LocationCode field';
                }
                field(OpeningCash; OpeningCash)
                {
                    Visible = POSUnitMode;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the OpeningCash field';
                }
                field(ClosingCash; ClosingCash)
                {
                    Visible = POSUnitMode;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ClosingCash field';
                }
            }
        }
    }

    var
        POSUnitMode: Boolean;
        OpeningCash: Decimal;
        ClosingCash: Decimal;
        LocationCode: Code[10];
        LocationCaption: Text;

    trigger OnAfterGetRecord()
    var
        POSStore: Record "NPR POS Store";
    begin
        if not POSUnitMode then exit;

        if POSStore.Get(Rec."POS Store Code") then begin
            // ivas todo - don't know where are these fields now
            // OpeningCash := Register."Opening Cash";
            // ClosingCash := Register."Closing Cash";
            LocationCode := POSStore."Location Code";

            // ivas todo - don't know where are these fields now
            // OpeningCashCaption := Register.FieldCaption("Opening Cash");
            // ClosingCashcaption := Register.FieldCaption("Closing Cash");
            LocationCaption := POSStore.FieldCaption("Location Code");
        end;
    end;

    procedure SetPOSUnitMode(Set: Boolean)
    begin
        POSUnitMode := Set;
    end;

    procedure SetRec(var TempPOSUnit: Record "NPR POS Unit")
    begin
        if TempPOSUnit.FindSet() then
            repeat
                Rec.Copy(TempPOSUnit);
                Rec."POS Store Code" := '';
                Rec.Insert(false);
                Rec."POS Store Code" := TempPOSUnit."POS Store Code";
                Rec.Modify(false);
            until TempPOSUnit.Next() = 0;

        if Rec.FindSet() then;
    end;
}