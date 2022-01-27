page 6151203 "NPR NpCs Document Mapping"
{
    Extensible = False;
    Caption = 'Collect Document Mapping';
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

                    ToolTip = 'Specifies the type of mapping.';
                    ApplicationArea = NPRRetail;
                }
                field("From Store Code"; Rec."From Store Code")
                {

                    ToolTip = 'Specifies the store code where the Click and Collect order has been created.';
                    ApplicationArea = NPRRetail;
                }
                field("From No."; Rec."From No.")
                {

                    ToolTip = 'Specifies the customer/item number used to create the Click and Collect order in the current store.';
                    ApplicationArea = NPRRetail;
                }
                field("From Description"; Rec."From Description")
                {

                    ToolTip = 'Specifies the description of the ‘From No’.';
                    ApplicationArea = NPRRetail;
                }
                field("From Description 2"; Rec."From Description 2")
                {

                    ToolTip = 'Specifies the longer description of the From No. field, if needed';
                    ApplicationArea = NPRRetail;
                }
                field("To No."; Rec."To No.")
                {

                    ToolTip = 'Specifies the customer/item no. that will be mapped in the collect store.';
                    ApplicationArea = NPRRetail;
                }
                field("To Description"; Rec."To Description")
                {

                    ToolTip = 'Specifies the description of the To No. field.';
                    ApplicationArea = NPRRetail;
                }
                field("To Description 2"; Rec."To Description 2")
                {

                    ToolTip = 'Specifies the longer description of the To No. field, if needed.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

