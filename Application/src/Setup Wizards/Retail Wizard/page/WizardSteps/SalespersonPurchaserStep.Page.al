page 6014689 "NPR Salesperson/Purchaser Step"
{
    Caption = 'Salespersons';
    PageType = ListPart;
    SourceTable = "NPR Salesperson Buffer";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Entry No."; Rec."Entry No.")
                {

                    Caption = 'Entry No.';
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the code of the record.';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    var
                        Salesperson: Record "NPR Salesperson Buffer";
                    begin
                        CheckIfNoAvailableInSalespersonPurchaser(Salesperson, Rec.Code);
                    end;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the name of the record.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    procedure CopyRealAndTemp(var TempSalesperson: Record "NPR Salesperson Buffer")
    var
        Salesperson: Record "Salesperson/Purchaser";
    begin
        TempSalesperson.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempSalesperson := Rec;
                TempSalesperson.Insert();
            until Rec.Next() = 0;

        TempSalesperson.Init();
        if Salesperson.FindSet() then
            repeat
                TempSalesperson.TransferFields(Salesperson);
                TempSalesperson.Insert();
            until Salesperson.Next() = 0;
    end;

    procedure CheckIfNoAvailableInSalespersonPurchaser(var SalespersonPurchaser: Record "NPR Salesperson Buffer"; var WantedStartingNo: Code[10]) CalculatedNo: Code[10]
    var
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
    begin
        if WantedStartingNo = '' then
            WantedStartingNo := '1';

        CalculatedNo := WantedStartingNo;

        if SalespersonPurchaser.Get(WantedStartingNo) then begin
            HelperFunctions.FormatCode(WantedStartingNo, true);
            CalculatedNo := CheckIfNoAvailableInSalespersonPurchaser(SalespersonPurchaser, WantedStartingNo);
        end;
    end;

    procedure SalespersonsToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    procedure CreateSalespersonData()
    var
        Salesperson: Record "Salesperson/Purchaser";
    begin
        if Rec.FindSet() then
            repeat
                Salesperson.TransferFields(Rec);
                if not Salesperson.Insert() then
                    Salesperson.Modify();
            until Rec.Next() = 0;
    end;
}