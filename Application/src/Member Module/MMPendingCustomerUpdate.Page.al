page 6184965 "NPR MM Pending Customer Update"
{
    Extensible = False;
    Caption = 'Pending Customer Update';
    PageType = List;
    Editable = false;
    SourceTable = "NPR MM Pending Customer Update";
    ApplicationArea = NPRRetail;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                ShowCaption = false;
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value for Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value for Customer No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer Config. Template Code"; Rec."Customer Config. Template Code")
                {
                    ToolTip = 'Specifies the value for Customer Config. Template Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Valid From Date"; Rec."Valid From Date")
                {
                    ToolTip = 'Specifies the value for Valid From Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Update Processed"; Rec."Update Processed")
                {
                    ToolTip = 'Specifies if the update has been processed for this entry';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
