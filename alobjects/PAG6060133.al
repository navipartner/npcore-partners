page 6060133 "MM Member Card Card"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.22/TSA /20170911 CASE 284560 Added field Card Is Temporary
    // MM1.28/TSA /20180420 CASE 311030 Changed property InsertAllowed to No, to removed the "New" button available in the Member Card subpage part

    Caption = 'Member Card Card';
    DataCaptionExpression = "External Card No.";
    InsertAllowed = false;
    SourceTable = "MM Member Card";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("External Card No.";"External Card No.")
                {
                    NotBlank = true;
                    ShowMandatory = true;
                }
                field("External Card No. Last 4";"External Card No. Last 4")
                {
                }
                field("Pin Code";"Pin Code")
                {
                }
                field("Valid Until";"Valid Until")
                {
                }
                field("Card Is Temporary";"Card Is Temporary")
                {
                }
                field(Blocked;Blocked)
                {
                }
                field("Blocked At";"Blocked At")
                {
                }
                field("Block Reason";"Block Reason")
                {
                }
                field("Membership Entry No.";"Membership Entry No.")
                {
                    Editable = false;
                }
                field("Member Entry No.";"Member Entry No.")
                {
                    Editable = false;
                }
                field("Document ID";"Document ID")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if (CloseAction = ACTION::OK) then
          TestField ("External Card No.");
    end;
}

