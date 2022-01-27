page 6151530 "NPR Nc Collec. Filters"
{
    Extensible = False;
    Caption = 'Nc Collector Filters';
    DelayedInsert = true;
    MultipleNewLines = false;
    PageType = ListPart;
    UsageCategory = Administration;
    PopulateAllFields = true;
    SourceTable = "NPR Nc Collector Filter";
    ApplicationArea = NPRNaviConnect;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field No."; Rec."Field No.")
                {

                    ToolTip = 'Specifies the value of the Field No. field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Field Name"; Rec."Field Name")
                {

                    ToolTip = 'Specifies the value of the Field Name field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Filter Text"; Rec."Filter Text")
                {

                    ToolTip = 'Specifies the value of the Filter Text field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Collect When Modified"; Rec."Collect When Modified")
                {

                    ToolTip = 'Specifies the value of the Collect When Modified field';
                    ApplicationArea = NPRNaviConnect;
                }
            }
        }
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
        NcCollector: Record "NPR Nc Collector";
    begin
        if (Rec."Collector Code" <> '') and (Rec."Table No." = 0) then begin
            if NcCollector.Get(Rec."Collector Code") then
                Rec."Table No." := NcCollector."Table No.";
        end;
    end;
}

