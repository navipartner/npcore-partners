page 6014487 "NPR Replication Error Log"
{

    ApplicationArea = NPRRetail;
    Caption = 'Replication Error Log';
    PageType = List;
    SourceTable = "NPR Replication Error Log";
    UsageCategory = Lists;
    SourceTableView = sorting("Entry No.") order(descending);
    Extensible = false;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the Entry No.';
                    ApplicationArea = NPRRetail;
                }
                field("API Version"; Rec."API Version")
                {
                    ToolTip = 'Specifies Replication API Setup Code.';
                    ApplicationArea = NPRRetail;
                }
                field("Endpoint ID"; Rec."Endpoint ID")
                {
                    ToolTip = 'Specifies the Replication API Endpoint ID.';
                    ApplicationArea = NPRRetail;
                }
                field(Method; Rec.Method)
                {
                    ToolTip = 'Specifies Replication API Method.';
                    ApplicationArea = NPRRetail;
                }
                field(URL; Rec.URL)
                {
                    ToolTip = 'Specifies Replication API URL.';
                    ApplicationArea = NPRRetail;
                }
                field("System Created At"; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies date and time when the entry was created.';
                    ApplicationArea = NPRRetail;
                }
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'Specifies the User ID who created the entry.';
                    ApplicationArea = NPRRetail;
                }
                field("Email Notification Sent"; Rec."Email Notification Sent")
                {
                    ToolTip = 'Specifies if a notification was sent by E-mail about the error.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(ShowRequest)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Request';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = XMLFile;
                ToolTip = 'Shows the API Request Body. For Get requests this is empty.';
                trigger OnAction()
                begin
                    Message(Rec.ReadTextFromBlob(Rec.FieldNo(Request)));
                end;
            }
            action(ShowResponse)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Response';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Shows the API Response Body or the Encountered Error.';
                Image = XMLFile;
                trigger OnAction()
                begin
                    Message(Rec.ReadTextFromBlob(Rec.FieldNo(Response)));
                end;
            }
        }
    }
}
