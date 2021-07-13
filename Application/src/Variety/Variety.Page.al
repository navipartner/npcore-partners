page 6059971 "NPR Variety"
{
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

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Use in Variant Description"; Rec."Use in Variant Description")
                {

                    ToolTip = 'Specifies the value of the Use in Variant Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Pre tag In Variant Description"; Rec."Pre tag In Variant Description")
                {

                    ToolTip = 'Specifies the value of the Pre tag In Variant Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Use Description field"; Rec."Use Description field")
                {

                    ToolTip = 'Specifies the value of the Use Description field field';
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
                Caption = 'Variety Tabel';
                Image = "Table";
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Variety Table";
                RunPageLink = Type = FIELD(Code);
                RunPageView = SORTING(Type, Code);

                ToolTip = 'Executes the Variety Tabel action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

