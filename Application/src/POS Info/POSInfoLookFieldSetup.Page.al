page 6150645 "NPR POS Info Look. Field Setup"
{
    Caption = 'POS Info Lookup Field Setup';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR POS Info Lookup Setup";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Group';
                field("Map To"; Rec."Map To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Map To field';
                }
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field No. field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupFieldNo(Text));
                    end;
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
            }
        }
    }

    var
        POSInfo: Record "NPR POS Info";

    trigger OnOpenPage()
    begin
        LoadTable();
        CurrPage.Update();
    end;

    trigger OnClosePage()
    var
        POSInfoLookupSetup: Record "NPR POS Info Lookup Setup";
    begin
        POSInfoLookupSetup.SetRange("POS Info Code", POSInfo.Code);
        POSInfoLookupSetup.DeleteAll();

        Rec.Reset();
        Rec.SetFilter("Field No.", '<>%1', 0);
        if Rec.FindSet() then
            repeat
                POSInfoLookupSetup := Rec;
                POSInfoLookupSetup.Insert();
            until Rec.Next() = 0;
    end;

    local procedure LoadTable()
    var
        i: Integer;
        POSInfoLookupSetup: Record "NPR POS Info Lookup Setup";
    begin
        for i := 0 to 5 do begin
            Rec.Init();
            Rec."POS Info Code" := POSInfo.Code;
            Rec."Table No" := POSInfo."Table No.";
            Rec."Map To" := i;
            if POSInfoLookupSetup.Get(Rec."POS Info Code", Rec."Table No", Rec."Map To") then
                Rec."Field No." := POSInfoLookupSetup."Field No.";
            if Rec.Insert() then;
        end;
    end;

    local procedure LookupFieldNo(var Text: Text): Boolean
    var
        FieldRec: Record "Field";
        FieldList: Page "NPR Field Lookup";
        CurrentlySelectedFieldNo: Integer;
    begin
        if not Evaluate(CurrentlySelectedFieldNo, Text) then
            CurrentlySelectedFieldNo := 0;
        FieldRec.FilterGroup(2);
        FieldRec.SetRange(TableNo, Rec."Table No");
        FieldRec.FilterGroup(0);
        if CurrentlySelectedFieldNo <> 0 then
            if FieldRec.Get(Rec."Table No", CurrentlySelectedFieldNo) then;
        FieldList.SetTableView(FieldRec);
        FieldList.LookupMode(true);
        if FieldList.RunModal() = ACTION::LookupOK then begin
            FieldList.GetRecord(FieldRec);
            Text := Format(FieldRec."No.");
            exit(true);
        end;
        exit(false);
    end;

    procedure SetPOSInfo(pPOSInfo: Record "NPR POS Info")
    begin
        POSInfo := pPOSInfo;
    end;
}

