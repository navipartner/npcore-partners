﻿page 6151444 "NPR Magento Display Groups"
{
    Extensible = False;
    Caption = 'Magento Display Groups';
    PageType = List;
    SourceTable = "NPR Magento Display Group";
    UsageCategory = Lists;
    ApplicationArea = NPRMagento;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRMagento;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRMagento;
                }
            }
        }
    }
}
