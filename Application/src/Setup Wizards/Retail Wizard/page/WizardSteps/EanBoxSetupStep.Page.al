page 6014673 "NPR Ean Box Setup Step"
{
    Extensible = False;
    Caption = 'Ean Box Setup';
    PageType = ListPart;
    SourceTable = "NPR Ean Box Setup";
    SourceTableTemporary = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CheckIfNoAvailableInEanBoxSetup(TempExistingEanBoxSetup, Rec.Code);
                    end;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("POS View"; Rec."POS View")
                {

                    ToolTip = 'Specifies the value of the POS View field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        CopyReal();
    end;

    var
        TempExistingEanBoxSetup: Record "NPR Ean Box Setup" temporary;

    procedure GetRec(var TempEanBoxSetup: Record "NPR Ean Box Setup")
    begin
        TempEanBoxSetup.Copy(Rec);
    end;

    procedure CreateEanBoxSetupData()
    var
        EanBoxSetup: Record "NPR Ean Box Setup";
    begin
        if Rec.FindSet() then
            repeat
                EanBoxSetup := Rec;
                if not EanBoxSetup.Insert() then
                    EanBoxSetup.Modify();
            until Rec.Next() = 0;
    end;

    procedure EanBoxSetupDataToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    procedure CopyRealAndTemp(var TempEanBoxSetup: Record "NPR Ean Box Setup")
    var
        EanBoxSetup: Record "NPR Ean Box Setup";
    begin
        TempEanBoxSetup.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempEanBoxSetup := Rec;
                TempEanBoxSetup.Insert();
            until Rec.Next() = 0;

        TempEanBoxSetup.Init();
        if EanBoxSetup.FindSet() then
            repeat
                TempEanBoxSetup.TransferFields(EanBoxSetup);
                TempEanBoxSetup.Insert();
            until EanBoxSetup.Next() = 0;
    end;

    local procedure CopyReal()
    var
        EanBoxSetup: Record "NPR Ean Box Setup";
    begin
        if EanBoxSetup.FindSet() then
            repeat
                TempExistingEanBoxSetup := EanBoxSetup;
                TempExistingEanBoxSetup.Insert();
            until EanBoxSetup.Next() = 0;
    end;

    local procedure CheckIfNoAvailableInEanBoxSetup(var EanBoxSetup: Record "NPR Ean Box Setup"; var WantedStartingNo: Code[20]) CalculatedNo: Code[20]
    var
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
    begin
        CalculatedNo := WantedStartingNo;

        EanBoxSetup.SetRange(Code, CalculatedNo);

        if EanBoxSetup.FindFirst() then begin
            WantedStartingNo := HelperFunctions.FormatCode20(WantedStartingNo);
            CalculatedNo := CheckIfNoAvailableInEanBoxSetup(EanBoxSetup, WantedStartingNo);
        end;
    end;
}

