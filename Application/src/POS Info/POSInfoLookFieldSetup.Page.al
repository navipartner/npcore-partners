page 6150645 "NPR POS Info Look. Field Setup"
{
    Caption = 'POS Info Lookup Field Setup';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Info Lookup Setup";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Group';
                field("Map To"; "Map To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Map To field';
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                    DrillDown = false;
                    Lookup = false;
                    ToolTip = 'Specifies the value of the Field No. field';

                    trigger OnAssistEdit()
                    begin
                        AssistEdit;
                    end;
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        LoadTable;
        CurrPage.Update(true);
    end;

    var
        POSInfo: Record "NPR POS Info";

    local procedure LoadTable()
    var
        i: Integer;
        POSInfoLookupSetup: Record "NPR POS Info Lookup Setup";
    begin
        for i := 0 to 5 do begin
            Rec.Init;
            Rec."POS Info Code" := POSInfo.Code;
            Rec."Table No" := POSInfo."Table No.";
            Rec."Map To" := i;
            if POSInfoLookupSetup.Get("POS Info Code", "Table No", "Map To") then
                "Field No." := POSInfoLookupSetup."Field No.";
            if Rec.Insert then;
        end;
    end;

    local procedure AssistEdit()
    var
        FieldRec: Record "Field";
        FieldList: Page "NPR Field Lookup";
        POSInfoLookupSetup: Record "NPR POS Info Lookup Setup";
    begin
        FieldRec.FilterGroup(2);
        FieldRec.SetRange(TableNo, "Table No");
        FieldRec.FilterGroup(0);
        FieldList.SetTableView(FieldRec);
        FieldList.LookupMode(true);
        if FieldList.RunModal = ACTION::LookupOK then begin
            FieldList.GetRecord(FieldRec);
            "Field No." := FieldRec."No.";
            POSInfoLookupSetup := Rec;
            if not POSInfoLookupSetup.Insert then
                POSInfoLookupSetup.Modify;
        end;
    end;

    procedure SetPOSInfo(pPOSInfo: Record "NPR POS Info")
    begin
        POSInfo := pPOSInfo;
    end;
}

