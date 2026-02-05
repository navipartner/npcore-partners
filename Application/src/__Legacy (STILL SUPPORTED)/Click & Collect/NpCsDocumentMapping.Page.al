page 6151203 "NPR NpCs Document Mapping"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Extensible = False;
    Caption = 'Collect Document Mapping';
    ContextSensitiveHelpPage = 'docs/retail/click_and_collect/how-to/setup/setup/';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR NpCs Document Mapping";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the Type of mapping.';
                    ApplicationArea = NPRRetail;
                }
                field("From Store Code"; Rec."From Store Code")
                {

                    ToolTip = 'Indicates the Store Code where the Click and Collect order has been created.';
                    ApplicationArea = NPRRetail;
                }
                field("From No."; Rec."From No.")
                {

                    ToolTip = 'Specifies the customer/item number used to create the Click and Collect order in the current store.';
                    ApplicationArea = NPRRetail;
                }
                field("From Description"; Rec."From Description")
                {

                    ToolTip = 'Specifies the Description of the From No. field.';
                    ApplicationArea = NPRRetail;
                }
                field("From Description 2"; Rec."From Description 2")
                {

                    ToolTip = 'Specifies the longer Description of the From No. field.';
                    ApplicationArea = NPRRetail;
                }
                field("To No."; Rec."To No.")
                {

                    ToolTip = 'Indicates the Customer/Item No. that will be mapped in the Collect Store.';
                    ApplicationArea = NPRRetail;
                }
                field("To Description"; Rec."To Description")
                {

                    ToolTip = 'Specifies the Description of the To No. field.';
                    ApplicationArea = NPRRetail;
                }
                field("To Description 2"; Rec."To Description 2")
                {

                    ToolTip = 'Specifies the longer Description of the To No. field.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

