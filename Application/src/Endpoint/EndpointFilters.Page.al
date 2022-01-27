page 6014676 "NPR Endpoint Filters"
{
    Extensible = False;
    // NPR5.23\BR\20160518  CASE 237658 Object created

    Caption = 'Endpoint Filters';
    DelayedInsert = true;
    MultipleNewLines = false;
    PageType = ListPart;
    UsageCategory = Administration;

    PopulateAllFields = true;
    SourceTable = "NPR Endpoint Filter";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field No."; Rec."Field No.")
                {

                    ToolTip = 'Specifies the value of the Field No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Field Name"; Rec."Field Name")
                {

                    ToolTip = 'Specifies the value of the Field Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Filter Text"; Rec."Filter Text")
                {

                    ToolTip = 'Specifies the value of the Filter Text field';
                    ApplicationArea = NPRRetail;
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

