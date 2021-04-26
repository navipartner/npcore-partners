page 6151530 "NPR Nc Collec. Filters"
{
    Caption = 'Nc Collector Filters';
    DelayedInsert = true;
    MultipleNewLines = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    PopulateAllFields = true;
    SourceTable = "NPR Nc Collector Filter";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field No. field';
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field("Filter Text"; Rec."Filter Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filter Text field';
                }
                field("Collect When Modified"; Rec."Collect When Modified")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Collect When Modified field';
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        SetTableNo;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetTableNo;
    end;

    local procedure SetTableNo()
    var
        NcCollector: Record "NPR Nc Collector";
    begin
        if (Rec."Collector Code" <> '') and (Rec."Table No." = 0) then begin
            if NcCollector.Get(Rec."Collector Code") then
                Rec."Table No." := NcCollector."Table No.";
        end;
    end;
}

