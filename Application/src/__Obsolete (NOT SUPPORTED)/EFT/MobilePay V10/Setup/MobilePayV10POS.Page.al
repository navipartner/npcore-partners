﻿page 6014436 "NPR MobilePayV10 POS"
{
    Extensible = False;
    PageType = List;
    SourceTable = "NPR MobilePayV10 POS";
    SourceTableTemporary = true;
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    Caption = 'MobilePayV10 POS';
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'No longer supported';


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("MobilePay POS ID"; Rec."MobilePay POS ID")
                {

                    ToolTip = 'Specifies the value of the MobilePay POS ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Merchant POS ID"; Rec."Merchant POS ID")
                {

                    ToolTip = 'Specifies the value of the Merchant POS ID field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Beacon ID"; Rec."Beacon ID")
                {

                    ToolTip = 'Specifies the value of the Beacon ID field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
