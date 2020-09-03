page 6151530 "NPR Nc Collec. Filters"
{
    // NC2.01/BR  /20160909  CASE 250447 Object created
    // NC2.08/BR  /20171220  CASE 300634 Added field Collect When Modified

    Caption = 'Nc Collector Filters';
    DelayedInsert = true;
    MultipleNewLines = false;
    PageType = ListPart;
    PopulateAllFields = true;
    SourceTable = "NPR Nc Collector Filter";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                }
                field("Filter Text"; "Filter Text")
                {
                    ApplicationArea = All;
                }
                field("Collect When Modified"; "Collect When Modified")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
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
        if ("Collector Code" <> '') and ("Table No." = 0) then begin
            if NcCollector.Get("Collector Code") then begin
                "Table No." := NcCollector."Table No.";

            end;
        end;
    end;
}

