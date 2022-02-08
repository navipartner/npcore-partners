page 6059971 "NPR Variety"
{
    Extensible = False;
    // VRT1.11/TR/20150428  CASE 210960 - Caption on action changed from "Variety Value" to "Variety Table".
    // NPR5.41/TS  /20180105 CASE 300893 ActionContainers cannot have captions

    Caption = 'Variety';
    PageType = List;
    SourceTable = "NPR Variety";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the code used in association with a variety.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the variety description.';
                    ApplicationArea = NPRRetail;
                }
                field("Use in Variant Description"; Rec."Use in Variant Description")
                {

                    ToolTip = 'Use this variety to generate the description for the relevant variant.';
                    ApplicationArea = NPRRetail;
                }
                field("Pre tag In Variant Description"; Rec."Pre tag In Variant Description")
                {

                    ToolTip = 'Generate the description on the variant with the provided tag in front of the value. Only works if Use in Variant Description is ticked.';
                    ApplicationArea = NPRRetail;
                }
                field("Use Description field"; Rec."Use Description field")
                {

                    ToolTip = 'Specifies whether the code field or the description field of the variant value is used in generating the variant description. Only works if Use in Variant Description is ticked.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Variety Tabel")
            {
                Caption = 'Variety Table';
                Image = "Table";
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Variety Table";
                RunPageLink = Type = FIELD(Code);
                RunPageView = SORTING(Type, Code);

                ToolTip = 'Open the Variety Table.';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

