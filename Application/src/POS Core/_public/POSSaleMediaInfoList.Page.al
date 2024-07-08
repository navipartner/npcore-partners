page 6059900 "NPR POS Sale Media Info List"
{
    Caption = 'POS Sale Media Info List';
    PageType = List;
    SourceTable = "NPR POS Sale Media Info";
    UsageCategory = None;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Register No."; Rec."Register No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Register No. field.';
                }
                field("Sales Ticket No."; Rec."Sales Ticket No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Sales Ticket No. field.';
                }
                field(Comment; Rec.Comment)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Comment field.';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the SystemCreatedBy field.';
                }
            }
        }
        area(factboxes)
        {
            part(ViewImage; "NPR POSSaleMediaImage FactBox")
            {
                Caption = 'Image';
                Editable = false;
                SubPageLink = "Entry No." = FIELD("Entry No.");
                ApplicationArea = NPRRetail;
            }
        }
    }
}
