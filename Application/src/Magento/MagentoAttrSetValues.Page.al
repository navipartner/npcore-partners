﻿page 6151435 "NPR Magento Attr. Set Values"
{
    Extensible = False;
    Caption = 'Attribute Set Values';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR Magento Attr. Set Value";
    SourceTableView = SORTING(Position);

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Attribute ID"; Rec."Attribute ID")
                {

                    ToolTip = 'Specifies the value of the Attribute ID field';
                    ApplicationArea = NPRMagento;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRMagento;
                }
                field(Position; Rec.Position)
                {

                    ToolTip = 'Specifies the value of the Position field';
                    ApplicationArea = NPRMagento;
                }
                field("Attribute Group ID"; Rec."Attribute Group ID")
                {

                    ToolTip = 'Specifies the value of the Attribute Group ID field';
                    ApplicationArea = NPRMagento;
                }
            }
        }
    }
}
