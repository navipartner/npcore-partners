﻿page 6151404 "NPR Magento Website List"
{
    Extensible = False;
    Caption = 'Magento Website List';
    CardPageID = "NPR Magento Websites";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Magento Website";
    ApplicationArea = NPRMagento;

    layout
    {
        area(content)
        {
            repeater(Control6150613)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRMagento;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRMagento;
                }
                field("Default Website"; Rec."Default Website")
                {

                    ToolTip = 'Specifies the value of the Std. Website field';
                    ApplicationArea = NPRMagento;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                    ApplicationArea = NPRMagento;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {

                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                    ApplicationArea = NPRMagento;
                }
            }
        }
    }
}
