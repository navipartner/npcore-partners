page 6059972 "NPR Variety Table"
{
    // VRT1.10/JDH/20160105 CASE 201022 Added field "Lock Table"
    // VRT1.11/JDH /20160602 CASE 242940 Added setup new line
    // NPR5.41/TS  /20180105 CASE 300893 ActionContainers cannot have captions

    Caption = 'Variety Table';
    PageType = List;
    SourceTable = "NPR Variety Table";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Use in Variant Description"; "Use in Variant Description")
                {
                    ApplicationArea = All;
                }
                field("Pre tag In Variant Description"; "Pre tag In Variant Description")
                {
                    ApplicationArea = All;
                }
                field("Use Description field"; "Use Description field")
                {
                    ApplicationArea = All;
                }
                field("Lock Table"; "Lock Table")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Values)
            {
                Caption = 'Values';
                Image = "table";
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Variety Value";
                RunPageLink = Type = FIELD(Type),
                              Table = FIELD(Code);
                RunPageView = SORTING(Type, Table, Value);
                ApplicationArea=All;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        //-VRT1.11
        SetupNewLine;
        //+VRT1.11
    end;
}

