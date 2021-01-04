page 6014676 "NPR Endpoint Filters"
{
    // NPR5.23\BR\20160518  CASE 237658 Object created

    Caption = 'Endpoint Filters';
    DelayedInsert = true;
    MultipleNewLines = false;
    PageType = ListPart;
    UsageCategory = Administration;
    PopulateAllFields = true;
    SourceTable = "NPR Endpoint Filter";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field No. field';
                }
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field("Filter Text"; "Filter Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filter Text field';
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
        Endpoint: Record "NPR Endpoint";
    begin
        if ("Endpoint Code" <> '') and ("Table No." = 0) then begin
            if Endpoint.Get("Endpoint Code") then begin
                "Table No." := Endpoint."Table No.";

            end;
        end;
    end;
}

