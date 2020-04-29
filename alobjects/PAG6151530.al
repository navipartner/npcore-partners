page 6151530 "Nc Collector Filters"
{
    // NC2.01/BR  /20160909  CASE 250447 Object created
    // NC2.08/BR  /20171220  CASE 300634 Added field Collect When Modified

    Caption = 'Nc Collector Filters';
    DelayedInsert = true;
    MultipleNewLines = false;
    PageType = ListPart;
    PopulateAllFields = true;
    SourceTable = "Nc Collector Filter";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field No.";"Field No.")
                {
                }
                field("Field Name";"Field Name")
                {
                }
                field("Filter Text";"Filter Text")
                {
                }
                field("Collect When Modified";"Collect When Modified")
                {
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
        NcCollector: Record "Nc Collector";
    begin
        if ("Collector Code" <> '') and ("Table No." = 0)  then begin
          if NcCollector.Get("Collector Code") then begin
            "Table No." := NcCollector."Table No.";

          end;
        end;
    end;
}

