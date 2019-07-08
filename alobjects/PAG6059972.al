page 6059972 "Variety Table"
{
    // VRT1.10/JDH/20160105 CASE 201022 Added field "Lock Table"
    // VRT1.11/JDH /20160602 CASE 242940 Added setup new line
    // NPR5.41/TS  /20180105 CASE 300893 ActionContainers cannot have captions

    Caption = 'Variety Table';
    PageType = List;
    SourceTable = "Variety Table";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type;Type)
                {
                    Visible = false;
                }
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Use in Variant Description";"Use in Variant Description")
                {
                }
                field("Pre tag In Variant Description";"Pre tag In Variant Description")
                {
                }
                field("Use Description field";"Use Description field")
                {
                }
                field("Lock Table";"Lock Table")
                {
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
                RunObject = Page "Variety Value";
                RunPageLink = Type=FIELD(Type),
                              Table=FIELD(Code);
                RunPageView = SORTING(Type,Table,Value);
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

