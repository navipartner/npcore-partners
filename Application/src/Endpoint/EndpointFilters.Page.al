page 6014676 "NPR Endpoint Filters"
{
    // NPR5.23\BR\20160518  CASE 237658 Object created

    Caption = 'Endpoint Filters';
    DelayedInsert = true;
    MultipleNewLines = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    PopulateAllFields = true;
    SourceTable = "NPR Endpoint Filter";

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
            }
        }
    }

    actions
    {
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        SetTableNo();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetTableNo();
    end;

    local procedure SetTableNo()
    var
        Endpoint: Record "NPR Endpoint";
    begin
        if (Rec."Endpoint Code" <> '') and (Rec."Table No." = 0) then begin
            if Endpoint.Get(Rec."Endpoint Code") then begin
                Rec."Table No." := Endpoint."Table No.";

            end;
        end;
    end;
}

